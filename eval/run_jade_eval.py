#!/usr/bin/env python3
"""Minimal JADE evaluator for Ollama models.

Current behavior:
- Iterates through models and tasks.
- Optionally queries the model with each task prompt.
- Optionally writes generated code to task-defined output files.
- Runs a compile command against the target project.
- Logs one JSON record per model/task pair.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import re
import shutil
import subprocess
import time
import urllib.error
import urllib.request
from pathlib import Path, PureWindowsPath
from typing import Any

ANSI_ESCAPE_RE = re.compile(r"\x1B\[[0-?]*[ -/]*[@-~]")
THINK_BLOCK_RE = re.compile(r"<think\b[^>]*>.*?</think>", re.IGNORECASE | re.DOTALL)
THINK_TAG_RE = re.compile(r"</?think\b[^>]*>", re.IGNORECASE)
DEFAULT_OLLAMA_HOST = "http://100.116.25.114:11434"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Evaluate Ollama models on JADE tasks and log compile status."
    )
    parser.add_argument(
        "--models",
        nargs="+",
        required=True,
        help="Ollama model names, e.g. qwen2.5-coder:7b",
    )
    parser.add_argument(
        "--tasks-file",
        default="eval/tasks.sample.jsonl",
        help="Path to JSONL tasks file with fields: id, prompt",
    )
    parser.add_argument(
        "--project-path",
        default=".",
        help="Project directory to compile",
    )
    parser.add_argument(
        "--compile-cmd",
        default=None,
        help="Compile command. If omitted, a command is auto-detected when possible.",
    )
    parser.add_argument(
        "--compile-mode",
        choices=["local", "parallels"],
        default="local",
        help="Where to run compile command (default: local).",
    )
    parser.add_argument(
        "--parallels-vm",
        default=None,
        help='Parallels VM name/ID (required when --compile-mode parallels).',
    )
    parser.add_argument(
        "--parallels-project-path",
        default=None,
        help=(
            "Project path inside Parallels guest. If omitted, macOS "
            "/Users/<name>/... paths are mapped to C:\\Mac\\Home\\..."
        ),
    )
    parser.add_argument(
        "--parallels-shell",
        choices=["cmd", "powershell"],
        default="cmd",
        help="Shell inside Parallels guest for compile command.",
    )
    parser.add_argument(
        "--parallels-user",
        default=None,
        help="Guest username for prlctl exec. Defaults to --current-user.",
    )
    parser.add_argument(
        "--parallels-password-env",
        default=None,
        help="Environment variable name that stores guest password for --parallels-user.",
    )
    parser.add_argument(
        "--llm-backend",
        choices=["ollama", "openwebui"],
        default="ollama",
        help="Model generation backend: direct Ollama or Open WebUI chat API.",
    )
    parser.add_argument(
        "--skip-ollama",
        action="store_true",
        help="Skip model calls and only log compile status.",
    )
    parser.add_argument(
        "--ollama-host",
        default=DEFAULT_OLLAMA_HOST,
        help=(
            "Ollama server URL (sets OLLAMA_HOST for subprocess), "
            f"defaults to {DEFAULT_OLLAMA_HOST}"
        ),
    )
    parser.add_argument(
        "--ollama-mode",
        choices=["auto", "cli", "http"],
        default="auto",
        help=(
            "How to call Ollama: auto (cli if present, else http), "
            "cli (ollama binary), or http (POST /api/generate)."
        ),
    )
    parser.add_argument(
        "--ollama-think",
        choices=["auto", "true", "false"],
        default="auto",
        help=(
            "Thinking mode for supported models. "
            "Use false for faster non-thinking responses, true to force thinking, "
            "or auto to leave model default behavior."
        ),
    )
    parser.add_argument(
        "--openwebui-url",
        default="http://localhost:3000",
        help="Open WebUI base URL used when --llm-backend openwebui.",
    )
    parser.add_argument(
        "--openwebui-api-key-env",
        default="OPENWEBUI_API_KEY",
        help="Environment variable containing the Open WebUI API key.",
    )
    parser.add_argument(
        "--openwebui-collection-id",
        action="append",
        default=[],
        help=(
            "Knowledge collection ID to attach for RAG. "
            "Repeat this flag to attach multiple collections."
        ),
    )
    parser.add_argument(
        "--openwebui-file-id",
        action="append",
        default=[],
        help=(
            "File ID to attach for RAG. "
            "Repeat this flag to attach multiple files."
        ),
    )
    parser.add_argument(
        "--apply-generated",
        action="store_true",
        help="Write model responses to output files specified by each task.",
    )
    parser.add_argument(
        "--keep-generated",
        action="store_true",
        help="Keep generated files after each task. Default behavior restores original files.",
    )
    parser.add_argument(
        "--timeout-sec",
        type=int,
        default=300,
        help="Timeout for ollama and compile commands.",
    )
    parser.add_argument(
        "--output",
        default=None,
        help="Output JSONL path. Defaults to logs/eval-<timestamp>.jsonl",
    )
    return parser.parse_args()


def load_tasks(tasks_file: Path) -> list[dict[str, Any]]:
    tasks: list[dict[str, Any]] = []
    with tasks_file.open("r", encoding="utf-8") as handle:
        for line_no, line in enumerate(handle, start=1):
            raw = line.strip()
            if not raw:
                continue
            task = json.loads(raw)
            task_id = task.get("id", f"line_{line_no}")
            prompt = str(task.get("prompt", ""))
            output_path = task.get("output_path")
            extract = str(task.get("extract", "auto"))
            tasks.append(
                {
                    "id": str(task_id),
                    "prompt": prompt,
                    "output_path": None if output_path is None else str(output_path),
                    "extract": extract,
                }
            )
    if not tasks:
        raise ValueError(f"No tasks found in {tasks_file}")
    return tasks


def detect_compile_cmd(project_path: Path) -> str | None:
    if (project_path / "Cargo.toml").exists():
        return "cargo build"
    if (project_path / "go.mod").exists():
        return "go build ./..."
    if (project_path / "pom.xml").exists():
        return "mvn -q -DskipTests compile"
    if (project_path / "build.gradle").exists() or (project_path / "build.gradle.kts").exists():
        return "./gradlew build -x test"
    if (project_path / "package.json").exists():
        return "npm run build"
    if (project_path / "Makefile").exists():
        return "make build"
    if (project_path / "pyproject.toml").exists() or (project_path / "setup.py").exists():
        return "python -m compileall ."
    return None


def run_shell(command: str, cwd: Path, timeout_sec: int) -> dict[str, Any]:
    started = time.time()
    try:
        proc = subprocess.run(
            command,
            cwd=str(cwd),
            shell=True,
            capture_output=True,
            text=True,
            timeout=timeout_sec,
            check=False,
        )
        return {
            "ok": proc.returncode == 0,
            "exit_code": proc.returncode,
            "stdout": proc.stdout,
            "stderr": proc.stderr,
            "duration_sec": round(time.time() - started, 3),
            "timeout": False,
        }
    except subprocess.TimeoutExpired as exc:
        return {
            "ok": False,
            "exit_code": None,
            "stdout": exc.stdout or "",
            "stderr": exc.stderr or "",
            "duration_sec": round(time.time() - started, 3),
            "timeout": True,
        }


def map_mac_path_to_parallels(path: Path) -> str | None:
    resolved = path.resolve()
    parts = resolved.parts
    if len(parts) >= 3 and parts[1] == "Users":
        mapped = PureWindowsPath("C:/Mac/Home")
        for part in parts[3:]:
            mapped /= part
        return str(mapped)
    if len(parts) >= 2 and parts[1] == "Volumes":
        mapped = PureWindowsPath("C:/Mac/Volumes")
        for part in parts[2:]:
            mapped /= part
        return str(mapped)
    return None


def resolve_parallels_project_path(project_path: Path, explicit_path: str | None) -> str:
    if explicit_path:
        return explicit_path
    mapped = map_mac_path_to_parallels(project_path)
    if mapped:
        return mapped
    raise ValueError(
        "Could not map project path for Parallels guest. "
        "Pass --parallels-project-path explicitly."
    )


def run_compile_in_parallels(
    command: str,
    timeout_sec: int,
    vm: str,
    project_path_guest: str,
    shell_name: str,
    user: str | None,
    password_env: str | None,
) -> dict[str, Any]:
    started = time.time()
    prlctl_cmd = ["prlctl", "exec", vm]

    if user:
        prlctl_cmd.extend(["--user", user])
        if password_env:
            password = os.getenv(password_env)
            if not password:
                raise ValueError(
                    f"Environment variable {password_env!r} is not set for --parallels-password-env."
                )
            prlctl_cmd.extend(["--password", password])
    else:
        prlctl_cmd.append("--current-user")

    if shell_name == "powershell":
        remote = f'Set-Location -LiteralPath "{project_path_guest}"; {command}'
        prlctl_cmd.extend(["powershell.exe", "-NoProfile", "-Command", remote])
    else:
        remote = f'cd /d "{project_path_guest}" && {command}'
        prlctl_cmd.extend(["cmd.exe", "/c", remote])

    try:
        proc = subprocess.run(
            prlctl_cmd,
            capture_output=True,
            text=True,
            timeout=timeout_sec,
            check=False,
        )
        return {
            "ok": proc.returncode == 0,
            "exit_code": proc.returncode,
            "stdout": proc.stdout,
            "stderr": proc.stderr,
            "duration_sec": round(time.time() - started, 3),
            "timeout": False,
        }
    except subprocess.TimeoutExpired as exc:
        return {
            "ok": False,
            "exit_code": None,
            "stdout": exc.stdout or "",
            "stderr": exc.stderr or "",
            "duration_sec": round(time.time() - started, 3),
            "timeout": True,
        }


def run_compile(
    command: str,
    project_path: Path,
    timeout_sec: int,
    compile_mode: str,
    parallels_vm: str | None,
    parallels_project_path: str | None,
    parallels_shell: str,
    parallels_user: str | None,
    parallels_password_env: str | None,
) -> dict[str, Any]:
    if compile_mode == "local":
        return run_shell(command, project_path, timeout_sec)

    if not parallels_vm:
        raise ValueError("--parallels-vm is required when --compile-mode parallels")

    guest_path = resolve_parallels_project_path(project_path, parallels_project_path)
    return run_compile_in_parallels(
        command=command,
        timeout_sec=timeout_sec,
        vm=parallels_vm,
        project_path_guest=guest_path,
        shell_name=parallels_shell,
        user=parallels_user,
        password_env=parallels_password_env,
    )


def parse_ollama_think_mode(value: str) -> bool | None:
    normalized = value.strip().lower()
    if normalized == "auto":
        return None
    if normalized == "true":
        return True
    if normalized == "false":
        return False
    raise ValueError(f"Invalid --ollama-think value: {value}")


def normalize_chat_content(content: Any) -> str:
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts: list[str] = []
        for item in content:
            if isinstance(item, str):
                parts.append(item)
                continue
            if not isinstance(item, dict):
                continue
            text = item.get("text")
            if isinstance(text, str):
                parts.append(text)
                continue
            for key in ("content", "value"):
                value = item.get(key)
                if isinstance(value, str):
                    parts.append(value)
                    break
        return "\n".join(parts).strip()
    if isinstance(content, dict):
        for key in ("text", "content", "value"):
            value = content.get(key)
            if isinstance(value, str):
                return value
    return str(content) if content is not None else ""


def extract_openwebui_response_text(parsed: Any) -> str:
    if not isinstance(parsed, dict):
        return ""

    # OpenAI-compatible shape: choices[0].message.content
    choices = parsed.get("choices")
    if isinstance(choices, list) and choices:
        first = choices[0]
        if isinstance(first, dict):
            message = first.get("message")
            if isinstance(message, dict):
                return normalize_chat_content(message.get("content")).strip()

    # Fallback shapes seen across OSS chat APIs.
    for key in ("response", "content", "message"):
        value = parsed.get(key)
        text = normalize_chat_content(value).strip()
        if text:
            return text
    return ""


def build_openwebui_files(
    collection_ids: list[str] | None,
    file_ids: list[str] | None,
) -> list[dict[str, str]]:
    files: list[dict[str, str]] = []
    for collection_id in collection_ids or []:
        cid = collection_id.strip()
        if cid:
            files.append({"type": "collection", "id": cid})
    for file_id in file_ids or []:
        fid = file_id.strip()
        if fid:
            files.append({"type": "file", "id": fid})
    return files


def ollama_cli_supports_think_error(stderr: str) -> bool:
    normalized = stderr.lower()
    return "--think" in normalized and "unknown flag" in normalized


def run_openwebui_chat(
    model: str,
    prompt: str,
    timeout_sec: int,
    openwebui_url: str,
    api_key: str,
    files: list[dict[str, str]] | None = None,
    think: bool | None = None,
) -> dict[str, Any]:
    started = time.time()
    url = openwebui_url.rstrip("/") + "/api/chat/completions"
    payload: dict[str, Any] = {
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "stream": False,
    }
    if think is not None:
        payload["think"] = think
    if files:
        payload["files"] = files

    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout_sec) as resp:
            body = resp.read().decode("utf-8", errors="replace")
        parsed = json.loads(body)
        if isinstance(parsed, dict) and parsed.get("error"):
            return {
                "ok": False,
                "exit_code": None,
                "response": "",
                "stderr": str(parsed.get("error")),
                "duration_sec": round(time.time() - started, 3),
                "timeout": False,
            }

        response_text = extract_openwebui_response_text(parsed)
        return {
            "ok": True,
            "exit_code": 0,
            "response": response_text,
            "stderr": "",
            "duration_sec": round(time.time() - started, 3),
            "timeout": False,
        }
    except urllib.error.HTTPError as exc:
        try:
            err = exc.read().decode("utf-8", errors="replace")
        except Exception:
            err = str(exc)
        return {
            "ok": False,
            "exit_code": exc.code,
            "response": "",
            "stderr": err,
            "duration_sec": round(time.time() - started, 3),
            "timeout": False,
        }
    except TimeoutError:
        return {
            "ok": False,
            "exit_code": None,
            "response": "",
            "stderr": "openwebui HTTP request timed out",
            "duration_sec": round(time.time() - started, 3),
            "timeout": True,
        }
    except urllib.error.URLError as exc:
        return {
            "ok": False,
            "exit_code": None,
            "response": "",
            "stderr": str(exc.reason),
            "duration_sec": round(time.time() - started, 3),
            "timeout": False,
        }


def run_ollama_cli(
    model: str,
    prompt: str,
    timeout_sec: int,
    ollama_host: str,
    think: bool | None = None,
) -> dict[str, Any]:
    started = time.time()
    env = os.environ.copy()
    env["OLLAMA_HOST"] = ollama_host
    cmd = ["ollama", "run", model]
    if think is not None:
        cmd.append(f"--think={'true' if think else 'false'}")
    cmd.append(prompt)
    try:
        proc = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout_sec,
            check=False,
            env=env,
        )
        return {
            "ok": proc.returncode == 0,
            "exit_code": proc.returncode,
            "response": proc.stdout,
            "stderr": ANSI_ESCAPE_RE.sub("", proc.stderr),
            "duration_sec": round(time.time() - started, 3),
            "timeout": False,
        }
    except subprocess.TimeoutExpired as exc:
        return {
            "ok": False,
            "exit_code": None,
            "response": exc.stdout or "",
            "stderr": ANSI_ESCAPE_RE.sub("", exc.stderr or ""),
            "duration_sec": round(time.time() - started, 3),
            "timeout": True,
        }
    except FileNotFoundError:
        return {
            "ok": False,
            "exit_code": None,
            "response": "",
            "stderr": "ollama CLI not found in PATH",
            "duration_sec": round(time.time() - started, 3),
            "timeout": False,
        }


def run_ollama_http(
    model: str,
    prompt: str,
    timeout_sec: int,
    ollama_host: str,
    think: bool | None = None,
) -> dict[str, Any]:
    started = time.time()
    url = ollama_host.rstrip("/") + "/api/generate"
    payload = {
        "model": model,
        "prompt": prompt,
        "stream": False,
    }
    if think is not None:
        payload["think"] = think
    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout_sec) as resp:
            body = resp.read().decode("utf-8", errors="replace")
        parsed = json.loads(body)
        if isinstance(parsed, dict) and parsed.get("error"):
            return {
                "ok": False,
                "exit_code": None,
                "response": "",
                "stderr": str(parsed.get("error")),
                "duration_sec": round(time.time() - started, 3),
                "timeout": False,
            }
        response_text = str(parsed.get("response", "")) if isinstance(parsed, dict) else body
        return {
            "ok": True,
            "exit_code": 0,
            "response": response_text,
            "stderr": "",
            "duration_sec": round(time.time() - started, 3),
            "timeout": False,
        }
    except urllib.error.HTTPError as exc:
        try:
            err = exc.read().decode("utf-8", errors="replace")
        except Exception:
            err = str(exc)
        return {
            "ok": False,
            "exit_code": exc.code,
            "response": "",
            "stderr": err,
            "duration_sec": round(time.time() - started, 3),
            "timeout": False,
        }
    except TimeoutError:
        return {
            "ok": False,
            "exit_code": None,
            "response": "",
            "stderr": "ollama HTTP request timed out",
            "duration_sec": round(time.time() - started, 3),
            "timeout": True,
        }
    except urllib.error.URLError as exc:
        return {
            "ok": False,
            "exit_code": None,
            "response": "",
            "stderr": str(exc.reason),
            "duration_sec": round(time.time() - started, 3),
            "timeout": False,
        }


def run_ollama(
    model: str,
    prompt: str,
    timeout_sec: int,
    ollama_host: str,
    ollama_mode: str,
    ollama_think: str = "auto",
) -> dict[str, Any]:
    think = parse_ollama_think_mode(ollama_think)
    if ollama_mode == "http":
        return run_ollama_http(model, prompt, timeout_sec, ollama_host, think)

    if ollama_mode == "cli":
        return run_ollama_cli(model, prompt, timeout_sec, ollama_host, think)

    # auto mode
    if shutil.which("ollama"):
        cli_result = run_ollama_cli(model, prompt, timeout_sec, ollama_host, think)
        if think is not None and not cli_result.get("ok"):
            if ollama_cli_supports_think_error(str(cli_result.get("stderr", ""))):
                http_result = run_ollama_http(model, prompt, timeout_sec, ollama_host, think)
                if http_result.get("ok"):
                    http_result["stderr"] = (
                        str(http_result.get("stderr", ""))
                        + "\n[ollama-auto-fallback] local CLI lacks --think; used HTTP API."
                    ).strip()
                return http_result
        return cli_result
    return run_ollama_http(model, prompt, timeout_sec, ollama_host, think)


def run_generation(
    *,
    backend: str,
    model: str,
    prompt: str,
    timeout_sec: int,
    ollama_host: str,
    ollama_mode: str,
    ollama_think: str,
    openwebui_url: str,
    openwebui_api_key_env: str,
    openwebui_think: str = "auto",
    openwebui_files: list[dict[str, str]] | None = None,
) -> dict[str, Any]:
    if backend == "openwebui":
        think = parse_ollama_think_mode(openwebui_think)
        api_key = os.getenv(openwebui_api_key_env, "").strip()
        if not api_key:
            return {
                "ok": False,
                "exit_code": None,
                "response": "",
                "stderr": (
                    f"Environment variable {openwebui_api_key_env!r} is not set "
                    "for Open WebUI API authentication."
                ),
                "duration_sec": 0.0,
                "timeout": False,
            }
        return run_openwebui_chat(
            model=model,
            prompt=prompt,
            timeout_sec=timeout_sec,
            openwebui_url=openwebui_url,
            api_key=api_key,
            files=openwebui_files,
            think=think,
        )

    return run_ollama(
        model=model,
        prompt=prompt,
        timeout_sec=timeout_sec,
        ollama_host=ollama_host,
        ollama_mode=ollama_mode,
        ollama_think=ollama_think,
    )


def extract_generated_text(response: str, mode: str) -> str:
    cleaned = THINK_BLOCK_RE.sub("", response)
    cleaned = THINK_TAG_RE.sub("", cleaned).strip()

    if mode == "raw":
        return trim_to_code_region(cleaned)

    fenced = re.search(r"```[^\n]*\n(.*?)```", cleaned, flags=re.DOTALL)
    if fenced:
        cleaned = fenced.group(1).strip()

    return trim_to_code_region(cleaned)


def trim_to_code_region(text: str) -> str:
    text = text.replace("\r\n", "\n").strip()
    if not text:
        return text

    code_start_patterns = [
        r"^\s*schema\b",
        r'^\s*jadeVersion\b',
        r"^\s*localeDefinitions\b",
        r"^\s*typeSources\b",
        r"^\s*jadeMethodSources\b",
        r"^\s*jadeMethodDefinitions\b",
        r"^\s*[A-Za-z_]\w*\s*$",
        r"^\s*begin\b",
        r"^\s*vars\b",
        r"^\s*return\b",
        r"^\s*if\b",
        r"^\s*foreach\b",
        r"^\s*for\b",
    ]
    starts: list[int] = []
    for pattern in code_start_patterns:
        match = re.search(pattern, text, flags=re.IGNORECASE | re.MULTILINE)
        if match:
            starts.append(match.start())
    if starts:
        text = text[min(starts) :].lstrip()

    return text.strip()


def maybe_apply_generated(
    project_path: Path, task: dict[str, Any], ollama_result: dict[str, Any] | None
) -> dict[str, Any]:
    if task["output_path"] is None:
        return {"applied": False, "reason": "task has no output_path", "target_file": None}
    if ollama_result is None or not ollama_result["ok"]:
        return {"applied": False, "reason": "no successful model output", "target_file": None}

    rel_path = task["output_path"]
    target_file = (project_path / rel_path).resolve()
    if project_path not in target_file.parents and target_file != project_path:
        raise ValueError(f"Task output_path escapes project directory: {rel_path}")
    target_file.parent.mkdir(parents=True, exist_ok=True)
    generated = extract_generated_text(ollama_result["response"], task["extract"])
    target_file.write_text(generated + "\n", encoding="utf-8")
    return {"applied": True, "reason": "generated content written", "target_file": str(target_file)}


def render_compile_command(
    compile_cmd_template: str,
    project_path: Path,
    task: dict[str, Any],
    apply_result: dict[str, Any],
) -> str:
    task_output_path = task["output_path"] or ""
    generated_target_file = apply_result.get("target_file") or ""
    return (
        compile_cmd_template.replace("{task_output_path}", task_output_path)
        .replace("{generated_target_file}", generated_target_file)
        .replace("{project_path}", str(project_path))
    )


def snapshot_original(project_path: Path, output_path: str | None) -> dict[str, Any] | None:
    if output_path is None:
        return None
    target_file = (project_path / output_path).resolve()
    existed = target_file.exists()
    content = target_file.read_bytes() if existed else None
    return {"path": target_file, "existed": existed, "content": content}


def restore_original(snapshot: dict[str, Any] | None) -> None:
    if snapshot is None:
        return
    path = snapshot["path"]
    if snapshot["existed"]:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(snapshot["content"])
    else:
        if path.exists():
            path.unlink()


def main() -> int:
    args = parse_args()

    project_path = Path(args.project_path).resolve()
    tasks_path = Path(args.tasks_file).resolve()

    if not project_path.exists():
        raise FileNotFoundError(f"Project path does not exist: {project_path}")
    if not tasks_path.exists():
        raise FileNotFoundError(f"Tasks file does not exist: {tasks_path}")

    compile_cmd = args.compile_cmd
    if not compile_cmd and args.compile_mode == "local":
        compile_cmd = detect_compile_cmd(project_path)
    if not compile_cmd:
        raise ValueError(
            "Could not determine compile command. Pass --compile-cmd explicitly."
        )

    tasks = load_tasks(tasks_path)
    openwebui_files = build_openwebui_files(
        args.openwebui_collection_id,
        args.openwebui_file_id,
    )
    logs_dir = Path("logs").resolve()
    logs_dir.mkdir(parents=True, exist_ok=True)

    if args.output:
        output_path = Path(args.output).resolve()
        output_path.parent.mkdir(parents=True, exist_ok=True)
    else:
        stamp = dt.datetime.now().strftime("%Y%m%d-%H%M%S")
        output_path = logs_dir / f"eval-{stamp}.jsonl"

    run_meta = {
        "started_at": dt.datetime.now(dt.timezone.utc).isoformat(),
        "project_path": str(project_path),
        "compile_cmd": compile_cmd,
        "compile_mode": args.compile_mode,
        "tasks_file": str(tasks_path),
        "models": args.models,
        "llm_backend": args.llm_backend,
        "skip_ollama": args.skip_ollama,
        "ollama_host": args.ollama_host,
        "ollama_mode": args.ollama_mode,
        "ollama_think": args.ollama_think,
        "openwebui_url": args.openwebui_url,
        "openwebui_api_key_env": args.openwebui_api_key_env,
        "openwebui_files": openwebui_files,
        "apply_generated": args.apply_generated,
        "keep_generated": args.keep_generated,
        "parallels_vm": args.parallels_vm,
        "parallels_project_path": args.parallels_project_path,
        "parallels_shell": args.parallels_shell,
    }
    print(json.dumps({"type": "run_start", **run_meta}))

    with output_path.open("w", encoding="utf-8") as out:
        out.write(json.dumps({"type": "run_start", **run_meta}) + "\n")
        for model in args.models:
            for task in tasks:
                snapshot = snapshot_original(project_path, task["output_path"])
                generation_result: dict[str, Any] | None = None
                if not args.skip_ollama and task["prompt"]:
                    generation_result = run_generation(
                        backend=args.llm_backend,
                        model=model,
                        prompt=task["prompt"],
                        timeout_sec=args.timeout_sec,
                        ollama_host=args.ollama_host,
                        ollama_mode=args.ollama_mode,
                        ollama_think=args.ollama_think,
                        openwebui_url=args.openwebui_url,
                        openwebui_api_key_env=args.openwebui_api_key_env,
                        openwebui_think=args.ollama_think,
                        openwebui_files=openwebui_files,
                    )

                apply_result = {"applied": False, "reason": "disabled", "target_file": None}
                try:
                    if args.apply_generated:
                        apply_result = maybe_apply_generated(project_path, task, generation_result)

                    compile_cmd_rendered = render_compile_command(
                        compile_cmd_template=compile_cmd,
                        project_path=project_path,
                        task=task,
                        apply_result=apply_result,
                    )
                    compile_result = run_compile(
                        command=compile_cmd_rendered,
                        project_path=project_path,
                        timeout_sec=args.timeout_sec,
                        compile_mode=args.compile_mode,
                        parallels_vm=args.parallels_vm,
                        parallels_project_path=args.parallels_project_path,
                        parallels_shell=args.parallels_shell,
                        parallels_user=args.parallels_user,
                        parallels_password_env=args.parallels_password_env,
                    )
                    record = {
                        "type": "eval_result",
                        "timestamp_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
                        "model": model,
                        "task_id": task["id"],
                        "llm_backend": args.llm_backend,
                        "ollama_host": args.ollama_host,
                        "ollama_mode": args.ollama_mode,
                        "ollama_think": args.ollama_think,
                        "openwebui_url": args.openwebui_url,
                        "openwebui_files_count": len(openwebui_files),
                        "compile_mode": args.compile_mode,
                        "task_output_path": task["output_path"],
                        "task_extract": task["extract"],
                        "compile_cmd": compile_cmd_rendered,
                        "compile_ok": compile_result["ok"],
                        "compile_exit_code": compile_result["exit_code"],
                        "compile_timeout": compile_result["timeout"],
                        "compile_duration_sec": compile_result["duration_sec"],
                        "compile_stdout_tail": compile_result["stdout"][-4000:],
                        "compile_stderr_tail": compile_result["stderr"][-4000:],
                        "generated_applied": apply_result["applied"],
                        "generated_apply_reason": apply_result["reason"],
                        "generated_target_file": apply_result["target_file"],
                        "ollama_ok": None
                        if generation_result is None
                        else generation_result["ok"],
                        "ollama_exit_code": None
                        if generation_result is None
                        else generation_result["exit_code"],
                        "ollama_timeout": None
                        if generation_result is None
                        else generation_result["timeout"],
                        "ollama_duration_sec": None
                        if generation_result is None
                        else generation_result["duration_sec"],
                        "ollama_response_tail": None
                        if generation_result is None
                        else generation_result["response"][-4000:],
                        "ollama_stderr_tail": None
                        if generation_result is None
                        else generation_result["stderr"][-4000:],
                    }
                    out.write(json.dumps(record) + "\n")
                    print(
                        json.dumps(
                            {
                                "model": model,
                                "task_id": task["id"],
                                "compile_ok": record["compile_ok"],
                                "ollama_ok": record["ollama_ok"],
                                "generated_applied": record["generated_applied"],
                            }
                        )
                    )
                finally:
                    if not args.keep_generated:
                        restore_original(snapshot)

    print(json.dumps({"type": "run_end", "output": str(output_path)}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

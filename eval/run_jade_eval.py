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
import subprocess
import time
from pathlib import Path
from typing import Any

ANSI_ESCAPE_RE = re.compile(r"\x1B\[[0-?]*[ -/]*[@-~]")
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


def run_ollama(model: str, prompt: str, timeout_sec: int, ollama_host: str) -> dict[str, Any]:
    started = time.time()
    env = os.environ.copy()
    env["OLLAMA_HOST"] = ollama_host
    try:
        proc = subprocess.run(
            ["ollama", "run", model, prompt],
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


def extract_generated_text(response: str, mode: str) -> str:
    if mode == "raw":
        return response.strip()
    fenced = re.search(r"```[^\n]*\n(.*?)```", response, flags=re.DOTALL)
    if fenced:
        return fenced.group(1).strip()
    return response.strip()


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

    compile_cmd = args.compile_cmd or detect_compile_cmd(project_path)
    if not compile_cmd:
        raise ValueError(
            "Could not auto-detect a compile command. Pass --compile-cmd explicitly."
        )

    tasks = load_tasks(tasks_path)
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
        "tasks_file": str(tasks_path),
        "models": args.models,
        "skip_ollama": args.skip_ollama,
        "ollama_host": args.ollama_host,
        "apply_generated": args.apply_generated,
        "keep_generated": args.keep_generated,
    }
    print(json.dumps({"type": "run_start", **run_meta}))

    with output_path.open("w", encoding="utf-8") as out:
        out.write(json.dumps({"type": "run_start", **run_meta}) + "\n")
        for model in args.models:
            for task in tasks:
                snapshot = snapshot_original(project_path, task["output_path"])
                ollama_result: dict[str, Any] | None = None
                if not args.skip_ollama and task["prompt"]:
                    ollama_result = run_ollama(
                        model, task["prompt"], args.timeout_sec, args.ollama_host
                    )

                apply_result = {"applied": False, "reason": "disabled", "target_file": None}
                try:
                    if args.apply_generated:
                        apply_result = maybe_apply_generated(project_path, task, ollama_result)

                    compile_result = run_shell(compile_cmd, project_path, args.timeout_sec)
                    record = {
                        "type": "eval_result",
                        "timestamp_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
                        "model": model,
                        "task_id": task["id"],
                        "ollama_host": args.ollama_host,
                        "task_output_path": task["output_path"],
                        "task_extract": task["extract"],
                        "compile_cmd": compile_cmd,
                        "compile_ok": compile_result["ok"],
                        "compile_exit_code": compile_result["exit_code"],
                        "compile_timeout": compile_result["timeout"],
                        "compile_duration_sec": compile_result["duration_sec"],
                        "compile_stdout_tail": compile_result["stdout"][-4000:],
                        "compile_stderr_tail": compile_result["stderr"][-4000:],
                        "generated_applied": apply_result["applied"],
                        "generated_apply_reason": apply_result["reason"],
                        "generated_target_file": apply_result["target_file"],
                        "ollama_ok": None if ollama_result is None else ollama_result["ok"],
                        "ollama_exit_code": None if ollama_result is None else ollama_result["exit_code"],
                        "ollama_timeout": None if ollama_result is None else ollama_result["timeout"],
                        "ollama_duration_sec": None
                        if ollama_result is None
                        else ollama_result["duration_sec"],
                        "ollama_response_tail": None
                        if ollama_result is None
                        else ollama_result["response"][-4000:],
                        "ollama_stderr_tail": None
                        if ollama_result is None
                        else ollama_result["stderr"][-4000:],
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

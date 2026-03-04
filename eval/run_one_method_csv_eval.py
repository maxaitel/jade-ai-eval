#!/usr/bin/env python3
"""Resumable evaluator for one-method JADE CSV task packs.

Workflow modes:
- generate: call Ollama for each task prompt and persist generated method code.
- evaluate: score generated code (signature checks + optional compile checks).
- all: generate then evaluate.

All progress is checkpointed to state.json after each task so interrupted runs
can be resumed with --resume.
"""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import hashlib
import json
import re
import shutil
from pathlib import Path
from typing import Any

import run_jade_eval as base_eval


DEFAULT_TASKS_CSV = "jade_one_method_eval_tasks_140.csv"
DEFAULT_RUN_DIR = "logs/one_method_csv_eval"
STATE_VERSION = 1
DEFAULT_COMPILE_INPUT_MODE = "wrapped_schema"
SCHEMA_WRAP_TEMPLATE = (
    Path(__file__).resolve().parent
    / "online_samples/JADE-Banking-Schema__BankingSchema__BankingModelSchema.scm"
)
TEMPLATE_DECLARATION_SENTINEL = "addTax(): Decimal number = 1001;"
TEMPLATE_CALL_SENTINEL = "write d.addTax();"
TEMPLATE_METHOD_SOURCE_RE = re.compile(
    r"addTax\s*\{\s*addTax\(\)\s*:\s*Decimal;\s*.*?\n\}",
    re.DOTALL,
)

TASK_ID_RE = re.compile(r"^[A-Za-z0-9_-]+$")
SIGNATURE_RE = re.compile(
    r"^\s*(?P<name>[A-Za-z_]\w*)\s*\((?P<params>.*)\)\s*->\s*(?P<return>[A-Za-z_]\w*)\s*$"
)
PARAM_RE = re.compile(r"^\s*(?P<name>[A-Za-z_]\w*)\s*:\s*(?P<type>[A-Za-z_]\w*)\s*$")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Run resumable evaluation on CSV one-method JADE tasks with per-task "
            "checkpointing and graph-ready outputs."
        )
    )
    parser.add_argument("--tasks-csv", default=DEFAULT_TASKS_CSV, help="Path to task CSV file")
    parser.add_argument(
        "--models",
        nargs="+",
        required=True,
        help="Ollama model names, e.g. qwen3.5:122b",
    )
    parser.add_argument(
        "--mode",
        choices=["generate", "evaluate", "all"],
        default="all",
        help="Pipeline stage to run",
    )
    parser.add_argument(
        "--run-dir",
        default=DEFAULT_RUN_DIR,
        help="Directory for checkpoints, outputs, and logs",
    )
    parser.add_argument(
        "--resume",
        action=argparse.BooleanOptionalAction,
        default=True,
        help="Resume from existing checkpoint state in --run-dir",
    )
    parser.add_argument(
        "--reset",
        action=argparse.BooleanOptionalAction,
        default=False,
        help="Delete --run-dir and start from scratch",
    )
    parser.add_argument(
        "--max-tasks",
        type=int,
        default=None,
        help="Optional limit for smoke tests",
    )

    parser.add_argument(
        "--ollama-host",
        default=base_eval.DEFAULT_OLLAMA_HOST,
        help="Ollama host URL",
    )
    parser.add_argument(
        "--ollama-mode",
        choices=["auto", "cli", "http"],
        default="auto",
        help="How to call Ollama",
    )
    parser.add_argument(
        "--extract",
        choices=["auto", "raw"],
        default="auto",
        help="Extraction mode for response text",
    )

    parser.add_argument("--project-path", default=".", help="Project root for compile commands")
    parser.add_argument(
        "--compile",
        action=argparse.BooleanOptionalAction,
        default=False,
        help="Enable compile checks during evaluate mode",
    )
    parser.add_argument(
        "--compile-cmd",
        default=None,
        help=(
            "Compile command template. Supports {task_output_path}, "
            "{generated_target_file}, {project_path}."
        ),
    )
    parser.add_argument(
        "--compile-input-mode",
        choices=["raw", "wrapped_schema"],
        default=DEFAULT_COMPILE_INPUT_MODE,
        help=(
            "Compile raw generated files or first wrap method output into a "
            "valid JADE schema harness."
        ),
    )
    parser.add_argument(
        "--compile-mode",
        choices=["local", "parallels"],
        default="local",
        help="Where to run compile command",
    )
    parser.add_argument(
        "--parallels-vm",
        default=None,
        help="Parallels VM name/ID (required when --compile-mode parallels)",
    )
    parser.add_argument(
        "--parallels-project-path",
        default=None,
        help="Project path inside Parallels guest",
    )
    parser.add_argument(
        "--parallels-shell",
        choices=["cmd", "powershell"],
        default="cmd",
        help="Shell inside Parallels guest",
    )
    parser.add_argument(
        "--parallels-user",
        default=None,
        help="Guest username for prlctl exec",
    )
    parser.add_argument(
        "--parallels-password-env",
        default=None,
        help="Env var name storing guest password",
    )
    parser.add_argument(
        "--timeout-sec",
        type=int,
        default=300,
        help="Timeout for ollama/compile calls",
    )

    return parser.parse_args()


def utc_now() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat()


def safe_model_dirname(model: str) -> str:
    return re.sub(r"[^A-Za-z0-9._-]+", "_", model)


def atomic_write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    tmp.replace(path)


def append_jsonl(path: Path, record: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(record) + "\n")


def load_tasks_csv(tasks_csv: Path, max_tasks: int | None) -> list[dict[str, str]]:
    tasks: list[dict[str, str]] = []
    with tasks_csv.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle)
        if not reader.fieldnames:
            raise ValueError(f"CSV has no header: {tasks_csv}")
        required = {"id", "prompt", "signature", "name", "category", "difficulty", "spec"}
        missing = sorted(required - set(reader.fieldnames))
        if missing:
            raise ValueError(f"CSV missing required columns: {', '.join(missing)}")

        for i, row in enumerate(reader, start=1):
            task_id = (row.get("id") or "").strip()
            if not task_id:
                raise ValueError(f"Row {i} has empty task id")
            if not TASK_ID_RE.match(task_id):
                raise ValueError(f"Row {i} has invalid task id: {task_id!r}")

            task = {
                "id": task_id,
                "category": (row.get("category") or "unknown").strip() or "unknown",
                "difficulty": (row.get("difficulty") or "unknown").strip() or "unknown",
                "name": (row.get("name") or "").strip(),
                "signature": (row.get("signature") or "").strip(),
                "spec": (row.get("spec") or "").strip(),
                "prompt": (row.get("prompt") or "").strip(),
            }
            tasks.append(task)
            if max_tasks is not None and len(tasks) >= max_tasks:
                break

    if not tasks:
        raise ValueError(f"No tasks loaded from {tasks_csv}")
    return tasks


def parse_signature(signature: str) -> dict[str, Any]:
    match = SIGNATURE_RE.match(signature)
    if not match:
        return {
            "parse_ok": False,
            "name": "",
            "return_type": "",
            "params": [],
        }

    raw_params = match.group("params").strip()
    params: list[dict[str, str]] = []
    if raw_params:
        for raw_param in raw_params.split(","):
            p_match = PARAM_RE.match(raw_param)
            if not p_match:
                return {
                    "parse_ok": False,
                    "name": match.group("name"),
                    "return_type": match.group("return"),
                    "params": [],
                }
            params.append(
                {
                    "name": p_match.group("name"),
                    "type": p_match.group("type"),
                }
            )

    return {
        "parse_ok": True,
        "name": match.group("name"),
        "return_type": match.group("return"),
        "params": params,
    }


def score_generated_code(task: dict[str, str], generated_code: str) -> dict[str, Any]:
    parsed = parse_signature(task["signature"])
    if not parsed["parse_ok"]:
        return {
            "signature_parse_ok": False,
            "method_name_match": False,
            "param_name_coverage": 0.0,
            "param_type_coverage": 0.0,
            "return_type_present": False,
            "has_return_keyword": False,
            "structural_pass": False,
        }

    expected_name = str(parsed["name"])
    expected_return_type = str(parsed["return_type"])
    expected_params = list(parsed["params"])

    code_lower = generated_code.lower()
    method_name_match = bool(re.search(rf"\b{re.escape(expected_name.lower())}\b", code_lower))

    total_params = len(expected_params)
    param_name_hits = 0
    param_type_hits = 0
    for param in expected_params:
        param_name = str(param["name"]).lower()
        param_type = str(param["type"]).lower()
        if re.search(rf"\b{re.escape(param_name)}\b", code_lower):
            param_name_hits += 1
        if re.search(rf"\b{re.escape(param_type)}\b", code_lower):
            param_type_hits += 1

    if total_params == 0:
        param_name_coverage = 1.0
        param_type_coverage = 1.0
    else:
        param_name_coverage = round(param_name_hits / total_params, 3)
        param_type_coverage = round(param_type_hits / total_params, 3)

    return_type_present = bool(
        re.search(rf"\b{re.escape(expected_return_type.lower())}\b", code_lower)
    )
    has_return_keyword = bool(re.search(r"\breturn\b", code_lower))

    structural_pass = (
        method_name_match
        and param_name_coverage == 1.0
        and return_type_present
        and has_return_keyword
    )

    return {
        "signature_parse_ok": True,
        "method_name_match": method_name_match,
        "param_name_coverage": param_name_coverage,
        "param_type_coverage": param_type_coverage,
        "return_type_present": return_type_present,
        "has_return_keyword": has_return_keyword,
        "structural_pass": structural_pass,
    }


def default_state(
    args: argparse.Namespace,
    tasks_csv_path: Path,
    tasks_count: int,
) -> dict[str, Any]:
    return {
        "version": STATE_VERSION,
        "created_at": utc_now(),
        "updated_at": utc_now(),
        "tasks_csv": str(tasks_csv_path),
        "models": list(args.models),
        "tasks_count": tasks_count,
        "current": None,
        "generated_done": {model: [] for model in args.models},
        "evaluated_done": {model: [] for model in args.models},
    }


def ensure_state_compatible(
    state: dict[str, Any],
    args: argparse.Namespace,
    tasks_csv_path: Path,
    tasks_count: int,
) -> None:
    if int(state.get("version", -1)) != STATE_VERSION:
        raise ValueError(
            "Incompatible checkpoint state version. Use --reset to start a fresh run."
        )

    if Path(state.get("tasks_csv", "")).resolve() != tasks_csv_path.resolve():
        raise ValueError(
            "Checkpoint tasks CSV does not match current --tasks-csv. Use --reset or --run-dir."
        )

    state_models = state.get("models", [])
    if list(state_models) != list(args.models):
        raise ValueError(
            "Checkpoint models do not match current --models. Use --reset or --run-dir."
        )

    if int(state.get("tasks_count", -1)) != tasks_count:
        raise ValueError(
            "Checkpoint task count does not match current CSV/max-tasks. Use --reset or --run-dir."
        )


def persist_state(state_path: Path, state: dict[str, Any]) -> None:
    state["updated_at"] = utc_now()
    atomic_write_json(state_path, state)


def snapshot_tasks(tasks: list[dict[str, str]], snapshot_path: Path) -> None:
    snapshot_path.parent.mkdir(parents=True, exist_ok=True)
    with snapshot_path.open("w", encoding="utf-8") as handle:
        for task in tasks:
            handle.write(json.dumps(task) + "\n")


def jsonl_to_csv(jsonl_path: Path, csv_path: Path) -> None:
    if not jsonl_path.exists():
        return

    rows: list[dict[str, Any]] = []
    columns: set[str] = set()
    with jsonl_path.open("r", encoding="utf-8") as handle:
        for line in handle:
            raw = line.strip()
            if not raw:
                continue
            row = json.loads(raw)
            rows.append(row)
            columns.update(row.keys())

    if not rows:
        return

    ordered = sorted(columns)
    csv_path.parent.mkdir(parents=True, exist_ok=True)
    with csv_path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=ordered)
        writer.writeheader()
        for row in rows:
            writer.writerow(row)


def signature_to_jade_declaration(signature: str, include_semicolon: bool = True) -> str:
    parsed = parse_signature(signature)
    if not parsed["parse_ok"]:
        raise ValueError(f"Cannot parse method signature: {signature}")

    params = list(parsed["params"])
    params_part = "; ".join(f"{p['name']} : {p['type']}" for p in params)
    if params_part:
        decl = f"{parsed['name']}({params_part}) : {parsed['return_type']}"
    else:
        decl = f"{parsed['name']}() : {parsed['return_type']}"
    return f"{decl};" if include_semicolon else decl


def write_wrapped_compile_schema(
    task: dict[str, str],
    generated_code: str,
    output_path: Path,
) -> Path:
    if not SCHEMA_WRAP_TEMPLATE.exists():
        raise FileNotFoundError(f"Schema wrapper template not found: {SCHEMA_WRAP_TEMPLATE}")

    template = SCHEMA_WRAP_TEMPLATE.read_text(encoding="utf-8-sig")
    if TEMPLATE_DECLARATION_SENTINEL not in template:
        raise ValueError("Schema template missing method declaration sentinel.")
    if TEMPLATE_CALL_SENTINEL not in template:
        raise ValueError("Schema template missing method-call sentinel.")

    identity_seed = (
        f"{task['id']}::{output_path.stem}::{utc_now()}::{generated_code}"
    ).encode("utf-8")
    suffix = hashlib.sha1(identity_seed).hexdigest()[:10].upper()
    schema_name = f"OM{task['id']}{suffix}"
    global_name = f"G{schema_name}"
    session_name = f"S{schema_name}"
    db_name = f"{schema_name}Db"

    # Isolate every compile payload into its own schema namespace so method-name
    # changes between tasks do not collide with previous loads.
    rendered = template
    substitutions = [
        ("GBankingModelSchema", global_name),
        ("SBankingModelSchema", session_name),
        ("BankingModelSchemaDb", db_name),
        ("BankingModelSchema", schema_name),
    ]
    for old, new in substitutions:
        rendered = re.sub(rf"\b{re.escape(old)}\b", new, rendered)

    # The command-file banner line can trigger name-change errors when we
    # synthesize per-task schema names; it is metadata and safe to drop.
    rendered_lines = rendered.splitlines()
    if rendered_lines and "JADE COMMAND FILE NAME" in rendered_lines[0]:
        rendered = "\n".join(rendered_lines[1:]) + "\n"

    declaration = signature_to_jade_declaration(task["signature"], include_semicolon=False)
    parsed = parse_signature(task["signature"])
    method_name = str(parsed["name"])

    source_payload = generated_code.rstrip()
    method_block = f"{method_name}\n{{\n{source_payload}\n}}\n"

    rendered = rendered.replace(
        TEMPLATE_DECLARATION_SENTINEL,
        f"{declaration};",
        1,
    )
    rendered = rendered.replace(TEMPLATE_CALL_SENTINEL, "write d.String;", 1)
    rendered, replaced = TEMPLATE_METHOD_SOURCE_RE.subn(method_block, rendered, count=1)
    if replaced != 1:
        raise ValueError("Schema template method source block replacement failed.")

    # Avoid class/method number collisions across repeated synthetic schema
    # loads by letting JADE assign IDs instead of forcing template IDs.
    rendered = re.sub(r",\s*number\s*=\s*\d+", "", rendered)
    rendered = re.sub(r"\s+number\s*=\s*\d+", "", rendered)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(rendered, encoding="utf-8")
    return output_path


def run_generate_phase(
    args: argparse.Namespace,
    tasks: list[dict[str, str]],
    run_dir: Path,
    state_path: Path,
    state: dict[str, Any],
) -> None:
    generated_dir = run_dir / "generated"
    generated_log = run_dir / "generated.jsonl"

    total = len(tasks)
    for model in args.models:
        done_set = set(state.get("generated_done", {}).get(model, []))
        done_count = len(done_set)

        for index, task in enumerate(tasks, start=1):
            task_id = task["id"]
            if task_id in done_set:
                continue

            state["current"] = {
                "phase": "generate",
                "model": model,
                "task_id": task_id,
                "task_index": index,
                "task_total": total,
            }
            persist_state(state_path, state)

            ollama_result = base_eval.run_ollama(
                model=model,
                prompt=task["prompt"],
                timeout_sec=args.timeout_sec,
                ollama_host=args.ollama_host,
                ollama_mode=args.ollama_mode,
            )
            generated_text = ""
            if ollama_result.get("ok"):
                generated_text = base_eval.extract_generated_text(
                    str(ollama_result.get("response", "")),
                    args.extract,
                )

            model_dir = generated_dir / safe_model_dirname(model)
            target_file = model_dir / f"{task_id}.jade"
            if generated_text:
                model_dir.mkdir(parents=True, exist_ok=True)
                target_file.write_text(generated_text.rstrip() + "\n", encoding="utf-8")

            record = {
                "type": "generated",
                "timestamp_utc": utc_now(),
                "model": model,
                "task_id": task_id,
                "task_category": task["category"],
                "task_difficulty": task["difficulty"],
                "task_name": task["name"],
                "task_signature": task["signature"],
                "generated_file": str(target_file),
                "generated_chars": len(generated_text),
                "ollama_ok": bool(ollama_result.get("ok")),
                "ollama_exit_code": ollama_result.get("exit_code"),
                "ollama_timeout": bool(ollama_result.get("timeout")),
                "ollama_duration_sec": ollama_result.get("duration_sec"),
                "ollama_stderr_tail": str(ollama_result.get("stderr", ""))[-2000:],
                "ollama_response_tail": str(ollama_result.get("response", ""))[-2000:],
            }
            append_jsonl(generated_log, record)

            done_set.add(task_id)
            done_count += 1
            state.setdefault("generated_done", {})[model] = sorted(done_set)
            state["current"] = {
                "phase": "generate",
                "model": model,
                "task_id": task_id,
                "task_index": index,
                "task_total": total,
                "status": "completed",
            }
            persist_state(state_path, state)

            print(
                json.dumps(
                    {
                        "phase": "generate",
                        "model": model,
                        "task_id": task_id,
                        "done": done_count,
                        "total": total,
                        "ollama_ok": record["ollama_ok"],
                    }
                )
            )

    jsonl_to_csv(generated_log, run_dir / "generated.csv")


def compute_compile_command(
    args: argparse.Namespace,
    project_path: Path,
    compile_input_file: Path,
) -> str:
    compile_cmd = args.compile_cmd
    if not compile_cmd and args.compile_mode == "local":
        compile_cmd = base_eval.detect_compile_cmd(project_path)
    if not compile_cmd:
        raise ValueError(
            "Compile checks requested but compile command is missing. Pass --compile-cmd."
        )

    try:
        rel_output = compile_input_file.resolve().relative_to(project_path.resolve())
        rel_output_str = str(rel_output)
    except ValueError:
        rel_output_str = str(compile_input_file.resolve())

    task_stub = {
        "output_path": rel_output_str,
    }
    apply_stub = {
        "target_file": str(compile_input_file.resolve()),
    }
    return base_eval.render_compile_command(
        compile_cmd_template=compile_cmd,
        project_path=project_path,
        task=task_stub,
        apply_result=apply_stub,
    )


def run_compile_with_vm_resume_retry(
    *,
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
    result = base_eval.run_compile(
        command=command,
        project_path=project_path,
        timeout_sec=timeout_sec,
        compile_mode=compile_mode,
        parallels_vm=parallels_vm,
        parallels_project_path=parallels_project_path,
        parallels_shell=parallels_shell,
        parallels_user=parallels_user,
        parallels_password_env=parallels_password_env,
    )
    if compile_mode != "parallels" or not parallels_vm or result.get("ok"):
        return result

    stderr_text = str(result.get("stderr", ""))
    paused_signature = 'in the "paused" state'
    if paused_signature.lower() not in stderr_text.lower():
        return result

    resume_cmd = f'prlctl resume "{parallels_vm}" || prlctl start "{parallels_vm}"'
    resume_result = base_eval.run_shell(
        command=resume_cmd,
        cwd=project_path,
        timeout_sec=min(timeout_sec, 60),
    )
    resume_note = (
        f"\n[auto-resume-attempt] ok={resume_result.get('ok')} "
        f"exit={resume_result.get('exit_code')}\n"
        f"{str(resume_result.get('stdout', ''))}{str(resume_result.get('stderr', ''))}"
    )

    retried = base_eval.run_compile(
        command=command,
        project_path=project_path,
        timeout_sec=timeout_sec,
        compile_mode=compile_mode,
        parallels_vm=parallels_vm,
        parallels_project_path=parallels_project_path,
        parallels_shell=parallels_shell,
        parallels_user=parallels_user,
        parallels_password_env=parallels_password_env,
    )
    retried["stderr"] = f"{str(retried.get('stderr', ''))}{resume_note}"
    return retried


def run_evaluate_phase(
    args: argparse.Namespace,
    tasks: list[dict[str, str]],
    run_dir: Path,
    project_path: Path,
    state_path: Path,
    state: dict[str, Any],
) -> None:
    generated_dir = run_dir / "generated"
    compile_payload_dir = run_dir / "compile_payload"
    results_log = run_dir / "results.jsonl"

    total = len(tasks)
    for model in args.models:
        model_dir = generated_dir / safe_model_dirname(model)
        done_set = set(state.get("evaluated_done", {}).get(model, []))
        done_count = len(done_set)

        for index, task in enumerate(tasks, start=1):
            task_id = task["id"]
            if task_id in done_set:
                continue

            state["current"] = {
                "phase": "evaluate",
                "model": model,
                "task_id": task_id,
                "task_index": index,
                "task_total": total,
            }
            persist_state(state_path, state)

            generated_file = model_dir / f"{task_id}.jade"
            if generated_file.exists():
                generated_code = generated_file.read_text(encoding="utf-8")
                generated_missing = False
            else:
                generated_code = ""
                generated_missing = True

            score = score_generated_code(task, generated_code)

            compile_ok: bool | None = None
            compile_exit_code: int | None = None
            compile_timeout: bool | None = None
            compile_duration_sec: float | None = None
            compile_stdout_tail = ""
            compile_stderr_tail = ""
            compile_cmd_rendered: str | None = None
            compile_input_file = generated_file
            compile_input_mode = args.compile_input_mode

            if args.compile and not generated_missing:
                if args.compile_input_mode == "wrapped_schema":
                    compile_input_file = (
                        compile_payload_dir / safe_model_dirname(model) / f"{task_id}.scm"
                    )
                    try:
                        write_wrapped_compile_schema(task, generated_code, compile_input_file)
                    except Exception as exc:  # pragma: no cover - defensive log path
                        compile_ok = False
                        compile_exit_code = None
                        compile_timeout = False
                        compile_duration_sec = 0.0
                        compile_stderr_tail = f"compile-wrapper-error: {exc}"
                else:
                    compile_input_file = generated_file

                if compile_ok is None:
                    compile_cmd_rendered = compute_compile_command(
                        args,
                        project_path,
                        compile_input_file,
                    )
                    compile_result = run_compile_with_vm_resume_retry(
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
                    compile_ok = bool(compile_result.get("ok"))
                    compile_exit_code = compile_result.get("exit_code")
                    compile_timeout = bool(compile_result.get("timeout"))
                    compile_duration_sec = compile_result.get("duration_sec")
                    compile_stdout_tail = str(compile_result.get("stdout", ""))[-2000:]
                    compile_stderr_tail = str(compile_result.get("stderr", ""))[-2000:]

            structural_pass = bool(score["structural_pass"])
            if generated_missing:
                overall_pass = False
            elif args.compile:
                overall_pass = structural_pass and bool(compile_ok)
            else:
                overall_pass = structural_pass

            record = {
                "type": "result",
                "timestamp_utc": utc_now(),
                "model": model,
                "task_id": task_id,
                "task_category": task["category"],
                "task_difficulty": task["difficulty"],
                "task_name": task["name"],
                "task_signature": task["signature"],
                "task_spec": task["spec"],
                "generated_file": str(generated_file),
                "generated_missing": generated_missing,
                "generated_chars": len(generated_code),
                "signature_parse_ok": bool(score["signature_parse_ok"]),
                "method_name_match": bool(score["method_name_match"]),
                "param_name_coverage": float(score["param_name_coverage"]),
                "param_type_coverage": float(score["param_type_coverage"]),
                "return_type_present": bool(score["return_type_present"]),
                "has_return_keyword": bool(score["has_return_keyword"]),
                "structural_pass": structural_pass,
                "compile_checked": bool(args.compile and not generated_missing),
                "compile_input_mode": compile_input_mode if args.compile else None,
                "compile_input_file": str(compile_input_file) if args.compile else None,
                "compile_cmd": compile_cmd_rendered,
                "compile_ok": compile_ok,
                "compile_exit_code": compile_exit_code,
                "compile_timeout": compile_timeout,
                "compile_duration_sec": compile_duration_sec,
                "compile_stdout_tail": compile_stdout_tail,
                "compile_stderr_tail": compile_stderr_tail,
                "overall_pass": overall_pass,
            }
            append_jsonl(results_log, record)

            done_set.add(task_id)
            done_count += 1
            state.setdefault("evaluated_done", {})[model] = sorted(done_set)
            state["current"] = {
                "phase": "evaluate",
                "model": model,
                "task_id": task_id,
                "task_index": index,
                "task_total": total,
                "status": "completed",
            }
            persist_state(state_path, state)

            print(
                json.dumps(
                    {
                        "phase": "evaluate",
                        "model": model,
                        "task_id": task_id,
                        "done": done_count,
                        "total": total,
                        "overall_pass": overall_pass,
                        "structural_pass": structural_pass,
                        "compile_ok": compile_ok,
                    }
                )
            )

    jsonl_to_csv(results_log, run_dir / "results.csv")


def build_summary(run_dir: Path) -> None:
    results_path = run_dir / "results.jsonl"
    if not results_path.exists():
        return

    totals_by_model: dict[str, dict[str, int]] = {}
    with results_path.open("r", encoding="utf-8") as handle:
        for line in handle:
            raw = line.strip()
            if not raw:
                continue
            row = json.loads(raw)
            model = str(row.get("model", "unknown"))
            stats = totals_by_model.setdefault(
                model,
                {
                    "count": 0,
                    "overall_pass": 0,
                    "structural_pass": 0,
                    "compile_ok": 0,
                    "compile_checked": 0,
                },
            )
            stats["count"] += 1
            if row.get("overall_pass"):
                stats["overall_pass"] += 1
            if row.get("structural_pass"):
                stats["structural_pass"] += 1
            if row.get("compile_checked"):
                stats["compile_checked"] += 1
                if row.get("compile_ok"):
                    stats["compile_ok"] += 1

    summary = {
        "generated_at": utc_now(),
        "models": {},
    }
    for model, stats in totals_by_model.items():
        count = max(stats["count"], 1)
        compile_checked = max(stats["compile_checked"], 1)
        summary["models"][model] = {
            **stats,
            "overall_pass_rate": round(stats["overall_pass"] / count, 4),
            "structural_pass_rate": round(stats["structural_pass"] / count, 4),
            "compile_pass_rate": round(stats["compile_ok"] / compile_checked, 4)
            if stats["compile_checked"]
            else None,
        }

    atomic_write_json(run_dir / "summary.json", summary)


def main() -> int:
    args = parse_args()

    tasks_csv_path = Path(args.tasks_csv).resolve()
    project_path = Path(args.project_path).resolve()
    run_dir = Path(args.run_dir).resolve()

    if not tasks_csv_path.exists():
        raise FileNotFoundError(f"Tasks CSV does not exist: {tasks_csv_path}")
    if not project_path.exists():
        raise FileNotFoundError(f"Project path does not exist: {project_path}")

    if args.reset and run_dir.exists():
        shutil.rmtree(run_dir)

    tasks = load_tasks_csv(tasks_csv_path, args.max_tasks)

    state_path = run_dir / "state.json"
    tasks_snapshot_path = run_dir / "tasks_snapshot.jsonl"

    run_dir.mkdir(parents=True, exist_ok=True)

    if state_path.exists():
        if not args.resume:
            raise ValueError(
                f"Checkpoint exists at {state_path}. Use --resume or pass --reset."
            )
        state = json.loads(state_path.read_text(encoding="utf-8"))
        ensure_state_compatible(state, args, tasks_csv_path, len(tasks))
    else:
        state = default_state(args, tasks_csv_path, len(tasks))
        persist_state(state_path, state)
        snapshot_tasks(tasks, tasks_snapshot_path)

    run_meta = {
        "type": "run_start",
        "timestamp_utc": utc_now(),
        "mode": args.mode,
        "run_dir": str(run_dir),
        "tasks_csv": str(tasks_csv_path),
        "tasks_count": len(tasks),
        "models": args.models,
        "resume": args.resume,
        "compile": args.compile,
        "compile_mode": args.compile_mode,
        "compile_input_mode": args.compile_input_mode,
        "ollama_host": args.ollama_host,
        "ollama_mode": args.ollama_mode,
    }
    append_jsonl(run_dir / "run_events.jsonl", run_meta)
    print(json.dumps(run_meta))

    if args.mode in {"generate", "all"}:
        run_generate_phase(args, tasks, run_dir, state_path, state)

    if args.mode in {"evaluate", "all"}:
        run_evaluate_phase(args, tasks, run_dir, project_path, state_path, state)

    build_summary(run_dir)
    state["current"] = None
    persist_state(state_path, state)

    run_end = {
        "type": "run_end",
        "timestamp_utc": utc_now(),
        "run_dir": str(run_dir),
        "results_jsonl": str(run_dir / "results.jsonl"),
        "summary_json": str(run_dir / "summary.json"),
    }
    append_jsonl(run_dir / "run_events.jsonl", run_end)
    print(json.dumps(run_end))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

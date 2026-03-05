#!/usr/bin/env python3
"""Apply saved OpenWebUI RAG profiles and run JADE CSV eval for each profile."""

from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any


def utc_now() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat()


def read_env_file(path: Path) -> None:
    if not path.exists():
        return
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key and key not in os.environ:
            os.environ[key] = value


def make_url(base: str, path: str, query: dict[str, str] | None = None) -> str:
    base_clean = base.rstrip("/")
    if query:
        return f"{base_clean}{path}?{urllib.parse.urlencode(query)}"
    return f"{base_clean}{path}"


class OpenWebUIClient:
    def __init__(self, base_url: str, api_key: str, timeout_sec: int = 60):
        self.base_url = base_url.rstrip("/")
        self.api_key = api_key
        self.timeout_sec = timeout_sec

    def _request(
        self,
        method: str,
        path: str,
        *,
        json_payload: Any | None = None,
        query: dict[str, str] | None = None,
    ) -> Any:
        url = make_url(self.base_url, path, query)
        headers = {"Authorization": f"Bearer {self.api_key}"}
        body = None
        if json_payload is not None:
            headers["Content-Type"] = "application/json"
            body = json.dumps(json_payload).encode("utf-8")
        req = urllib.request.Request(url, data=body, method=method, headers=headers)
        try:
            with urllib.request.urlopen(req, timeout=self.timeout_sec) as resp:
                raw = resp.read().decode("utf-8", errors="replace")
        except urllib.error.HTTPError as exc:
            detail = exc.read().decode("utf-8", errors="replace")
            raise RuntimeError(f"{method} {path} failed: HTTP {exc.code} {detail}") from exc
        return json.loads(raw) if raw else None

    def get_retrieval_config(self) -> dict[str, Any]:
        parsed = self._request("GET", "/api/v1/retrieval/config")
        if isinstance(parsed, dict):
            return parsed
        raise RuntimeError("Unexpected retrieval config response.")

    def update_retrieval_config(self, payload: dict[str, Any]) -> dict[str, Any]:
        parsed = self._request("POST", "/api/v1/retrieval/config/update", json_payload=payload)
        if isinstance(parsed, dict):
            return parsed
        raise RuntimeError("Unexpected retrieval update response.")


def normalize_restore_payload(cfg: dict[str, Any]) -> dict[str, Any]:
    return {
        "ENABLE_RAG_HYBRID_SEARCH": cfg.get("ENABLE_RAG_HYBRID_SEARCH"),
        "RELEVANCE_THRESHOLD": cfg.get("RELEVANCE_THRESHOLD"),
        "TOP_K": cfg.get("TOP_K"),
        "TOP_K_RERANKER": cfg.get("TOP_K_RERANKER"),
        "HYBRID_BM25_WEIGHT": cfg.get("HYBRID_BM25_WEIGHT"),
    }


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def load_summary(summary_path: Path, model: str) -> dict[str, Any]:
    if not summary_path.exists():
        return {}
    payload = load_json(summary_path)
    row = payload.get("models", {}).get(model)
    return row if isinstance(row, dict) else {}


def load_generated_stats(generated_jsonl: Path) -> dict[str, Any]:
    if not generated_jsonl.exists():
        return {
            "rows": 0,
            "nonempty": 0,
            "ollama_ok_count": 0,
            "ollama_timeout_count": 0,
            "avg_ollama_duration_sec": None,
        }
    rows = 0
    nonempty = 0
    ollama_ok_count = 0
    ollama_timeout_count = 0
    durations: list[float] = []
    for raw in generated_jsonl.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
        except json.JSONDecodeError:
            continue
        if not isinstance(obj, dict):
            continue
        rows += 1
        if int(obj.get("generated_chars") or 0) > 0:
            nonempty += 1
        if bool(obj.get("ollama_ok")):
            ollama_ok_count += 1
        if bool(obj.get("ollama_timeout")):
            ollama_timeout_count += 1
        durations.append(float(obj.get("ollama_duration_sec") or 0.0))
    avg = round(sum(durations) / len(durations), 3) if durations else None
    return {
        "rows": rows,
        "nonempty": nonempty,
        "ollama_ok_count": ollama_ok_count,
        "ollama_timeout_count": ollama_timeout_count,
        "avg_ollama_duration_sec": avg,
    }


def run_profile_eval(
    *,
    project_root: Path,
    run_dir: Path,
    model: str,
    tasks_csv: str,
    max_tasks: int | None,
    openwebui_url: str,
    openwebui_api_key_env: str,
    think: str,
    timeout_sec: int,
    file_ids: list[str],
    wall_timeout_sec: int,
) -> dict[str, Any]:
    cmd = [
        sys.executable,
        "eval/run_one_method_csv_eval.py",
        "--mode",
        "all",
        "--models",
        model,
        "--tasks-csv",
        tasks_csv,
        "--run-dir",
        str(run_dir),
        "--reset",
        "--llm-backend",
        "openwebui",
        "--openwebui-url",
        openwebui_url,
        "--openwebui-api-key-env",
        openwebui_api_key_env,
        "--ollama-think",
        think,
        "--timeout-sec",
        str(timeout_sec),
    ]
    if max_tasks is not None:
        cmd.extend(["--max-tasks", str(max_tasks)])
    for fid in file_ids:
        cmd.extend(["--openwebui-file-id", fid])

    started = dt.datetime.now(dt.timezone.utc)
    status = "ok"
    rc: int | None = None
    try:
        proc = subprocess.run(
            cmd,
            cwd=str(project_root),
            capture_output=True,
            text=True,
            timeout=wall_timeout_sec,
            check=False,
        )
        rc = proc.returncode
        if rc != 0:
            status = "nonzero_exit"
        stdout_tail = (proc.stdout or "")[-2000:]
        stderr_tail = (proc.stderr or "")[-2000:]
    except subprocess.TimeoutExpired as exc:
        status = "wall_timeout"
        stdout_tail = (exc.stdout or "")[-2000:]
        stderr_tail = (exc.stderr or "")[-2000:]
    wall_sec = round((dt.datetime.now(dt.timezone.utc) - started).total_seconds(), 3)

    summary = load_summary(run_dir / "summary.json", model)
    gen_stats = load_generated_stats(run_dir / "generated.jsonl")
    return {
        "status": status,
        "return_code": rc,
        "wall_sec": wall_sec,
        "run_dir": str(run_dir),
        "overall_pass_rate": summary.get("overall_pass_rate"),
        "structural_pass_rate": summary.get("structural_pass_rate"),
        "count": summary.get("count"),
        "generated_rows": gen_stats["rows"],
        "generated_nonempty": gen_stats["nonempty"],
        "ollama_ok_count": gen_stats["ollama_ok_count"],
        "ollama_timeout_count": gen_stats["ollama_timeout_count"],
        "avg_ollama_duration_sec": gen_stats["avg_ollama_duration_sec"],
        "stdout_tail": stdout_tail,
        "stderr_tail": stderr_tail,
    }


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Run eval for saved OpenWebUI RAG profiles against JADE CSV tasks."
    )
    parser.add_argument(
        "--profiles",
        default="eval/profiles/openwebui_jade_agent_profiles.json",
        help="Path to saved profile json.",
    )
    parser.add_argument("--env-file", default=".env.local")
    parser.add_argument("--run-root", default="logs/openwebui_saved_profiles_eval")
    parser.add_argument(
        "--report-dir",
        default="eval/reports",
        help="Commit-friendly summary output dir (outside logs).",
    )
    parser.add_argument(
        "--max-tasks",
        type=int,
        default=None,
        help="Optional task cap; default uses full CSV task set.",
    )
    parser.add_argument(
        "--wall-timeout-sec",
        type=int,
        default=7200,
        help="Per-profile hard timeout for the eval subprocess.",
    )
    args = parser.parse_args()

    project_root = Path.cwd()
    read_env_file(project_root / args.env_file)

    profile_path = (project_root / args.profiles).resolve()
    if not profile_path.exists():
        raise FileNotFoundError(f"Profiles file not found: {profile_path}")
    profile_data = load_json(profile_path)

    defaults = profile_data.get("defaults", {})
    model = str(defaults.get("model", "qwen3.5:9b"))
    tasks_csv = str(defaults.get("tasks_csv", "jade_one_method_eval_tasks_140.csv"))
    openwebui_url_env = str(defaults.get("openwebui_url_env", "OPENWEBUI_URL"))
    openwebui_api_key_env = str(defaults.get("openwebui_api_key_env", "OPENWEBUI_API_KEY"))

    openwebui_url = os.getenv(openwebui_url_env, "").strip()
    openwebui_key = os.getenv(openwebui_api_key_env, "").strip()
    if not openwebui_url or not openwebui_key:
        raise RuntimeError(
            f"Missing OpenWebUI credentials. Need env vars {openwebui_url_env} and {openwebui_api_key_env}."
        )

    profiles = profile_data.get("profiles", [])
    if not isinstance(profiles, list) or not profiles:
        raise RuntimeError("No profiles found in profiles json.")

    ts = dt.datetime.now().strftime("%Y%m%dT%H%M%S")
    run_root = (project_root / args.run_root / ts).resolve()
    report_dir = (project_root / args.report_dir).resolve()
    run_root.mkdir(parents=True, exist_ok=True)
    report_dir.mkdir(parents=True, exist_ok=True)

    client = OpenWebUIClient(openwebui_url, openwebui_key, timeout_sec=60)
    baseline_cfg = client.get_retrieval_config()
    restore_payload = normalize_restore_payload(baseline_cfg)

    consolidated: dict[str, Any] = {
        "created_at": utc_now(),
        "profiles_file": str(profile_path),
        "run_root": str(run_root),
        "model": model,
        "tasks_csv": tasks_csv,
        "max_tasks": args.max_tasks,
        "wall_timeout_sec": args.wall_timeout_sec,
        "baseline_retrieval_config": restore_payload,
        "results": [],
        "interrupted": False,
    }

    print(json.dumps({"phase": "start", "run_root": str(run_root), "profiles": len(profiles)}), flush=True)
    exit_code = 0
    try:
        for i, profile in enumerate(profiles, start=1):
            name = str(profile.get("name", f"profile_{i}"))
            think = str(profile.get("think", "false"))
            timeout_sec = int(profile.get("timeout_sec", 300))
            file_ids = [str(x) for x in profile.get("file_ids", [])]
            retrieval_cfg = profile.get("retrieval_config", {})
            if not isinstance(retrieval_cfg, dict):
                raise RuntimeError(f"Invalid retrieval_config for profile {name}")

            run_dir = run_root / name
            client.update_retrieval_config(retrieval_cfg)
            print(
                json.dumps(
                    {"phase": "profile_start", "index": i, "profile": name, "timestamp_utc": utc_now()}
                ),
                flush=True,
            )
            result = run_profile_eval(
                project_root=project_root,
                run_dir=run_dir,
                model=model,
                tasks_csv=tasks_csv,
                max_tasks=args.max_tasks,
                openwebui_url=openwebui_url,
                openwebui_api_key_env=openwebui_api_key_env,
                think=think,
                timeout_sec=timeout_sec,
                file_ids=file_ids,
                wall_timeout_sec=args.wall_timeout_sec,
            )
            row = {
                "name": name,
                "description": profile.get("description"),
                "think": think,
                "timeout_sec": timeout_sec,
                "file_ids": file_ids,
                "retrieval_config": retrieval_cfg,
                **result,
            }
            consolidated["results"].append(row)
            print(
                json.dumps(
                    {
                        "phase": "profile_done",
                        "profile": name,
                        "status": row["status"],
                        "overall_pass_rate": row["overall_pass_rate"],
                        "count": row["count"],
                        "generated_nonempty": row["generated_nonempty"],
                    }
                ),
                flush=True,
            )
    except KeyboardInterrupt:
        consolidated["interrupted"] = True
        consolidated["interrupted_at"] = utc_now()
        exit_code = 130
        print(json.dumps({"phase": "interrupted"}), flush=True)
    finally:
        client.update_retrieval_config(restore_payload)
        consolidated["restored_at"] = utc_now()
        consolidated["restored_retrieval_config"] = restore_payload

    result_path = run_root / "results.json"
    result_path.write_text(json.dumps(consolidated, indent=2) + "\n", encoding="utf-8")

    report_latest = report_dir / "openwebui_saved_profiles_eval_latest.json"
    report_versioned = report_dir / f"openwebui_saved_profiles_eval_{ts}.json"
    report_latest.write_text(json.dumps(consolidated, indent=2) + "\n", encoding="utf-8")
    report_versioned.write_text(json.dumps(consolidated, indent=2) + "\n", encoding="utf-8")

    print(
        json.dumps(
            {
                "phase": "complete",
                "results_file": str(result_path),
                "report_latest": str(report_latest),
                "report_versioned": str(report_versioned),
            }
        ),
        flush=True,
    )
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())

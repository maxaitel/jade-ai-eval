# JADE Language Ollama Eval Scaffold

Evaluate Ollama models on JADE (Jade Software language) code-generation tasks.

## Important note about "jade" in Python

`pip install jade` is **not** the JADE programming language toolchain. It is an unrelated
astronomy package ("Exoplanet evolution code").

This repo uses:
- Ollama for model inference.
- Your external JADE compiler/build command via `COMPILE_CMD`.
- Default remote Ollama host: `http://100.116.25.114:11434`.

## Setup

Linux/macOS:

```bash
./scripts/setup_venv.sh
```

Windows PowerShell:

```powershell
.\scripts\setup_venv.ps1
```

Linux/macOS manual:

```bash
python3 -m venv --clear .venv
. .venv/bin/activate
python -m pip install --upgrade pip
```

## What it does

- Loads tasks from JSONL.
- Runs each task against each model with `ollama run`.
- Optionally writes generated code to task-defined output files.
- Runs compile/build command and logs pass/fail.
- Restores original files between tasks by default (isolated task behavior).

## Run

Compile-only baseline:

```bash
make eval-compile COMPILE_CMD="your compile command" PROJECT=/path/to/project
```

Model + compile logging:

```bash
make eval-full MODELS="qwen3.5:122b" COMPILE_CMD="your compile command" PROJECT=/path/to/project
```

JADE code generation tasks (writes model output files before compiling):

```bash
make eval-jade \
  MODELS="qwen3.5:122b" \
  TASKS="eval/tasks.jade.jsonl" \
  PROJECT=/path/to/project \
  COMPILE_CMD="your jade compile/build command" \
  OLLAMA_HOST="http://100.116.25.114:11434" \
  APPLY=1
```

Set `KEEP=1` if you want generated files to remain after the run.

Windows PowerShell example (no `make` required):

```powershell
.\scripts\run_eval.ps1 `
  -Models "qwen3.5:122b" `
  -TasksFile "eval/tasks.jade.jsonl" `
  -ProjectPath "C:\path\to\jade\project" `
  -CompileCmd "your jade compile/build command" `
  -OllamaHost "http://100.116.25.114:11434" `
  -ApplyGenerated
```

## Task JSONL schema

One object per line:

```json
{"id":"task_1","prompt":"Task prompt","output_path":"relative/path.jade","extract":"auto"}
```

Fields:
- `id`: task identifier.
- `prompt`: prompt sent to the model.
- `output_path` (optional): file to write generated content before compile.
- `extract` (optional): `auto` (default; extracts first fenced block if present) or `raw`.

## Output

Logs are written to `logs/eval-<timestamp>.jsonl`.

Each result record includes:
- model and task IDs
- compile status (`compile_ok`, `compile_exit_code`, timeout, duration)
- compile stdout/stderr tails
- model call status/output tails
- generation-apply status (`generated_applied`, `generated_target_file`)

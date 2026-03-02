# JADE Language Ollama Eval Scaffold

Evaluate Ollama models on JADE (Jade Software language) code-generation tasks, then compile/load-check the generated schema using JADE tooling running inside a Parallels VM.

## Important note about `pip install jade`

`pip install jade` is **not** the JADE programming language toolchain. It is an unrelated astronomy package.

## Known working configuration (validated March 2, 2026)

- macOS host path: `/Users/maxaitel/Documents/school-projects/jade-ai-training/jade-ai`
- Parallels VM name: `Windows 11`
- Hosted Ollama: `http://100.116.25.114:11434`
- JADE binaries in VM: `C:\Jade2025\bin\`
- JADE system DB in VM: `C:\Jade2025\system`
- JADE ini in VM: `C:\Jade2025\system\jade.ini`

## Setup

Linux/macOS:

```bash
./scripts/setup_venv.sh
```

Windows PowerShell:

```powershell
.\scripts\setup_venv.ps1
```

Manual:

```bash
python3 -m venv --clear .venv
. .venv/bin/activate
python -m pip install --upgrade pip
```

## What the evaluator does

- Reads tasks from JSONL.
- Calls Ollama via CLI or HTTP API.
- Extracts generated code and writes to each task `output_path` when `--apply-generated` is enabled.
- Runs compile/load command per task (local shell or Parallels VM).
- Logs one JSON record per model/task with compile + model outputs.

## Compile command templating

`COMPILE_CMD`/`--compile-cmd` supports placeholders per task:

- `{task_output_path}`: relative task output file (for example `eval/generated/hard/DomainModel.scm`)
- `{generated_target_file}`: absolute host path of generated file (empty if not applied)
- `{project_path}`: absolute host project path

This is how we run real JADE loader checks against each generated file.

## Parallels mode behavior

- `--compile-mode parallels` runs compile command through `prlctl exec`.
- Default mapping for project path:
  - `/Users/<name>/...` -> `C:\Mac\Home\...`
  - `/Volumes/...` -> `C:\Mac\Volumes\...`
- Override with `--parallels-project-path` if your VM path is different.

## Real JADE compile/load command used

This command was validated in VM:

```text
C:\Jade2025\bin\jadloadb.exe path=C:\Jade2025\system ini=C:\Jade2025\system\jade.ini schemaFile={task_output_path} showProgress=false
```

## Run commands

### Quick model eval (Parallels + hosted Ollama)

```bash
make eval-jade-parallels \
  MODELS="qwen3.5:122b" \
  TASKS="eval/tasks.jade.jsonl" \
  PROJECT="/Users/maxaitel/Documents/school-projects/jade-ai-training/jade-ai" \
  COMPILE_CMD='C:\Jade2025\bin\jadloadb.exe path=C:\Jade2025\system ini=C:\Jade2025\system\jade.ini schemaFile={task_output_path} showProgress=false' \
  OLLAMA_HOST="http://100.116.25.114:11434" \
  OLLAMA_MODE="http" \
  PARALLELS_VM="Windows 11" \
  APPLY=1
```

Add `KEEP=1` to keep generated files.

### Harder task pack

```bash
python3 eval/run_jade_eval.py \
  --models qwen3.5:122b \
  --tasks-file eval/tasks.jade.hard.jsonl \
  --project-path /Users/maxaitel/Documents/school-projects/jade-ai-training/jade-ai \
  --compile-mode parallels \
  --parallels-vm "Windows 11" \
  --compile-cmd 'C:\Jade2025\bin\jadloadb.exe path=C:\Jade2025\system ini=C:\Jade2025\system\jade.ini schemaFile={task_output_path} showProgress=false' \
  --ollama-host http://100.116.25.114:11434 \
  --ollama-mode http \
  --apply-generated \
  --keep-generated
```

Hard task file: `eval/tasks.jade.hard.jsonl`

## Proving the harness catches compiler failures

Control task file: `eval/tasks.jade.compile_control.jsonl`

- `control_valid_schema` uses `eval/controls/valid_reportwriter.scm` (known valid JADE schema file).
- `control_invalid_schema` uses `eval/controls/invalid_schema.scm` (intentionally invalid).

Run:

```bash
python3 eval/run_jade_eval.py \
  --models qwen3.5:122b \
  --tasks-file eval/tasks.jade.compile_control.jsonl \
  --project-path /Users/maxaitel/Documents/school-projects/jade-ai-training/jade-ai \
  --compile-mode parallels \
  --parallels-vm "Windows 11" \
  --compile-cmd 'C:\Jade2025\bin\jadloadb.exe path=C:\Jade2025\system ini=C:\Jade2025\system\jade.ini schemaFile={task_output_path} showProgress=false' \
  --skip-ollama
```

Expected result:

- `control_valid_schema`: `compile_ok=true`
- `control_invalid_schema`: `compile_ok=false`

Validated log:

- `logs/eval-20260303-002512.jsonl`

## Example model output snippets (qwen3.5:122b)

From `logs/eval-20260303-000609.jsonl`:

```jade
class Customer {
    id: Integer
    firstName: String
    lastName: String

    fullName(): String {
        return firstName + " " + lastName
    }
}
```

```jade
class Order
    property subtotal: Decimal
    property taxRate: Decimal

    method total(): Decimal
        return subtotal + (subtotal * taxRate)
end class
```

## Files added for repeatability

- `eval/tasks.jade.hard.jsonl`
- `eval/tasks.jade.compile_control.jsonl`
- `eval/controls/invalid_schema.scm`
- `eval/controls/valid_reportwriter.scm`

## Output logs

Logs are written to `logs/eval-<timestamp>.jsonl` and include:

- model/task IDs
- rendered compile command
- compile status (`compile_ok`, `compile_exit_code`, timeout, duration)
- compile stdout/stderr tails
- model status/output tails
- generation apply metadata

## Troubleshooting

- If compile fails immediately with `INI file not found`, ensure `ini=C:\Jade2025\system\jade.ini` is present in `COMPILE_CMD`.
- If Parallels path mapping is wrong, pass `--parallels-project-path` explicitly.
- If local `ollama` CLI is not installed, force `--ollama-mode http`.
- If model calls hang, inspect hosted server with:

```bash
curl -s http://100.116.25.114:11434/api/ps
```

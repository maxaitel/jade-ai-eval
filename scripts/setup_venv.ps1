Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $RepoRoot

py -3 -m venv .venv --clear
.\.venv\Scripts\python.exe -m pip install --upgrade pip

Write-Host "Created .venv for evaluator tooling."
Write-Host "Note: JADE (Jade Software language) is proprietary and not installable via pip."
Write-Host "Use COMPILE_CMD to call your local JADE compiler/build tooling."


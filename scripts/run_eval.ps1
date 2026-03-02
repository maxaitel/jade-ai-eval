param(
    [Parameter(Mandatory = $false)]
    [string[]]$Models = @("qwen3.5:122b"),
    [Parameter(Mandatory = $false)]
    [string]$TasksFile = "eval/tasks.jade.jsonl",
    [Parameter(Mandatory = $false)]
    [string]$ProjectPath = ".",
    [Parameter(Mandatory = $false)]
    [string]$CompileCmd = "",
    [Parameter(Mandatory = $false)]
    [string]$OllamaHost = "http://100.116.25.114:11434",
    [Parameter(Mandatory = $false)]
    [ValidateSet("auto", "cli", "http")]
    [string]$OllamaMode = "auto",
    [Parameter(Mandatory = $false)]
    [ValidateSet("local", "parallels")]
    [string]$CompileMode = "local",
    [Parameter(Mandatory = $false)]
    [string]$ParallelsVm = "",
    [Parameter(Mandatory = $false)]
    [string]$ParallelsProjectPath = "",
    [Parameter(Mandatory = $false)]
    [ValidateSet("cmd", "powershell")]
    [string]$ParallelsShell = "cmd",
    [Parameter(Mandatory = $false)]
    [string]$ParallelsUser = "",
    [Parameter(Mandatory = $false)]
    [string]$ParallelsPasswordEnv = "",
    [Parameter(Mandatory = $false)]
    [int]$TimeoutSec = 300,
    [switch]$SkipOllama,
    [switch]$ApplyGenerated,
    [switch]$KeepGenerated
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $RepoRoot

$Python = Join-Path $RepoRoot ".venv\Scripts\python.exe"
if (-not (Test-Path $Python)) {
    throw ".venv not found. Run scripts\setup_venv.ps1 first."
}

$ArgsList = @(
    "eval/run_jade_eval.py",
    "--models"
)
$ArgsList += $Models
$ArgsList += @(
    "--tasks-file", $TasksFile,
    "--project-path", $ProjectPath,
    "--ollama-host", $OllamaHost,
    "--ollama-mode", $OllamaMode,
    "--compile-mode", $CompileMode,
    "--timeout-sec", "$TimeoutSec"
)

if ($CompileCmd -ne "") {
    $ArgsList += @("--compile-cmd", $CompileCmd)
}
if ($SkipOllama) {
    $ArgsList += "--skip-ollama"
}
if ($ApplyGenerated) {
    $ArgsList += "--apply-generated"
}
if ($KeepGenerated) {
    $ArgsList += "--keep-generated"
}
if ($ParallelsVm -ne "") {
    $ArgsList += @("--parallels-vm", $ParallelsVm)
}
if ($ParallelsProjectPath -ne "") {
    $ArgsList += @("--parallels-project-path", $ParallelsProjectPath)
}
if ($ParallelsShell -ne "") {
    $ArgsList += @("--parallels-shell", $ParallelsShell)
}
if ($ParallelsUser -ne "") {
    $ArgsList += @("--parallels-user", $ParallelsUser)
}
if ($ParallelsPasswordEnv -ne "") {
    $ArgsList += @("--parallels-password-env", $ParallelsPasswordEnv)
}

& $Python @ArgsList

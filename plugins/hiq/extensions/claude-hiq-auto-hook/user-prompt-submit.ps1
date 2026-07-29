$ErrorActionPreference = 'Stop'

$raw = [Console]::In.ReadToEnd()
if (-not $raw) { exit 0 }
try {
  $event = $raw | ConvertFrom-Json
} catch {
  exit 0
}

$cwd = [string]$event.cwd
$prompt = ([string]$event.prompt).Replace("`r", ' ').Replace("`n", ' ').Trim()
if ($prompt.Length -gt 400) { $prompt = $prompt.Substring(0, 400) }
if (-not $cwd) { exit 0 }
if (-not (Test-Path -LiteralPath (Join-Path $cwd 'AGENTS.md'))) { exit 0 }
if (-not (Test-Path -LiteralPath (Join-Path $cwd '.hiq\config.yaml'))) { exit 0 }

$homeDir = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
$hiqHome = if ($env:HIQ_HOME_DIR) { $env:HIQ_HOME_DIR } else { Join-Path $homeDir '.hiq' }
$hookCmd = Join-Path $hiqHome 'scripts\hiq-hook.cmd'
$activateCmd = Join-Path $hiqHome 'scripts\hiq-activate.cmd'
if (-not (Test-Path -LiteralPath $hookCmd)) { exit 0 }
if (-not (Test-Path -LiteralPath $activateCmd)) { exit 0 }

& $hookCmd $cwd 'pre-session' '--host=claude' '--adapter=claude' *> $null
& $activateCmd $cwd '--if-needed' '--mode=auto' "--goal-title=$prompt" "--goal-now=$prompt" "--acceptance=$prompt" '--owner=hiq-grill' '--phase=grill' '--next-skill=hiq-grill' '--next-step=clarify scope, confirm acceptance target, and choose the truthful next owner lane' '--host=claude' '--hook-adapter=claude' '--reason=Claude hook loaded the HiQ auto entry contract for this project turn' *> $null
exit 0

$ErrorActionPreference = 'Stop'

$raw = [Console]::In.ReadToEnd()
if (-not $raw) { exit 0 }
try {
  $event = $raw | ConvertFrom-Json
} catch {
  exit 0
}

$cwd = [string]$event.cwd
if (-not $cwd) { exit 0 }
if (-not (Test-Path -LiteralPath (Join-Path $cwd 'AGENTS.md'))) { exit 0 }
if (-not (Test-Path -LiteralPath (Join-Path $cwd '.hiq\config.yaml'))) { exit 0 }

$homeDir = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
$hiqHome = if ($env:HIQ_HOME_DIR) { $env:HIQ_HOME_DIR } else { Join-Path $homeDir '.hiq' }
$hookCmd = Join-Path $hiqHome 'scripts\hiq-hook.cmd'
if (-not (Test-Path -LiteralPath $hookCmd)) { exit 0 }
& $hookCmd $cwd 'pre-final' '--host=claude' '--adapter=claude' *> $null
exit 0

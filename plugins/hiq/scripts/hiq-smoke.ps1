param(
  [string]$SmokeRoot = "",
  [switch]$Keep
)

$ErrorActionPreference = "Stop"

function Fail([string]$Message) {
  Write-Error "hiq-smoke: FAIL - $Message"
  exit 1
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $scriptDir '..\..\..'))
if (-not $SmokeRoot) {
  $SmokeRoot = Join-Path $repoRoot 'tmp\hiq-smoke-project'
}

if (Test-Path -LiteralPath $SmokeRoot) {
  Remove-Item -LiteralPath $SmokeRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $SmokeRoot -Force | Out-Null

try {
  Write-Output "hiq-smoke: init-project root=$SmokeRoot"
  & (Join-Path $scriptDir 'init-project.ps1') $SmokeRoot | Out-Null

  $configText = Get-Content -LiteralPath (Join-Path $SmokeRoot '.hiq\config.yaml') -Raw
  if ($configText -notmatch 'entry_skill: hiq-auto') { Fail 'missing hiq-auto entry skill' }

  $current = Get-Content -LiteralPath (Join-Path $SmokeRoot '.hiq\current-change.json') -Raw | ConvertFrom-Json
  if ([string]$current.entrySkill -ne 'hiq-auto') { Fail 'missing entrySkill in current-change.json' }
  if ([string]$current.autoOwnerSkill -ne 'hiq-session') { Fail 'missing autoOwnerSkill in current-change.json' }
  if (-not ($current.PSObject.Properties.Name -contains 'goalId')) { Fail 'missing goalId in current-change.json' }
  if (-not ($current.PSObject.Properties.Name -contains 'goalPath')) { Fail 'missing goalPath in current-change.json' }

  $sessionText = Get-Content -LiteralPath (Join-Path $SmokeRoot '.hiq\session.md') -Raw
  if ($sessionText -notmatch '- \*\*entry_skill\*\*: `hiq-auto`') { Fail 'missing entry_skill in session.md' }
  if ($sessionText -notmatch '- \*\*auto_owner\*\*: `hiq-session`') { Fail 'missing auto_owner in session.md' }
  if ($sessionText -notmatch '- \*\*goal_record\*\*:') { Fail 'missing goal_record in session.md' }

  $statusOut = & (Join-Path $scriptDir 'hiq-status.ps1') $SmokeRoot | Out-String
  $doctorPre = & (Join-Path $scriptDir 'hiq-doctor.ps1') $SmokeRoot | Out-String
  if ($statusOut -notmatch 'session=ok') { Fail 'status did not report session=ok after init-project' }
  if ($statusOut -notmatch 'entry_skill=hiq-auto') { Fail 'status should report entry_skill=hiq-auto after init-project' }
  if ($statusOut -notmatch 'auto_owner=hiq-session') { Fail 'status should report auto_owner=hiq-session after init-project' }
  if ($doctorPre -notmatch 'runtime.codegraph_index=missing') { Fail 'doctor should report missing codegraph index before project-init' }
  if ($doctorPre -notmatch 'overall=partial') { Fail 'doctor should report overall=partial before project-init' }

  Write-Output "hiq-smoke: project-init root=$SmokeRoot"
  & (Join-Path $scriptDir 'codegraph-project-init.cmd') $SmokeRoot | Out-Null

  $doctorPost = & (Join-Path $scriptDir 'hiq-doctor.ps1') $SmokeRoot | Out-String
  if ($doctorPost -notmatch 'runtime.codegraph_index=ok') { Fail 'doctor should report codegraph index ok after project-init' }
  if ($doctorPost -notmatch 'overall=ok') { Fail 'doctor should report overall=ok after project-init' }

  $repoMcp = Get-Content -LiteralPath (Join-Path $SmokeRoot '.mcp.json') -Raw
  if ($repoMcp -notmatch '"command"\s*:\s*"\.hiq/tools/codegraph(\.cmd)?"') { Fail 'repo mcp should use project-relative codegraph launcher' }

  $liveagent = Get-Content -LiteralPath (Join-Path $SmokeRoot '.hiq\graph\mcp-liveagent.json') -Raw
  if ($liveagent -notmatch '"hiq_command_windows"\s*:\s*"\.hiq/tools/codegraph\.cmd"') { Fail 'liveagent snippet should document Windows launcher' }

  $previewOut = & (Join-Path $scriptDir 'install-skills.ps1') 'liveagent' '' 0 | Out-String
  if ($previewOut -notmatch 'skill=hiq-auto') { Fail 'install preview missing hiq-auto' }
  if ($previewOut -notmatch 'mode=preview') { Fail 'install preview did not stay in preview mode' }

  $dispatcherRoot = Join-Path $repoRoot 'tmp\hiq-dispatcher-smoke-project'
  $dispatcherWrong = Join-Path $repoRoot 'init-project'
  if (Test-Path -LiteralPath $dispatcherRoot) { Remove-Item -LiteralPath $dispatcherRoot -Recurse -Force }
  if (Test-Path -LiteralPath $dispatcherWrong) { Remove-Item -LiteralPath $dispatcherWrong -Recurse -Force }
  New-Item -ItemType Directory -Path $dispatcherRoot -Force | Out-Null
  & (Join-Path $scriptDir 'hiq-run.cmd') 'init-project' $dispatcherRoot | Out-Null
  if (-not (Test-Path -LiteralPath (Join-Path $dispatcherRoot '.hiq'))) { Fail 'dispatcher init-project did not create .hiq at requested root' }
  if (Test-Path -LiteralPath $dispatcherWrong) { Fail 'dispatcher created stray init-project path' }

  Write-Output 'smoke:'
  Write-Output '- Windows init-project surface: source-complete'
  Write-Output '- Windows project-init surface: source-complete'
  Write-Output '- install preview surface: source-complete'
  if ($Keep) {
    Write-Output "- kept project: $SmokeRoot"
  }
} finally {
  if (-not $Keep -and (Test-Path -LiteralPath $SmokeRoot)) {
    Remove-Item -LiteralPath $SmokeRoot -Recurse -Force
  }
  $dispatcherRoot = Join-Path $repoRoot 'tmp\hiq-dispatcher-smoke-project'
  if (Test-Path -LiteralPath $dispatcherRoot) {
    Remove-Item -LiteralPath $dispatcherRoot -Recurse -Force
  }
}

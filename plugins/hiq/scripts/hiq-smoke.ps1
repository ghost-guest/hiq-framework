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
  if (-not ($current.PSObject.Properties.Name -contains 'goalId')) { Fail 'missing goalId in current-change.json' }
  if (-not ($current.PSObject.Properties.Name -contains 'goalPath')) { Fail 'missing goalPath in current-change.json' }

  $sessionText = Get-Content -LiteralPath (Join-Path $SmokeRoot '.hiq\session.md') -Raw
  if ($sessionText -notmatch '- \*\*goal_record\*\*:') { Fail 'missing goal_record in session.md' }

  $statusOut = & (Join-Path $scriptDir 'hiq-status.ps1') $SmokeRoot | Out-String
  $doctorPre = & (Join-Path $scriptDir 'hiq-doctor.ps1') $SmokeRoot | Out-String
  if ($statusOut -notmatch 'session=ok') { Fail 'status did not report session=ok after init-project' }
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
}

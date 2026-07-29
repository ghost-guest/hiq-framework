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
$smokeHome = Join-Path $repoRoot 'tmp\hiq-smoke-home'
if (-not $SmokeRoot) {
  $SmokeRoot = Join-Path $repoRoot 'tmp\hiq-smoke-project'
}

if (Test-Path -LiteralPath $SmokeRoot) {
  Remove-Item -LiteralPath $SmokeRoot -Recurse -Force
}
if (Test-Path -LiteralPath $smokeHome) {
  Remove-Item -LiteralPath $smokeHome -Recurse -Force
}
New-Item -ItemType Directory -Path $SmokeRoot -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $smokeHome 'scripts') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $smokeHome 'bin') -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $scriptDir 'hiq-run.cmd') -Destination (Join-Path $smokeHome 'scripts') -Force
Copy-Item -LiteralPath (Join-Path $scriptDir 'hiq-status.cmd') -Destination (Join-Path $smokeHome 'scripts') -Force
Copy-Item -LiteralPath (Join-Path $scriptDir 'hiq-doctor.cmd') -Destination (Join-Path $smokeHome 'scripts') -Force
$env:HIQ_HOME_DIR = $smokeHome
$env:HIQ_BIN_DIR = Join-Path $smokeHome 'bin'

try {
  Write-Output "hiq-smoke: init-project root=$SmokeRoot"
  & (Join-Path $scriptDir 'init-project.ps1') $SmokeRoot | Out-Null

  $configText = Get-Content -LiteralPath (Join-Path $SmokeRoot '.hiq\config.yaml') -Raw
  if ($configText -notmatch 'schema: 2') { Fail 'config did not use schema 2' }
  if ($configText -notmatch 'host_automation_level.*instruction-only') { Fail 'config missing honest host automation level' }

  $current = Get-Content -LiteralPath (Join-Path $SmokeRoot '.hiq\current-change.json') -Raw | ConvertFrom-Json
  if ([string]$current.schema -ne '2') { Fail 'current-change.json did not use schema 2' }
  if ([string]$current.entrySkill -ne 'hiq-auto') { Fail 'missing entrySkill in current-change.json' }
  if ([string]$current.hostAutomationLevel -ne 'instruction-only') { Fail 'missing hostAutomationLevel in current-change.json' }
  if ([string]$current.autoStatus -ne 'available') { Fail 'fresh init must report autoStatus=available' }
  if ([string]$current.autoOwnerSkill -ne 'hiq-session') { Fail 'missing autoOwnerSkill in current-change.json' }
  if ([string]$current.reviewStatus -ne 'not-run') { Fail 'missing reviewStatus in current-change.json' }
  if ([string]$current.evalApplicability -ne 'not-applicable') { Fail 'missing eval applicability truth' }
  if (-not ($current.PSObject.Properties.Name -contains 'goalId')) { Fail 'missing goalId in current-change.json' }
  if (-not ($current.PSObject.Properties.Name -contains 'goalPath')) { Fail 'missing goalPath in current-change.json' }

  $sessionText = Get-Content -LiteralPath (Join-Path $SmokeRoot '.hiq\session.md') -Raw
  if ($sessionText -notmatch '- \*\*entry_skill\*\*: `hiq-auto`') { Fail 'missing entry_skill in session.md' }
  if ($sessionText -notmatch '- \*\*auto_owner\*\*: `hiq-session`') { Fail 'missing auto_owner in session.md' }
  if ($sessionText -notmatch '- \*\*goal_record\*\*:') { Fail 'missing goal_record in session.md' }

  $goalTemplate = Get-Content -LiteralPath (Join-Path $repoRoot 'plugins\hiq\references\templates\goal.md') -Raw
  if ($goalTemplate -notmatch 'accepted complete result') { Fail 'goal template missing accepted complete result field' }
  $grillTemplate = Get-Content -LiteralPath (Join-Path $repoRoot 'plugins\hiq\references\templates\grill.md') -Raw
  if ($grillTemplate -notmatch 'scope downgrade approved') { Fail 'grill template missing scope downgrade approval field' }
  if ($grillTemplate -notmatch 'plan updated\?') { Fail 'grill template missing post-decision plan update field' }
  $implementTemplate = Get-Content -LiteralPath (Join-Path $repoRoot 'plugins\hiq\references\templates\IMPLEMENT.md') -Raw
  if ($implementTemplate -notmatch 'scope_downgrade_approved') { Fail 'IMPLEMENT template missing scope downgrade approval metadata' }
  if ($implementTemplate -notmatch 'grill\.md` \(required before L1\+ product work\)') { Fail 'IMPLEMENT template missing grill-before-implement rule' }

  $statusOut = & (Join-Path $scriptDir 'hiq-status.ps1') $SmokeRoot | Out-String
  $doctorPre = & (Join-Path $scriptDir 'hiq-doctor.ps1') $SmokeRoot | Out-String
  if ($statusOut -notmatch 'session=ok') { Fail 'status did not report session=ok after init-project' }
  if ($statusOut -notmatch 'entry_skill=hiq-auto') { Fail 'status should report entry_skill=hiq-auto after init-project' }
  if ($statusOut -notmatch 'host_automation_level=instruction-only') { Fail 'status should report instruction-only host automation' }
  if ($statusOut -notmatch 'auto_status=available') { Fail 'status should report autoStatus=available before a real turn enters' }
  if ($statusOut -notmatch 'auto_owner=hiq-session') { Fail 'status should report auto_owner=hiq-session after init-project' }
  if ($statusOut -notmatch 'pointer_status=ok') { Fail 'status should report an aligned fresh pointer' }
  if ($doctorPre -notmatch 'runtime.codegraph_index=missing') { Fail 'doctor should report missing codegraph index before project-init' }
  if ($doctorPre -notmatch 'state.overall=ok') { Fail 'doctor should report semantic state healthy after init-project' }
  if ($doctorPre -notmatch 'overall=partial') { Fail 'doctor should report overall=partial before project-init' }

  Write-Output "hiq-smoke: project-init root=$SmokeRoot"
  & (Join-Path $scriptDir 'codegraph-project-init.cmd') $SmokeRoot | Out-Null

  $doctorPost = & (Join-Path $scriptDir 'hiq-doctor.ps1') $SmokeRoot | Out-String
  if ($doctorPost -notmatch 'runtime.codegraph_index=ok') { Fail 'doctor should report codegraph index ok after project-init' }
  if ($doctorPost -notmatch 'state.overall=ok') { Fail 'doctor should report semantic state healthy after project-init' }
  if ($doctorPost -notmatch 'overall=ok') { Fail 'doctor should report overall=ok after project-init' }

  $currentPath = Join-Path $SmokeRoot '.hiq\current-change.json'
  $sessionPath = Join-Path $SmokeRoot '.hiq\session.md'
  $currentBackup = "$currentPath.bak"
  $sessionBackup = "$sessionPath.bak"
  Copy-Item -LiteralPath $currentPath -Destination $currentBackup -Force
  Copy-Item -LiteralPath $sessionPath -Destination $sessionBackup -Force

  $fixture = Get-Content -LiteralPath $currentPath -Raw | ConvertFrom-Json
  $fixture.ownerSkill = 'hiq-implement'
  $fixture | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $currentPath -Encoding UTF8
  & (Join-Path $scriptDir 'hiq-doctor.ps1') $SmokeRoot --strict | Out-Null
  if ($LASTEXITCODE -eq 0) { Fail 'strict doctor accepted owner/phase drift' }
  Copy-Item -LiteralPath $currentBackup -Destination $currentPath -Force

  $fixture = Get-Content -LiteralPath $currentPath -Raw | ConvertFrom-Json
  $fixture.stateStatus = 'accepted'; $fixture.autoStatus = 'accepted'; $fixture.reviewStatus = 'pass'
  $fixture | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $currentPath -Encoding UTF8
  & (Join-Path $scriptDir 'hiq-doctor.ps1') $SmokeRoot --strict | Out-Null
  if ($LASTEXITCODE -eq 0) { Fail 'strict doctor accepted missing review proof' }
  Copy-Item -LiteralPath $currentBackup -Destination $currentPath -Force

  $fixture = Get-Content -LiteralPath $currentPath -Raw | ConvertFrom-Json
  $fixture.verifyStatus = 'valid'
  $fixture | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $currentPath -Encoding UTF8
  $sessionText = Get-Content -LiteralPath $sessionPath -Raw
  $sessionText = $sessionText -replace '(?m)^- \*\*verify_status\*\*: unset$', '- **verify_status**: valid'
  $sessionText = $sessionText -replace '(?m)^- \*\*verify_commands\*\*:$', '- **verify_commands**: `python3 --object config/objects/deleted.json`'
  Set-Content -LiteralPath $sessionPath -Value $sessionText -Encoding UTF8
  & (Join-Path $scriptDir 'hiq-doctor.ps1') $SmokeRoot --strict | Out-Null
  if ($LASTEXITCODE -eq 0) { Fail 'strict doctor accepted stale verify path' }
  Copy-Item -LiteralPath $currentBackup -Destination $currentPath -Force
  Copy-Item -LiteralPath $sessionBackup -Destination $sessionPath -Force
  Remove-Item -LiteralPath $currentBackup, $sessionBackup -Force

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
  if (-not $Keep -and (Test-Path -LiteralPath $smokeHome)) {
    Remove-Item -LiteralPath $smokeHome -Recurse -Force
  }
}

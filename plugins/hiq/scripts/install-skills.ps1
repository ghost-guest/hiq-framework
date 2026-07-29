param(
  [string]$Target = "liveagent",
  [string]$ProjectDir = "",
  [int]$Apply = 1
)

$ErrorActionPreference = "Stop"

function Copy-DirContent([string]$Source, [string]$Destination) {
  New-Item -ItemType Directory -Path $Destination -Force | Out-Null
  Copy-Item -LiteralPath (Join-Path $Source '*') -Destination $Destination -Recurse -Force
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$hiqHome = Split-Path -Parent $scriptDir
$src = Join-Path $hiqHome 'skills'
$ref = Join-Path $hiqHome 'references'
$scripts = Join-Path $hiqHome 'scripts'
$vendor = Join-Path $hiqHome 'vendor'
$extensions = Join-Path $hiqHome 'extensions'

$liveagentSkills = if ($env:LIVEAGENT_SKILLS) { $env:LIVEAGENT_SKILLS } else { Join-Path $env:USERPROFILE '.liveagent\skills' }
$codexSkills = if ($env:CODEX_SKILLS) { $env:CODEX_SKILLS } else { Join-Path $env:USERPROFILE '.codex\skills' }
$claudeSkills = if ($env:CLAUDE_SKILLS) { $env:CLAUDE_SKILLS } else { Join-Path $env:USERPROFILE '.claude\skills' }
$piSkills = if ($env:PI_SKILLS) { $env:PI_SKILLS } else { Join-Path $env:USERPROFILE '.pi\agent\skills' }
$piExtensions = if ($env:PI_EXTENSIONS) { $env:PI_EXTENSIONS } else { Join-Path $env:USERPROFILE '.pi\agent\extensions' }
$claudeHooks = if ($env:CLAUDE_HOOKS) { $env:CLAUDE_HOOKS } else { Join-Path $env:USERPROFILE '.claude\hooks' }
$hiqUserHome = if ($env:HIQ_HOME_DIR) { $env:HIQ_HOME_DIR } else { Join-Path $env:USERPROFILE '.hiq' }

switch ($Target.ToLower()) {
  'liveagent' { $dest = $liveagentSkills }
  'codex' { $dest = $codexSkills }
  'claude' { $dest = $claudeSkills }
  'pi' { $dest = $piSkills }
  'project' {
    if (-not $ProjectDir) { throw 'project target needs PROJECT_DIR as arg2' }
    $dest = Join-Path $ProjectDir '.agents\skills'
  }
  default { throw "bad target: $Target" }
}

if (-not (Test-Path -LiteralPath $src -PathType Container)) {
  throw "missing skills: $src"
}

Write-Output "hiq_home=$hiqHome"
Write-Output "source=$src"
Write-Output "dest=$dest"
Write-Output "apply=$Apply"

$skillDirs = Get-ChildItem -LiteralPath $src -Directory | Sort-Object Name
$count = 0
foreach ($dir in $skillDirs) {
  Write-Output "skill=$($dir.Name)"
  $count++
}

if ($Apply -ne 1) {
  Write-Output "mode=preview count=$count"
  Write-Output "note=apply=1 also installs Cleboost/codegraph-rs plus hiq-status/hiq-doctor/hiq-hook/hiq-activate into ~/.hiq/scripts and host helper copies"
  if ($Target.ToLower() -eq 'pi' -and (Test-Path -LiteralPath (Join-Path $extensions 'pi-hiq-auto-hook'))) {
    Write-Output 'note=pi target also installs ~/.pi/agent/extensions/hiq-auto-hook'
  }
  if ($Target.ToLower() -eq 'claude' -and (Test-Path -LiteralPath (Join-Path $extensions 'claude-hiq-auto-hook'))) {
    Write-Output 'note=claude target also installs ~/.claude/hooks/hiq-auto and merges hooks.json'
  }
  exit 0
}

New-Item -ItemType Directory -Path $dest -Force | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupRoot = Join-Path $dest ".hiq-backup-$stamp"

foreach ($dir in $skillDirs) {
  $name = $dir.Name
  $targetPath = Join-Path $dest $name
  if (Test-Path -LiteralPath $targetPath) {
    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    Move-Item -LiteralPath $targetPath -Destination (Join-Path $backupRoot $name) -Force
    Write-Output "backup=$name"
  }
  Copy-Item -LiteralPath $dir.FullName -Destination $targetPath -Recurse -Force
  Write-Output "installed=$name"
}

if (Test-Path -LiteralPath $ref) {
  $refDest = Join-Path $dest '_hiq-references'
  if (Test-Path -LiteralPath $refDest) { Remove-Item -LiteralPath $refDest -Recurse -Force }
  Copy-Item -LiteralPath $ref -Destination $refDest -Recurse -Force
  Write-Output 'installed=_hiq-references'
}

New-Item -ItemType Directory -Path (Join-Path $hiqUserHome 'scripts') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $hiqUserHome 'vendor') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $hiqUserHome 'bin') -Force | Out-Null
if (Test-Path -LiteralPath $scripts) {
  Copy-DirContent $scripts (Join-Path $hiqUserHome 'scripts')
  Write-Output "installed=$hiqUserHome/scripts"
}
if (Test-Path -LiteralPath $vendor) {
  Copy-DirContent $vendor (Join-Path $hiqUserHome 'vendor')
  Write-Output "installed=$hiqUserHome/vendor"
}

foreach ($name in @('_hiq-scripts', '_hiq-vendor')) {
  $path = Join-Path $dest $name
  if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Recurse -Force }
}
Copy-Item -LiteralPath $scripts -Destination (Join-Path $dest '_hiq-scripts') -Recurse -Force
Copy-Item -LiteralPath $vendor -Destination (Join-Path $dest '_hiq-vendor') -Recurse -Force
Write-Output 'installed=_hiq-scripts _hiq-vendor'

if ($Target.ToLower() -eq 'pi') {
  $piHookSource = Join-Path $extensions 'pi-hiq-auto-hook'
  if (Test-Path -LiteralPath $piHookSource) {
    New-Item -ItemType Directory -Path $piExtensions -Force | Out-Null
    $piHookDest = Join-Path $piExtensions 'hiq-auto-hook'
    if (Test-Path -LiteralPath $piHookDest) {
      $extBackupRoot = Join-Path $piExtensions ".hiq-backup-$stamp"
      New-Item -ItemType Directory -Path $extBackupRoot -Force | Out-Null
      Move-Item -LiteralPath $piHookDest -Destination (Join-Path $extBackupRoot 'hiq-auto-hook') -Force
      Write-Output 'backup=hiq-auto-hook'
    }
    Copy-Item -LiteralPath $piHookSource -Destination $piHookDest -Recurse -Force
    Write-Output "installed=$piHookDest"
  }
}

if ($Target.ToLower() -eq 'claude') {
  $claudeHookSource = Join-Path $extensions 'claude-hiq-auto-hook'
  if (Test-Path -LiteralPath $claudeHookSource) {
    New-Item -ItemType Directory -Path $claudeHooks -Force | Out-Null
    $claudeHookDest = Join-Path $claudeHooks 'hiq-auto'
    if (Test-Path -LiteralPath $claudeHookDest) {
      $claudeBackupRoot = Join-Path $claudeHooks ".hiq-backup-$stamp"
      New-Item -ItemType Directory -Path $claudeBackupRoot -Force | Out-Null
      Move-Item -LiteralPath $claudeHookDest -Destination (Join-Path $claudeBackupRoot 'hiq-auto') -Force
      Write-Output 'backup=claude-hiq-auto'
    }
    Copy-Item -LiteralPath $claudeHookSource -Destination $claudeHookDest -Recurse -Force
    Write-Output "installed=$claudeHookDest"
    & (Join-Path $scripts 'lib\merge_claude_hooks.ps1') -HooksJson (Join-Path $claudeHooks 'hooks.json') -HookRoot $claudeHookDest -Platform windows
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  }
}

Write-Output 'hiq-install: installing bundled codegraph-rs...'
& (Join-Path $scripts 'install-codegraph.cmd')
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Copy-Item -LiteralPath (Join-Path $scripts '*.cmd') -Destination (Join-Path $hiqUserHome 'scripts') -Force -ErrorAction SilentlyContinue
Copy-Item -LiteralPath (Join-Path $scripts '*.ps1') -Destination (Join-Path $hiqUserHome 'scripts') -Force -ErrorAction SilentlyContinue
Write-Output "done count=$count stamp=$stamp dest=$dest codegraph=$hiqUserHome/bin/codegraph.exe"

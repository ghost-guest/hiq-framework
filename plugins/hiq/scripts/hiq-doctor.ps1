param(
  [string]$Root = ".",
  [string]$Mode = ""
)

$ErrorActionPreference = "Stop"

function Get-FullPath([string]$Path) {
  return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
}

function Check-File([string]$Path) {
  if (Test-Path -LiteralPath $Path -PathType Leaf) { return "ok" }
  return "missing"
}

function Check-Dir([string]$Path) {
  if (Test-Path -LiteralPath $Path -PathType Container) { return "ok" }
  return "missing"
}

function Get-MdField([string]$Key, [string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) { return "" }
  $pattern = '^- \*\*' + [regex]::Escape($Key) + '\*\*: (.*)$'
  foreach ($line in Get-Content -LiteralPath $Path) {
    if ($line -match $pattern) {
      return $Matches[1].Trim().Trim('`')
    }
  }
  return ""
}

$resolvedRoot = Get-FullPath $Root
$hiq = Join-Path $resolvedRoot ".hiq"
$hiqHome = if ($env:HIQ_HOME_DIR) { $env:HIQ_HOME_DIR } else { Join-Path $env:USERPROFILE ".hiq" }
$session = Join-Path $hiq "session.md"
$current = Join-Path $hiq "current-change.json"
$config = Join-Path $hiq "config.yaml"
$manifest = Join-Path $hiq "runtime-manifest.json"
$bootstrap = Join-Path $hiq "BOOTSTRAP.md"
$memory = Join-Path $hiq "MEMORY.md"
$activeChange = Get-MdField "active_change" $session
$codegraphBin = Join-Path $hiqHome "bin\codegraph.exe"
$codegraphStatus = if (Test-Path -LiteralPath $codegraphBin) { "ok" } else { "missing" }
$codegraphIndex = Check-Dir (Join-Path $resolvedRoot ".codegraph")

$projectOk = $true
foreach ($f in @($bootstrap, $memory, $session, $config, $current, $manifest)) {
  if (-not (Test-Path -LiteralPath $f)) { $projectOk = $false }
}

$changeDirStatus = "none"
if ($activeChange -and $activeChange -ne "none") {
  $candidate = $activeChange
  if ($candidate.StartsWith("./")) { $candidate = $candidate.Substring(2) }
  $pathA = Join-Path $resolvedRoot $candidate
  if ((Test-Path -LiteralPath $pathA -PathType Container) -or (Test-Path -LiteralPath $activeChange -PathType Container)) {
    $changeDirStatus = "ok"
  } else {
    $changeDirStatus = "missing"
    $projectOk = $false
  }
}

$runtimeChecks = [ordered]@{
  hiqHome = $hiqHome
  codegraphBin = $codegraphStatus
  codegraphIndex = $codegraphIndex
  hiqRun = Check-File (Join-Path $hiqHome "scripts\hiq-run.cmd")
  hiqStatus = Check-File (Join-Path $hiqHome "scripts\hiq-status.cmd")
  hiqDoctor = Check-File (Join-Path $hiqHome "scripts\hiq-doctor.cmd")
}

$runtimeOk = $true
foreach ($value in @($runtimeChecks.codegraphBin, $runtimeChecks.hiqRun, $runtimeChecks.hiqStatus, $runtimeChecks.hiqDoctor)) {
  if ($value -ne "ok") { $runtimeOk = $false }
}

if ($Mode -eq "--json") {
  [ordered]@{
    root = $resolvedRoot
    project = [ordered]@{
      bootstrap = Check-File $bootstrap
      memory = Check-File $memory
      session = Check-File $session
      config = Check-File $config
      currentChange = Check-File $current
      manifest = Check-File $manifest
      evalRoot = Check-Dir (Join-Path $hiq "eval")
      activeChangeDir = $changeDirStatus
    }
    runtime = $runtimeChecks
    overall = $(if ($projectOk -and $runtimeOk) { "ok" } else { "partial" })
  } | ConvertTo-Json -Depth 4
  exit 0
}

Write-Output "hiq_root=$resolvedRoot"
Write-Output "project.bootstrap=$(Check-File $bootstrap)"
Write-Output "project.memory=$(Check-File $memory)"
Write-Output "project.session=$(Check-File $session)"
Write-Output "project.config=$(Check-File $config)"
Write-Output "project.current_change=$(Check-File $current)"
Write-Output "project.manifest=$(Check-File $manifest)"
Write-Output "project.eval_root=$(Check-Dir (Join-Path $hiq 'eval'))"
Write-Output "project.active_change_dir=$changeDirStatus"
Write-Output "runtime.hiq_home=$hiqHome"
Write-Output "runtime.codegraph_bin=$($runtimeChecks.codegraphBin)"
Write-Output "runtime.codegraph_index=$($runtimeChecks.codegraphIndex)"
Write-Output "runtime.hiq_run=$($runtimeChecks.hiqRun)"
Write-Output "runtime.hiq_status=$($runtimeChecks.hiqStatus)"
Write-Output "runtime.hiq_doctor=$($runtimeChecks.hiqDoctor)"
Write-Output "overall=$(if ($projectOk -and $runtimeOk) { 'ok' } else { 'partial' })"

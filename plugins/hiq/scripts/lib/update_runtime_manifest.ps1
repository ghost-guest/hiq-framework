param(
  [Parameter(Mandatory = $true)][string]$Root,
  [Parameter(Mandatory = $true)][string]$Bin
)

$ErrorActionPreference = "Stop"

function Get-FullPath([string]$Path) {
  if ([System.IO.Path]::IsPathRooted($Path)) {
    return [System.IO.Path]::GetFullPath($Path)
  }
  return [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $Path))
}

function Invoke-Capture([string]$Command, [string[]]$Args) {
  try {
    $output = & $Command @Args 2>&1 | Out-String
    return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = $output }
  } catch {
    return [pscustomobject]@{ ExitCode = 1; Output = ($_ | Out-String) }
  }
}

$resolvedRoot = Get-FullPath $Root
$manifestPath = Join-Path $resolvedRoot ".hiq\runtime-manifest.json"
$existing = $null
if (Test-Path -LiteralPath $manifestPath) {
  try {
    $raw = Get-Content -LiteralPath $manifestPath -Raw
    if ($raw.Trim()) {
      $existing = $raw | ConvertFrom-Json
    }
  } catch {
    $existing = $null
  }
}

$createdAt = if ($existing -and $existing.PSObject.Properties.Name -contains 'created_at' -and $existing.created_at) {
  [string]$existing.created_at
} else {
  Get-Date -Format 'yyyy-MM-dd'
}
$schema = 2
if ($existing -and $existing.PSObject.Properties.Name -contains 'schema' -and $existing.schema) {
  $schema = [int]$existing.schema
}
$stack = if ($existing -and $existing.PSObject.Properties.Name -contains 'stack') { $existing.stack } else { $null }
$memory = if ($existing -and $existing.PSObject.Properties.Name -contains 'memory') { $existing.memory } else { $null }
$existingCodegraph = if ($existing -and $existing.PSObject.Properties.Name -contains 'codegraph') { $existing.codegraph } else { $null }

$statusOutput = & $Bin status --path $resolvedRoot 2>&1 | Out-String
$files = 0
$nodes = 0
$edges = 0
foreach ($line in ($statusOutput -split "`r?`n")) {
  if ($line -match '^\s*files:\s*(\d+)') { $files = [int]$Matches[1] }
  if ($line -match '^\s*nodes:\s*(\d+)') { $nodes = [int]$Matches[1] }
  if ($line -match '^\s*edges:\s*(\d+)') { $edges = [int]$Matches[1] }
}

$version = ''
foreach ($args in @(@('--version'), @('version'))) {
  try {
    $versionOutput = & $Bin @args 2>&1 | Out-String
    if ($LASTEXITCODE -eq 0 -and $versionOutput.Trim()) {
      if ($versionOutput -match '(\d+\.\d+\.\d+(?:[-+][^\s]+)?)') {
        $version = $Matches[1]
      } else {
        $version = ($versionOutput -split "`r?`n")[0].Trim()
      }
      break
    }
  } catch {
  }
}

$hiqHome = if ($env:HIQ_HOME_DIR) { $env:HIQ_HOME_DIR } else { Join-Path $env:USERPROFILE '.hiq' }
$scriptsDir = Join-Path $hiqHome 'scripts'
$statusScript = Join-Path $scriptsDir 'hiq-status.cmd'
$doctorScript = Join-Path $scriptsDir 'hiq-doctor.cmd'
$hookScript = Join-Path $scriptsDir 'hiq-hook.cmd'

$hiqStatus = 'missing'
$statusJson = $null
if (Test-Path -LiteralPath $statusScript) {
  $statusResult = Invoke-Capture $statusScript @($resolvedRoot, '--json')
  try {
    $statusJson = $statusResult.Output | ConvertFrom-Json
    $hiqStatus = if ($statusResult.ExitCode -eq 0 -and [string]$statusJson.pointerStatus -eq 'ok') { 'ok' } else { 'partial' }
  } catch {
    $hiqStatus = if ($statusResult.ExitCode -ne 0) { 'error' } else { 'partial' }
  }
}

$hiqDoctor = 'missing'
$doctorJson = $null
if (Test-Path -LiteralPath $doctorScript) {
  $doctorResult = Invoke-Capture $doctorScript @($resolvedRoot, '--json')
  try {
    $doctorJson = $doctorResult.Output | ConvertFrom-Json
    $hiqDoctor = if ($doctorResult.ExitCode -eq 0 -and [string]$doctorJson.overall -eq 'ok') { 'ok' } else { 'partial' }
  } catch {
    $hiqDoctor = if ($doctorResult.ExitCode -ne 0) { 'error' } else { 'partial' }
  }
}

$hiqHook = if (Test-Path -LiteralPath $hookScript) { 'ok' } else { 'missing' }
$updatedAt = ((Get-Date).ToString('yyyy-MM-ddTHH:mm:sszzz') -replace ':(?=\d\d$)', '')
$codegraph = [ordered]@{
  engine = 'Cleboost/codegraph-rs'
  binary = $Bin
  version = $version
  status = 'initialized'
  files = $files
  nodes = $nodes
  edges = $edges
}
if ($existingCodegraph -and $existingCodegraph.PSObject.Properties.Name -contains 'note' -and $existingCodegraph.note) {
  $codegraph.note = [string]$existingCodegraph.note
}

$runtimeState = [ordered]@{
  hiq_status = $hiqStatus
  hiq_doctor = $hiqDoctor
  hiq_hook = $hiqHook
  updated_at = $updatedAt
}
if ($doctorJson) {
  $runtimeState.doctor_overall = $doctorJson.overall
  $runtimeState.doctor_state = $doctorJson.stateOverall
}

$manifest = [ordered]@{
  framework = 'hiq'
  schema = $schema
  mode = 'refresh'
  created_at = $createdAt
  updated_at = $updatedAt
  codegraph = $codegraph
  runtime_state = $runtimeState
}
if ($stack) { $manifest.stack = $stack }
if ($memory) { $manifest.memory = $memory }
if ($statusJson) {
  $manifest.session_pointer = [ordered]@{
    entry_skill = $statusJson.entrySkill
    entry_mode = $statusJson.entryMode
    auto_status = $statusJson.autoStatus
    owner_skill = $statusJson.ownerSkill
    next_skill = $statusJson.nextSkill
    goal_path = $statusJson.goalPath
    host_automation_level = $statusJson.hostAutomationLevel
    pointer_status = $statusJson.pointerStatus
  }
}

$manifestDir = Split-Path -Parent $manifestPath
if (-not (Test-Path -LiteralPath $manifestDir)) {
  New-Item -ItemType Directory -Path $manifestDir -Force | Out-Null
}

$manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $manifestPath
Write-Output "manifest=$manifestPath files=$files nodes=$nodes edges=$edges hiq_status=$hiqStatus hiq_doctor=$hiqDoctor"

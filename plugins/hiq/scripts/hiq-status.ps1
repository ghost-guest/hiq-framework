param(
  [string]$Root = ".",
  [string]$Mode = ""
)

$ErrorActionPreference = "Stop"

function Get-FullPath([string]$Path) {
  return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
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
$session = Join-Path $hiq "session.md"
$current = Join-Path $hiq "current-change.json"
$currentObj = $null
if (Test-Path -LiteralPath $current) {
  try { $currentObj = Get-Content -LiteralPath $current -Raw | ConvertFrom-Json } catch { $currentObj = $null }
}

$activeChange = Get-MdField "active_change" $session
$phase = Get-MdField "phase" $session
$nextSkill = Get-MdField "next_skill" $session
$nextStep = Get-MdField "next_step" $session
$goalNow = Get-MdField "goal_now" $session
$checkpoint = Get-MdField "latest_checkpoint" $session
$updated = Get-MdField "updated" $session
$ownerSkill = if ($currentObj) { [string]$currentObj.ownerSkill } else { "" }
$currentPhase = if ($currentObj) { [string]$currentObj.phase } else { "" }

if ($Mode -eq "--json") {
  [ordered]@{
    root = $resolvedRoot
    hiq = $hiq
    sessionExists = (Test-Path -LiteralPath $session)
    currentChangeExists = (Test-Path -LiteralPath $current)
    activeChange = $activeChange
    phase = $phase
    ownerSkill = $ownerSkill
    currentPhase = $currentPhase
    nextSkill = $nextSkill
    nextStep = $nextStep
    goalNow = $goalNow
    latestCheckpoint = $checkpoint
    updated = $updated
  } | ConvertTo-Json -Depth 4
  exit 0
}

Write-Output "hiq_root=$resolvedRoot"
Write-Output ("session={0}" -f ($(if (Test-Path -LiteralPath $session) { "ok" } else { "missing" })))
Write-Output ("current_change={0}" -f ($(if (Test-Path -LiteralPath $current) { "ok" } else { "missing" })))
Write-Output ("active_change={0}" -f $(if ($activeChange) { $activeChange } else { "none" }))
Write-Output ("phase={0}" -f $(if ($phase) { $phase } else { "unknown" }))
Write-Output ("owner_skill={0}" -f $(if ($ownerSkill) { $ownerSkill } else { "unknown" }))
Write-Output ("next_skill={0}" -f $(if ($nextSkill) { $nextSkill } else { "unknown" }))
Write-Output ("goal_now={0}" -f $goalNow)
Write-Output ("checkpoint={0}" -f $(if ($checkpoint) { $checkpoint } else { "none" }))
Write-Output ("updated={0}" -f $(if ($updated) { $updated } else { "unknown" }))
if ($currentPhase -and $phase -and $currentPhase -ne $phase) {
  Write-Output "warning=session_phase_mismatch session=$phase current_change=$currentPhase"
}

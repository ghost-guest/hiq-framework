param(
  [string]$Root = ".",
  [string]$Mode = ""
)

$ErrorActionPreference = "Stop"

if ($Root.StartsWith('--')) {
  if ($Mode) { Write-Error 'too many options when root is omitted'; exit 2 }
  $Mode = $Root
  $Root = "."
}
if ($Mode -notin @('', '--json')) { Write-Error "unknown option: $Mode"; exit 2 }

function Get-FullPath([string]$Path) {
  if ([System.IO.Path]::IsPathRooted($Path)) {
    return [System.IO.Path]::GetFullPath($Path)
  }
  return [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $Path))
}

function Get-MdField([string]$Key, [string]$Path) {
  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return "" }
  $pattern = '^- \*\*' + [regex]::Escape($Key) + '\*\*: (.*)$'
  foreach ($line in Get-Content -LiteralPath $Path) {
    if ($line -match $pattern) { return $Matches[1].Trim().Trim('`') }
  }
  return ""
}

function Get-JsonValue($Object, [string]$Key) {
  if ($null -eq $Object) { return "" }
  $property = $Object.PSObject.Properties[$Key]
  if ($null -eq $property) { return "" }
  if ($null -eq $property.Value) { return "null" }
  if ($property.Value -is [bool]) { return $property.Value.ToString().ToLowerInvariant() }
  return [string]$property.Value
}

$resolvedRoot = Get-FullPath $Root
$hiq = Join-Path $resolvedRoot ".hiq"
$session = Join-Path $hiq "session.md"
$current = Join-Path $hiq "current-change.json"
$currentObj = $null
if (Test-Path -LiteralPath $current -PathType Leaf) {
  try { $currentObj = Get-Content -LiteralPath $current -Raw | ConvertFrom-Json } catch { $currentObj = $null }
}

$entrySkill = Get-JsonValue $currentObj 'entrySkill'; if (-not $entrySkill) { $entrySkill = Get-MdField 'entry_skill' $session }
$entryMode = Get-JsonValue $currentObj 'entryMode'; if (-not $entryMode) { $entryMode = Get-MdField 'entry_mode' $session }
$hostTarget = Get-JsonValue $currentObj 'hostTarget'
$hostLevel = Get-JsonValue $currentObj 'hostAutomationLevel'
$hostEvidence = Get-JsonValue $currentObj 'hostAutomationEvidence'; if (-not $hostEvidence) { $hostEvidence = Get-MdField 'host_automation_evidence' $session }
$hookProtocol = Get-JsonValue $currentObj 'hookProtocolVersion'; if (-not $hookProtocol) { $hookProtocol = Get-MdField 'hook_protocol_version' $session }
$hookCore = Get-JsonValue $currentObj 'hookCoreStatus'; if (-not $hookCore) { $hookCore = Get-MdField 'hook_core_status' $session }
$hookAdapter = Get-JsonValue $currentObj 'hookAdapter'; if (-not $hookAdapter) { $hookAdapter = Get-MdField 'hook_adapter' $session }
$hookLastEvent = Get-JsonValue $currentObj 'hookLastEvent'; if (-not $hookLastEvent) { $hookLastEvent = Get-MdField 'hook_last_event' $session }
$hookLastRun = Get-JsonValue $currentObj 'hookLastRunPath'; if (-not $hookLastRun) { $hookLastRun = Get-MdField 'hook_last_run' $session }
$hookLastStatus = Get-JsonValue $currentObj 'hookLastRunStatus'; if (-not $hookLastStatus) { $hookLastStatus = Get-MdField 'hook_last_status' $session }
$autoStatus = Get-JsonValue $currentObj 'autoStatus'; if (-not $autoStatus) { $autoStatus = Get-MdField 'auto_status' $session }
$autoOwner = Get-JsonValue $currentObj 'autoOwnerSkill'; if (-not $autoOwner) { $autoOwner = Get-MdField 'auto_owner' $session }
$autoReason = Get-JsonValue $currentObj 'autoReason'; if (-not $autoReason) { $autoReason = Get-MdField 'auto_reason' $session }
$manualOverride = Get-JsonValue $currentObj 'manualOverride'; if (-not $manualOverride) { $manualOverride = Get-MdField 'manual_override' $session }
$activeChange = Get-JsonValue $currentObj 'activeChange'; if (-not $activeChange) { $activeChange = Get-MdField 'active_change' $session }
$stateStatus = Get-JsonValue $currentObj 'stateStatus'
$phase = Get-JsonValue $currentObj 'phase'; if (-not $phase) { $phase = Get-MdField 'phase' $session }
$contentRevision = Get-JsonValue $currentObj 'contentRevision'
$ownerSkill = Get-JsonValue $currentObj 'ownerSkill'
$nextSkill = Get-JsonValue $currentObj 'nextSkill'; if (-not $nextSkill) { $nextSkill = Get-MdField 'next_skill' $session }
$nextStep = Get-JsonValue $currentObj 'nextStep'; if (-not $nextStep) { $nextStep = Get-MdField 'next_step' $session }
$goalNow = Get-JsonValue $currentObj 'goalNow'; if (-not $goalNow) { $goalNow = Get-MdField 'goal_now' $session }
$reviewStatus = Get-JsonValue $currentObj 'reviewStatus'; if (-not $reviewStatus) { $reviewStatus = Get-MdField 'review_status' $session }
$reviewPath = Get-JsonValue $currentObj 'reviewPath'; if (-not $reviewPath) { $reviewPath = Get-MdField 'review_path' $session }
$evalApplicability = Get-JsonValue $currentObj 'evalApplicability'; if (-not $evalApplicability) { $evalApplicability = Get-MdField 'eval_applicability' $session }
$evalStatus = Get-JsonValue $currentObj 'evalStatus'; if (-not $evalStatus) { $evalStatus = Get-MdField 'eval_status' $session }
$checkpointRequired = Get-JsonValue $currentObj 'checkpointRequired'; if (-not $checkpointRequired) { $checkpointRequired = 'false' }
$checkpointRequiredBool = ($checkpointRequired -eq 'true')
$checkpointReason = Get-JsonValue $currentObj 'checkpointReason'; if (-not $checkpointReason) { $checkpointReason = Get-MdField 'checkpoint_reason' $session }
$checkpoint = Get-JsonValue $currentObj 'latestCheckpoint'; if (-not $checkpoint) { $checkpoint = Get-MdField 'latest_checkpoint' $session }
$verifyStatus = Get-JsonValue $currentObj 'verifyStatus'; if (-not $verifyStatus) { $verifyStatus = Get-MdField 'verify_status' $session }
$updated = Get-JsonValue $currentObj 'updatedAt'; if (-not $updated) { $updated = Get-MdField 'updated' $session }
if ($activeChange -in @('', 'null')) { $activeChange = 'none' }
if ($reviewPath -in @('', 'null')) { $reviewPath = 'none' }
if ($hookLastEvent -in @('', 'null')) { $hookLastEvent = 'none' }
if ($hookLastRun -in @('', 'null')) { $hookLastRun = 'none' }
if ($checkpoint -in @('', 'null')) { $checkpoint = 'none' }

$pointerStatus = 'ok'
$expectedOwner = switch ($phase) {
  idle { 'hiq-session' }; init { 'hiq-init' }; install { 'hiq-install' }; grill { 'hiq-grill' }; implement { 'hiq-implement' }; debug { 'hiq-debug' }; review { 'hiq-review' }; evolve { 'hiq-evolve' }; knowledge { 'hiq-knowledge' }; skill { 'hiq-skill' }; default { '' }
}
if (-not $expectedOwner -or ($ownerSkill -and $ownerSkill -ne $expectedOwner)) { $pointerStatus = 'partial' }
if ((-not $manualOverride -or $manualOverride -eq 'none') -and $autoOwner -and $ownerSkill -and $autoOwner -ne $ownerSkill) { $pointerStatus = 'partial' }
if ($phase -and (Get-MdField 'phase' $session) -ne $phase) { $pointerStatus = 'partial' }
if ($nextSkill -and (Get-MdField 'next_skill' $session) -ne $nextSkill) { $pointerStatus = 'partial' }
if ($checkpoint -and $checkpoint -notin @('none','null')) {
  $checkpointRelative = $checkpoint.Replace('\','/')
  if ($checkpointRelative.StartsWith('./')) { $checkpointRelative = $checkpointRelative.Substring(2) }
  $checkpointPath = [System.IO.Path]::GetFullPath((Join-Path $resolvedRoot $checkpointRelative))
  if (-not (Test-Path -LiteralPath $checkpointPath -PathType Leaf)) { $pointerStatus = 'partial' }
}

if ($Mode -eq '--json') {
  [ordered]@{
    root = $resolvedRoot
    hiq = $hiq
    sessionExists = (Test-Path -LiteralPath $session -PathType Leaf)
    currentChangeExists = (Test-Path -LiteralPath $current -PathType Leaf)
    entrySkill = $entrySkill
    entryMode = $entryMode
    hostTarget = $hostTarget
    hostAutomationLevel = $hostLevel
    hostAutomationEvidence = $hostEvidence
    hookProtocolVersion = $hookProtocol
    hookCoreStatus = $hookCore
    hookAdapter = $hookAdapter
    hookLastEvent = $hookLastEvent
    hookLastRunPath = $hookLastRun
    hookLastRunStatus = $hookLastStatus
    autoStatus = $autoStatus
    autoOwnerSkill = $autoOwner
    autoReason = $autoReason
    manualOverride = $manualOverride
    activeChange = $activeChange
    stateStatus = $stateStatus
    phase = $phase
    contentRevision = $contentRevision
    ownerSkill = $ownerSkill
    nextSkill = $nextSkill
    nextStep = $nextStep
    goalNow = $goalNow
    reviewStatus = $reviewStatus
    reviewPath = $reviewPath
    evalApplicability = $evalApplicability
    evalStatus = $evalStatus
    checkpointRequired = $checkpointRequiredBool
    checkpointReason = $checkpointReason
    latestCheckpoint = $checkpoint
    verifyStatus = $verifyStatus
    updatedAt = $updated
    pointerStatus = $pointerStatus
  } | ConvertTo-Json -Depth 4
  exit 0
}

Write-Output "hiq_root=$resolvedRoot"
Write-Output ("session={0}" -f ($(if (Test-Path -LiteralPath $session -PathType Leaf) { 'ok' } else { 'missing' })))
Write-Output ("current_change={0}" -f ($(if (Test-Path -LiteralPath $current -PathType Leaf) { 'ok' } else { 'missing' })))
Write-Output ("entry_skill={0}" -f $(if ($entrySkill) { $entrySkill } else { 'unknown' }))
Write-Output ("entry_mode={0}" -f $(if ($entryMode) { $entryMode } else { 'unknown' }))
Write-Output ("host_target={0}" -f $(if ($hostTarget) { $hostTarget } else { 'unknown' }))
Write-Output ("host_automation_level={0}" -f $(if ($hostLevel) { $hostLevel } else { 'unknown' }))
Write-Output ("host_automation_evidence={0}" -f $(if ($hostEvidence) { $hostEvidence } else { 'none' }))
Write-Output ("hook_protocol_version={0}" -f $(if ($hookProtocol) { $hookProtocol } else { 'unknown' }))
Write-Output ("hook_core_status={0}" -f $(if ($hookCore) { $hookCore } else { 'unknown' }))
Write-Output ("hook_adapter={0}" -f $(if ($hookAdapter) { $hookAdapter } else { 'none' }))
Write-Output ("hook_last_event={0}" -f $(if ($hookLastEvent) { $hookLastEvent } else { 'none' }))
Write-Output ("hook_last_run={0}" -f $(if ($hookLastRun) { $hookLastRun } else { 'none' }))
Write-Output ("hook_last_status={0}" -f $(if ($hookLastStatus) { $hookLastStatus } else { 'none' }))
Write-Output ("auto_status={0}" -f $(if ($autoStatus) { $autoStatus } else { 'unknown' }))
Write-Output ("auto_owner={0}" -f $(if ($autoOwner) { $autoOwner } else { 'unknown' }))
Write-Output ("auto_reason={0}" -f $autoReason)
Write-Output ("manual_override={0}" -f $(if ($manualOverride) { $manualOverride } else { 'none' }))
Write-Output ("active_change={0}" -f $(if ($activeChange) { $activeChange } else { 'none' }))
Write-Output ("state_status={0}" -f $(if ($stateStatus) { $stateStatus } else { 'unknown' }))
Write-Output ("phase={0}" -f $(if ($phase) { $phase } else { 'unknown' }))
Write-Output ("content_revision={0}" -f $(if ($contentRevision) { $contentRevision } else { 'unknown' }))
Write-Output ("owner_skill={0}" -f $(if ($ownerSkill) { $ownerSkill } else { 'unknown' }))
Write-Output ("next_skill={0}" -f $(if ($nextSkill) { $nextSkill } else { 'unknown' }))
Write-Output ("next_step={0}" -f $nextStep)
Write-Output ("goal_now={0}" -f $goalNow)
Write-Output ("review_status={0}" -f $(if ($reviewStatus) { $reviewStatus } else { 'unknown' }))
Write-Output ("review_path={0}" -f $(if ($reviewPath) { $reviewPath } else { 'none' }))
Write-Output ("eval_applicability={0}" -f $(if ($evalApplicability) { $evalApplicability } else { 'unknown' }))
Write-Output ("eval_status={0}" -f $(if ($evalStatus) { $evalStatus } else { 'unknown' }))
Write-Output "checkpoint_required=$checkpointRequired"
Write-Output ("checkpoint_reason={0}" -f $(if ($checkpointReason) { $checkpointReason } else { 'none' }))
Write-Output ("checkpoint={0}" -f $(if ($checkpoint) { $checkpoint } else { 'none' }))
Write-Output ("verify_status={0}" -f $(if ($verifyStatus) { $verifyStatus } else { 'unknown' }))
Write-Output ("updated={0}" -f $(if ($updated) { $updated } else { 'unknown' }))
Write-Output "pointer_status=$pointerStatus"

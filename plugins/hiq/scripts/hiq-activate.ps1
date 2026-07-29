param(
  [string]$Root = ".",
  [string]$Mode = "auto",
  [string]$GoalTitle = "",
  [string]$GoalNow = "",
  [string]$Acceptance = "",
  [string]$Owner = "hiq-session",
  [string]$Phase = "",
  [string]$NextSkill = "",
  [string]$NextStep = "",
  [string]$Reason = "hiq-auto activated for this project turn",
  [string]$ManualOverride = "none",
  [string]$StateStatus = "active",
  [string]$AutoStatus = "active",
  [string]$ActiveChange = "none",
  [string]$ResumeSource = "session",
  [string]$HostTarget = "",
  [string]$HostLevel = "",
  [string]$HostEvidence = "",
  [string]$HookAdapter = "",
  [switch]$IfNeeded,
  [switch]$Json
)

$ErrorActionPreference = "Stop"

function Get-FullPath([string]$Path) {
  if ([System.IO.Path]::IsPathRooted($Path)) {
    return [System.IO.Path]::GetFullPath($Path)
  }
  return [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $Path))
}

function Normalize-None([object]$Value) {
  if ($null -eq $Value) { return 'none' }
  $text = [string]$Value
  if ([string]::IsNullOrWhiteSpace($text) -or $text -in @('null', 'None')) { return 'none' }
  return $text.Trim()
}

function Set-MdField([string]$Text, [string]$Key, [string]$Value) {
  $pattern = '(?m)^- \*\*' + [regex]::Escape($Key) + '\*\*:.*$'
  $line = "- **$Key**: $Value"
  if ([regex]::IsMatch($Text, $pattern)) {
    return [regex]::Replace($Text, $pattern, $line)
  }
  return $Text
}

function Slugify([string]$Text) {
  $slug = ($Text -replace '[^A-Za-z0-9]+', '-').Trim('-').ToLowerInvariant()
  if (-not $slug) { return 'goal' }
  if ($slug.Length -gt 48) { return $slug.Substring(0, 48).Trim('-') }
  return $slug
}

$defaultPhase = switch ($Owner) {
  'hiq-init' { 'init' }
  'hiq-install' { 'install' }
  'hiq-grill' { 'grill' }
  'hiq-implement' { 'implement' }
  'hiq-debug' { 'debug' }
  'hiq-review' { 'review' }
  'hiq-evolve' { 'evolve' }
  'hiq-knowledge' { 'knowledge' }
  'hiq-skill' { 'skill' }
  default { 'idle' }
}
if (-not $Phase) { $Phase = $defaultPhase }
if (-not $NextSkill) { $NextSkill = $Owner }
if (-not $NextStep) {
  $NextStep = switch ($Owner) {
    'hiq-grill' { 'clarify scope, confirm acceptance target, and choose the truthful next owner lane' }
    'hiq-session' { 'rebuild pointer and resume the truthful current owner step' }
    'hiq-debug' { 'freeze the symptom, identify root cause, and define the next repair step' }
    'hiq-review' { 'refresh proof for the current revision and decide acceptance honestly' }
    default { 'execute the truthful next owner step for this goal' }
  }
}

$resolvedRoot = Get-FullPath $Root
$hiq = Join-Path $resolvedRoot '.hiq'
$currentPath = Join-Path $hiq 'current-change.json'
$sessionPath = Join-Path $hiq 'session.md'
$goalsDir = Join-Path $hiq 'goals'
New-Item -ItemType Directory -Path $goalsDir -Force | Out-Null

$current = if (Test-Path -LiteralPath $currentPath) {
  Get-Content -LiteralPath $currentPath -Raw | ConvertFrom-Json
} else {
  [pscustomobject]@{ framework = 'hiq'; schema = 2 }
}
if ($IfNeeded -and $current.PSObject.Properties.Name -contains 'autoStatus' -and [string]$current.autoStatus -eq 'active' -and $current.PSObject.Properties.Name -contains 'goalPath' -and $current.goalPath) {
  $result = [ordered]@{
    skipped = $true
    goalId = if ($current.PSObject.Properties.Name -contains 'goalId') { $current.goalId } else { $null }
    goalPath = $current.goalPath
    ownerSkill = if ($current.PSObject.Properties.Name -contains 'ownerSkill') { $current.ownerSkill } else { $null }
    phase = if ($current.PSObject.Properties.Name -contains 'phase') { $current.phase } else { $null }
    autoStatus = $current.autoStatus
    stateRevision = if ($current.PSObject.Properties.Name -contains 'stateRevision') { $current.stateRevision } else { $null }
    updatedAt = if ($current.PSObject.Properties.Name -contains 'updatedAt') { $current.updatedAt } else { $null }
  }
  if ($Json) {
    $result | ConvertTo-Json -Depth 8
  } else {
    Write-Output 'skipped=true'
    foreach ($key in @('goalId', 'goalPath', 'ownerSkill', 'phase', 'autoStatus', 'stateRevision')) {
      Write-Output ($key + '=' + $result[$key])
    }
  }
  exit 0
}

$stamp = ((Get-Date).ToString('yyyy-MM-ddTHH:mm:sszzz') -replace ':(?=\d\d$)', '')
$stampId = Get-Date -Format 'yyyyMMdd-HHmmss'
$stateRevision = 1
if ($current.PSObject.Properties.Name -contains 'stateRevision' -and $current.stateRevision) {
  $stateRevision = [int]$current.stateRevision + 1
}
$contentRevision = 0
if ($current.PSObject.Properties.Name -contains 'contentRevision' -and $current.contentRevision -ne $null) {
  $contentRevision = [int]$current.contentRevision
}
$reviewStatus = if ($current.PSObject.Properties.Name -contains 'reviewStatus' -and $current.reviewStatus) { [string]$current.reviewStatus } else { 'not-run' }
$reviewPath = if ($current.PSObject.Properties.Name -contains 'reviewPath') { Normalize-None $current.reviewPath } else { 'none' }
$reviewedRevision = if ($current.PSObject.Properties.Name -contains 'reviewedContentRevision') { Normalize-None $current.reviewedContentRevision } else { 'none' }
$resolvedGoalNow = if ($GoalNow) { $GoalNow.Trim() } elseif ($current.PSObject.Properties.Name -contains 'goalNow' -and $current.goalNow) { [string]$current.goalNow } elseif ($GoalTitle) { $GoalTitle.Trim() } else { 'Resume truthful HiQ coordination' }
$resolvedAcceptance = if ($Acceptance) { $Acceptance.Trim() } elseif ($current.PSObject.Properties.Name -contains 'acceptanceTarget' -and $current.acceptanceTarget) { [string]$current.acceptanceTarget } else { $resolvedGoalNow }
$resolvedGoalTitle = if ($GoalTitle) { $GoalTitle.Trim() } else { $resolvedGoalNow }
$existingGoalId = if ($current.PSObject.Properties.Name -contains 'goalId') { Normalize-None $current.goalId } else { 'none' }
$existingGoalPath = if ($current.PSObject.Properties.Name -contains 'goalPath') { Normalize-None $current.goalPath } else { 'none' }
if ($existingGoalId -ne 'none' -and $existingGoalPath -ne 'none' -and (Test-Path -LiteralPath (Join-Path $resolvedRoot ($existingGoalPath -replace '/', [System.IO.Path]::DirectorySeparatorChar)))) {
  $goalId = $existingGoalId
  $goalPath = $existingGoalPath
} else {
  $goalId = "goal-$stampId-$(Slugify $resolvedGoalTitle)"
  $goalPath = ".hiq/goals/$goalId.md"
}
$goalFile = Join-Path $resolvedRoot ($goalPath -replace '/', [System.IO.Path]::DirectorySeparatorChar)
if (-not $HostTarget) {
  $HostTarget = if ($current.PSObject.Properties.Name -contains 'hostTarget' -and $current.hostTarget) { [string]$current.hostTarget } else { 'unknown' }
}
if (-not $HostLevel) {
  $HostLevel = if ($current.PSObject.Properties.Name -contains 'hostAutomationLevel' -and $current.hostAutomationLevel) { [string]$current.hostAutomationLevel } else { 'instruction-only' }
}
if (-not $HookAdapter) {
  $HookAdapter = if ($current.PSObject.Properties.Name -contains 'hookAdapter' -and $current.hookAdapter) { [string]$current.hookAdapter } else { 'none' }
}
if (-not $HostEvidence) {
  $HostEvidence = if ($current.PSObject.Properties.Name -contains 'hostAutomationEvidence' -and $current.hostAutomationEvidence) { [string]$current.hostAutomationEvidence } else { 'AGENTS.md' }
}
if ((Normalize-None $ActiveChange) -eq 'none' -and $current.PSObject.Properties.Name -contains 'activeChange') {
  $ActiveChange = Normalize-None $current.activeChange
}

$updates = [ordered]@{
  framework = 'hiq'
  schema = 2
  stateRevision = $stateRevision
  entrySkill = 'hiq-auto'
  entryMode = $Mode
  hostTarget = $HostTarget
  hostAutomationLevel = $HostLevel
  hostAutomationEvidence = if ((Normalize-None $HostEvidence) -eq 'none') { $null } else { $HostEvidence }
  hookAdapter = $HookAdapter
  autoStatus = $AutoStatus
  autoOwnerSkill = $Owner
  autoReason = $Reason
  manualOverride = $ManualOverride
  activeChange = if ((Normalize-None $ActiveChange) -eq 'none') { $null } else { $ActiveChange }
  stateStatus = $StateStatus
  phase = $Phase
  ownerSkill = $Owner
  nextSkill = $NextSkill
  nextStep = $NextStep
  goalId = $goalId
  goalPath = $goalPath
  goalNow = $resolvedGoalNow
  acceptanceTarget = $resolvedAcceptance
  resumeSource = $ResumeSource
  updatedAt = $stamp
}
foreach ($key in $updates.Keys) {
  if ($current.PSObject.Properties.Name -contains $key) {
    $current.$key = $updates[$key]
  } else {
    Add-Member -InputObject $current -NotePropertyName $key -NotePropertyValue $updates[$key]
  }
}
[System.IO.File]::WriteAllText($currentPath, (($current | ConvertTo-Json -Depth 8) + "`n"), [System.Text.UTF8Encoding]::new($false))

function Format-GoalValue([string]$Value, [bool]$Code = $false) {
  $normalized = Normalize-None $Value
  if ($normalized -eq 'none') { return 'none' }
  if ($Code) { return ('`' + $Value + '`') }
  return $Value
}

if (Test-Path -LiteralPath $sessionPath) {
  $sessionText = Get-Content -LiteralPath $sessionPath -Raw
  $sessionText = Set-MdField $sessionText 'updated' $stamp
  $sessionText = Set-MdField $sessionText 'state_revision' ([string]$stateRevision)
  $sessionText = Set-MdField $sessionText 'entry_skill' '`hiq-auto`'
  $sessionText = Set-MdField $sessionText 'entry_mode' $Mode
  $sessionText = Set-MdField $sessionText 'auto_status' $AutoStatus
  $sessionText = Set-MdField $sessionText 'auto_owner' ('`' + $Owner + '`')
  $sessionText = Set-MdField $sessionText 'auto_reason' $Reason
  $sessionText = Set-MdField $sessionText 'manual_override' $ManualOverride
  $sessionText = Set-MdField $sessionText 'active_change' (Format-GoalValue $ActiveChange $true)
  $sessionText = Set-MdField $sessionText 'state_status' $StateStatus
  $sessionText = Set-MdField $sessionText 'phase' $Phase
  $sessionText = Set-MdField $sessionText 'next_skill' $NextSkill
  $sessionText = Set-MdField $sessionText 'next_step' $NextStep
  $sessionText = Set-MdField $sessionText 'goal_record' ('`' + $goalPath + '`')
  $sessionText = Set-MdField $sessionText 'goal_now' $resolvedGoalNow
  $sessionText = Set-MdField $sessionText 'acceptance_target' $resolvedAcceptance
  $sessionText = Set-MdField $sessionText 'review_status' $reviewStatus
  $sessionText = Set-MdField $sessionText 'review_path' (Format-GoalValue $reviewPath $true)
  $sessionText = Set-MdField $sessionText 'reviewed_content_revision' $reviewedRevision
  $sessionText = Set-MdField $sessionText 'resume_source' $ResumeSource
  $sessionText = Set-MdField $sessionText 'last_action' "hiq-auto activation -> owner $Owner"
  $sessionText = Set-MdField $sessionText 'next_action' $NextStep
  [System.IO.File]::WriteAllText($sessionPath, $sessionText, [System.Text.UTF8Encoding]::new($false))
}

$ownerTableRow = "| $stateRevision | ``$Owner`` | $Mode | activate | $Reason | active | $NextSkill |"
if (Test-Path -LiteralPath $goalFile) {
  $goalText = Get-Content -LiteralPath $goalFile -Raw
  $goalText = Set-MdField $goalText 'state_revision' ([string]$stateRevision)
  $goalText = Set-MdField $goalText 'content_revision' ([string]$contentRevision)
  $goalText = Set-MdField $goalText 'status' $StateStatus
  $goalText = Set-MdField $goalText 'mode' $Mode
  $goalText = Set-MdField $goalText 'current_owner' ('`' + $Owner + '`')
  $goalText = Set-MdField $goalText 'next_owner' ('`' + $NextSkill + '`')
  $goalText = Set-MdField $goalText 'active_change' (Format-GoalValue $ActiveChange $true)
  $goalText = Set-MdField $goalText 'review_status' $reviewStatus
  $goalText = Set-MdField $goalText 'review_path' (Format-GoalValue $reviewPath $true)
  $goalText = Set-MdField $goalText 'reviewed_content_revision' $reviewedRevision
  $goalText = Set-MdField $goalText 'updated' $stamp
  $goalText = [regex]::Replace($goalText, '(?m)^- user request:.*$', ('- user request: ' + $resolvedGoalTitle))
  $goalText = [regex]::Replace($goalText, '(?m)^- accepted complete result:.*$', ('- accepted complete result: ' + $resolvedAcceptance))
  $goalText = [regex]::Replace($goalText, '(?m)^- goal_now:.*$', ('- goal_now: ' + $resolvedGoalNow))
  $goalText = [regex]::Replace($goalText, '(?m)^- acceptance target:.*$', ('- acceptance target: ' + $resolvedAcceptance))
  $goalText = [regex]::Replace($goalText, '(?m)^- why this owner is current:.*$', ('- why this owner is current: ' + $Reason))
  $goalText = [regex]::Replace($goalText, '(?m)^- owner lease action:.*$', ('- owner lease action: ' + $NextStep))
  $goalText = [regex]::Replace($goalText, '(?m)^- owner lease started:.*$', ('- owner lease started: ' + $stamp))
  $goalText = [regex]::Replace($goalText, '(?m)^- evidence gap:.*$', '- evidence gap: current owner output is still needed')
  $goalText = [regex]::Replace($goalText, '(?m)^- acceptance item still open:.*$', ('- acceptance item still open: ' + $resolvedAcceptance))
  if ($goalText -notmatch [regex]::Escape($ownerTableRow) -and $goalText.Contains('## 5. Acceptance ledger')) {
    $goalText = $goalText.Replace('## 5. Acceptance ledger', ($ownerTableRow + "`n`n## 5. Acceptance ledger"))
  }
} else {
  $goalText = @"
# Goal — $resolvedGoalTitle

- **goal_id**: `$goalId`
- **state_revision**: $stateRevision
- **content_revision**: $contentRevision
- **entry_skill**: `hiq-auto`
- **status**: $StateStatus
- **mode**: $Mode
- **current_owner**: `$Owner`
- **next_owner**: `$NextSkill`
- **active_change**: $(Format-GoalValue $ActiveChange $true)
- **review_status**: $reviewStatus
- **review_path**: $(Format-GoalValue $reviewPath $true)
- **reviewed_content_revision**: $reviewedRevision
- **updated**: $stamp

## 1. Requested outcome

- user request: $resolvedGoalTitle
- accepted complete result: $resolvedAcceptance
- staged delivery approved?: no
- scope downgrade approved?: no

## 2. Goal statement

- goal_now: $resolvedGoalNow
- non-goals:
- acceptance target: $resolvedAcceptance
- anti-downgrade rule: MVP / prototype / first-version / placeholder requires explicit user approval

## 3. Current truthful bottleneck

- why this owner is current: $Reason
- owner lease action: $NextStep
- owner lease started: $stamp
- evidence gap: current owner output is still needed
- explicit blocker if any:
- user-owned inputs still pending:
- acceptance item still open: $resolvedAcceptance

## 4. Owner transition ledger

| step | owner | mode | trigger | reason | result | next |
|------|-------|------|---------|--------|--------|------|
$ownerTableRow

## 5. Acceptance ledger

| item | required proof | current status | source |
|------|----------------|----------------|--------|
| A1 | $resolvedAcceptance | open | |

## 6. Evidence ledger

| time | content revision | owner | evidence | freshness | impact |
|------|------------------|-------|----------|-----------|--------|
| $stamp | $contentRevision | `$Owner` | hiq-auto activation state | fresh | goal pointer established |

## 7. User decisions

| id | question | why user-owned | status | answer |
|----|----------|----------------|--------|--------|
| D1 | | | open | |

## 8. Handoff / checkpoint

- checkpoint_required: no
- checkpoint_reason: none
- latest_checkpoint:
- resume command: `$hiq-auto`

## 9. Final verdict

- accepted?: no
- review verdict: PENDING
- review source:
- reviewed content revision: $contentRevision
- follow-up work:
"@
}
[System.IO.File]::WriteAllText($goalFile, ($goalText.TrimEnd() + "`n"), [System.Text.UTF8Encoding]::new($false))

$result = [ordered]@{
  goalId = $goalId
  goalPath = $goalPath
  ownerSkill = $Owner
  phase = $Phase
  autoStatus = $AutoStatus
  stateRevision = $stateRevision
  updatedAt = $stamp
}
if ($Json) {
  $result | ConvertTo-Json -Depth 8
} else {
  foreach ($key in @('goalId', 'goalPath', 'ownerSkill', 'phase', 'autoStatus', 'stateRevision')) {
    Write-Output ($key + '=' + $result[$key])
  }
}

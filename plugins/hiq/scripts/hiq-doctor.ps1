param(
  [string]$Root = ".",
  [string]$Mode = "",
  [string]$Extra = ""
)

$ErrorActionPreference = "Stop"

if ($Root.StartsWith('--')) {
  if ($Extra) { Write-Error 'too many options when root is omitted'; exit 2 }
  $Extra = $Mode
  $Mode = $Root
  $Root = "."
}
$allowedModes = @('', '--json', '--strict')
foreach ($option in @($Mode, $Extra)) {
  if ($option -and $option -notin $allowedModes) { Write-Error "unknown option: $option"; exit 2 }
}

function Get-FullPath([string]$Path) {
  if ([System.IO.Path]::IsPathRooted($Path)) {
    return [System.IO.Path]::GetFullPath($Path)
  }
  return [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $Path))
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
  if ($null -eq $property -or $null -eq $property.Value) { return "null" }
  if ($property.Value -is [bool]) { return $property.Value.ToString().ToLowerInvariant() }
  return [string]$property.Value
}

function Get-YamlField([string]$Key, [string]$Path) {
  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return "" }
  $pattern = '^\s*' + [regex]::Escape($Key) + ':\s*(.*)$'
  foreach ($line in Get-Content -LiteralPath $Path) {
    if ($line -match $pattern) { return $Matches[1].Trim().Trim("'").Trim('"') }
  }
  return ""
}

function Normalize-None([string]$Value) {
  if ([string]::IsNullOrWhiteSpace($Value) -or $Value -in @('none', 'null')) { return 'none' }
  return $Value
}

function Is-None([string]$Value) { return (Normalize-None $Value) -eq 'none' }

function Is-SafeRelative([string]$Value) {
  if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
  if ([System.IO.Path]::IsPathRooted($Value)) { return $false }
  $normalized = $Value.Replace('\', '/')
  if ($normalized -match '(^|/)\.\.(\/|$)') { return $false }
  return $true
}

function Normalize-RelativePath([string]$Value) {
  $relative = $Value.Replace('\\','/')
  if ($relative.StartsWith('./')) { $relative = $relative.Substring(2) }
  return $relative
}

function Resolve-Project([string]$Value) {
  return [System.IO.Path]::GetFullPath((Join-Path $script:ResolvedRoot (Normalize-RelativePath $Value)))
}

function Compare-State([string]$Category, [string]$Code, [string]$Left, [string]$Right) {
  if ((Normalize-None $Left) -ne (Normalize-None $Right)) {
    Add-Issue $Category $Code "current=$(Normalize-None $Left) session=$(Normalize-None $Right)"
  }
}

$script:State = [ordered]@{
  json = 'ok'; schema = 'ok'; reconciliation = 'ok'; owner = 'ok'; review = 'ok'; eval = 'ok'; checkpoint = 'ok'; verify = 'ok'; hook = 'ok'
}
$script:Issues = [System.Collections.Generic.List[object]]::new()
$script:IssueCount = 0
$script:StateOk = $true
function Add-Issue([string]$Category, [string]$Code, [string]$Detail) {
  $script:StateOk = $false
  $script:IssueCount++
  [void]$script:Issues.Add([ordered]@{ code = $Code; detail = $Detail })
  if ($script:State.Contains($Category)) { $script:State[$Category] = 'partial' }
}

$script:ResolvedRoot = Get-FullPath $Root
$hiq = Join-Path $ResolvedRoot ".hiq"
$hiqHome = if ($env:HIQ_HOME_DIR) { Get-FullPath $env:HIQ_HOME_DIR } else { Join-Path $env:USERPROFILE ".hiq" }
$session = Join-Path $hiq "session.md"
$current = Join-Path $hiq "current-change.json"
$config = Join-Path $hiq "config.yaml"
$manifest = Join-Path $hiq "runtime-manifest.json"
$bootstrap = Join-Path $hiq "BOOTSTRAP.md"
$memory = Join-Path $hiq "MEMORY.md"

$projectOk = $true
foreach ($file in @($bootstrap, $memory, $session, $config, $current, $manifest)) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { $projectOk = $false }
}

$activeChangeSession = Get-MdField "active_change" $session
$changeDirStatus = "none"
if (-not (Is-None $activeChangeSession)) {
  if ((Is-SafeRelative $activeChangeSession) -and (Test-Path -LiteralPath (Resolve-Project $activeChangeSession) -PathType Container)) {
    $changeDirStatus = "ok"
  } else {
    $changeDirStatus = "missing"
    $projectOk = $false
  }
}

$codegraphBin = Join-Path $hiqHome "bin\codegraph.exe"
$codegraphStatus = Check-File $codegraphBin
$codegraphIndex = Check-Dir (Join-Path $ResolvedRoot ".codegraph")
$globalScriptsStatus = Check-File (Join-Path $hiqHome "scripts\hiq-run.cmd")
$globalStatusStatus = Check-File (Join-Path $hiqHome "scripts\hiq-status.cmd")
$globalDoctorStatus = Check-File (Join-Path $hiqHome "scripts\hiq-doctor.cmd")
$globalHookStatus = Check-File (Join-Path $hiqHome "scripts\hiq-hook.cmd")
$runtimeOk = ($codegraphStatus -eq 'ok' -and $codegraphIndex -eq 'ok' -and $globalScriptsStatus -eq 'ok' -and $globalStatusStatus -eq 'ok' -and $globalDoctorStatus -eq 'ok' -and $globalHookStatus -eq 'ok')

$currentObj = $null
if (-not (Test-Path -LiteralPath $current -PathType Leaf)) {
  Add-Issue json state.current_missing ".hiq/current-change.json is missing"
} else {
  try {
    $currentObj = Get-Content -LiteralPath $current -Raw | ConvertFrom-Json
  } catch {
    Add-Issue json state.json_invalid "current-change.json cannot be parsed as JSON"
  }
}

$framework = Get-JsonValue $currentObj 'framework'
$schema = Get-JsonValue $currentObj 'schema'
if ($framework -ne 'hiq') { Add-Issue schema state.framework_invalid 'framework must be hiq' }
if ($schema -ne '2') { Add-Issue schema state.schema_legacy "schema=$schema; run hiq-init refresh to add schema 2 fields" }
$requiredKeys = @('stateRevision','changeId','stateStatus','contentRevision','entrySkill','entryMode','hostTarget','hostAutomationLevel','hostAutomationEvidence','hookProtocolVersion','hookCoreStatus','hookAdapter','hookLastEvent','hookLastRunPath','hookLastRunAt','hookLastRunStatus','autoStatus','autoOwnerSkill','autoReason','manualOverride','activeChange','phase','ownerSkill','nextSkill','nextStep','goalId','goalPath','goalNow','acceptanceTarget','reviewStatus','reviewPath','reviewedContentRevision','acceptedAt','evalApplicability','evalStatus','evalRunPath','evalReason','checkpointRequired','checkpointReason','resumeSource','latestCheckpoint','verifyCommandsSource','verifyCwd','verifyStatus','verifyWaiverReason','updatedAt')
foreach ($key in $requiredKeys) {
  if ($null -eq $currentObj -or $null -eq $currentObj.PSObject.Properties[$key]) { Add-Issue schema "state.field_missing.$key" "$key is missing" }
}

$stateRevision = Get-JsonValue $currentObj 'stateRevision'
$changeId = Get-JsonValue $currentObj 'changeId'
$stateStatus = Get-JsonValue $currentObj 'stateStatus'
$contentRevision = Get-JsonValue $currentObj 'contentRevision'
$entrySkill = Get-JsonValue $currentObj 'entrySkill'
$entryMode = Get-JsonValue $currentObj 'entryMode'
$hostTarget = Get-JsonValue $currentObj 'hostTarget'
$hostLevel = Get-JsonValue $currentObj 'hostAutomationLevel'
$hostEvidence = Get-JsonValue $currentObj 'hostAutomationEvidence'
$hookProtocol = Get-JsonValue $currentObj 'hookProtocolVersion'
$hookCore = Get-JsonValue $currentObj 'hookCoreStatus'
$hookAdapter = Get-JsonValue $currentObj 'hookAdapter'
$hookLastEvent = Get-JsonValue $currentObj 'hookLastEvent'
$hookLastRun = Get-JsonValue $currentObj 'hookLastRunPath'
$hookLastRunAt = Get-JsonValue $currentObj 'hookLastRunAt'
$hookLastStatus = Get-JsonValue $currentObj 'hookLastRunStatus'
$autoStatus = Get-JsonValue $currentObj 'autoStatus'
$autoOwner = Get-JsonValue $currentObj 'autoOwnerSkill'
$manualOverride = Get-JsonValue $currentObj 'manualOverride'
$activeChange = Get-JsonValue $currentObj 'activeChange'
$phase = Get-JsonValue $currentObj 'phase'
$ownerSkill = Get-JsonValue $currentObj 'ownerSkill'
$nextSkill = Get-JsonValue $currentObj 'nextSkill'
$nextStep = Get-JsonValue $currentObj 'nextStep'
$goalId = Get-JsonValue $currentObj 'goalId'
$goalPath = Get-JsonValue $currentObj 'goalPath'
$goalNow = Get-JsonValue $currentObj 'goalNow'
$acceptanceTarget = Get-JsonValue $currentObj 'acceptanceTarget'
$reviewStatus = Get-JsonValue $currentObj 'reviewStatus'
$reviewPath = Get-JsonValue $currentObj 'reviewPath'
$reviewedRevision = Get-JsonValue $currentObj 'reviewedContentRevision'
$acceptedAt = Get-JsonValue $currentObj 'acceptedAt'
$evalApplicability = Get-JsonValue $currentObj 'evalApplicability'
$evalStatus = Get-JsonValue $currentObj 'evalStatus'
$evalRunPath = Get-JsonValue $currentObj 'evalRunPath'
$evalReason = Get-JsonValue $currentObj 'evalReason'
$checkpointRequired = Get-JsonValue $currentObj 'checkpointRequired'
$checkpointReason = Get-JsonValue $currentObj 'checkpointReason'
$resumeSource = Get-JsonValue $currentObj 'resumeSource'
$latestCheckpoint = Get-JsonValue $currentObj 'latestCheckpoint'
$verifySource = Get-JsonValue $currentObj 'verifyCommandsSource'
$verifyCwd = Get-JsonValue $currentObj 'verifyCwd'
$verifyStatus = Get-JsonValue $currentObj 'verifyStatus'
$verifyWaiver = Get-JsonValue $currentObj 'verifyWaiverReason'

if ($stateStatus -notin @('idle','active','blocked','handoff','accepted')) { Add-Issue schema state.status_invalid "stateStatus=$stateStatus" }
if ($hostLevel -notin @('unavailable','instruction-only','adapter-available','turn-scoped','persistent')) { Add-Issue schema state.host_level_invalid "hostAutomationLevel=$hostLevel" }
if ($hookCore -notin @('missing','available','running','failed')) { Add-Issue hook state.hook_core_invalid "hookCoreStatus=$hookCore" }
if ($hookLastEvent -notin @('','none','null','pre-session','pre-tool','post-tool','pre-final','checkpoint','status')) { Add-Issue hook state.hook_event_invalid "hookLastEvent=$hookLastEvent" }
if ($hookLastStatus -notin @('none','pass','fail')) { Add-Issue hook state.hook_status_invalid "hookLastRunStatus=$hookLastStatus" }
if ($autoStatus -notin @('available','active','manual','disabled','blocked','accepted','handoff')) { Add-Issue schema state.auto_status_invalid "autoStatus=$autoStatus" }
if ($reviewStatus -notin @('not-run','pending','pass','partial','fail','blocked')) { Add-Issue schema state.review_status_invalid "reviewStatus=$reviewStatus" }
if ($evalApplicability -notin @('unknown','not-applicable','optional','required')) { Add-Issue schema state.eval_applicability_invalid "evalApplicability=$evalApplicability" }
if ($evalStatus -notin @('not-run','running','pass','fail','blocked','not-applicable')) { Add-Issue schema state.eval_status_invalid "evalStatus=$evalStatus" }
if ($checkpointReason -notin @('none','handoff','compaction','context-pressure')) { Add-Issue schema state.checkpoint_reason_invalid "checkpointReason=$checkpointReason" }
if ($resumeSource -notin @('fresh','session','checkpoint','manual')) { Add-Issue schema state.resume_source_invalid "resumeSource=$resumeSource" }
if ($verifyStatus -notin @('unset','valid','stale','unrunnable','waived')) { Add-Issue schema state.verify_status_invalid "verifyStatus=$verifyStatus" }

Compare-State reconciliation state.revision_mismatch $stateRevision (Get-MdField 'state_revision' $session)
Compare-State reconciliation state.change_id_mismatch $changeId (Get-MdField 'change_id' $session)
Compare-State reconciliation state.status_mismatch $stateStatus (Get-MdField 'state_status' $session)
Compare-State reconciliation state.content_revision_mismatch $contentRevision (Get-MdField 'content_revision' $session)
Compare-State reconciliation state.entry_skill_mismatch $entrySkill (Get-MdField 'entry_skill' $session)
Compare-State reconciliation state.entry_mode_mismatch $entryMode (Get-MdField 'entry_mode' $session)
Compare-State reconciliation state.host_target_mismatch $hostTarget (Get-MdField 'host_target' $session)
Compare-State reconciliation state.host_level_mismatch $hostLevel (Get-MdField 'host_automation_level' $session)
Compare-State reconciliation state.host_evidence_mismatch $hostEvidence (Get-MdField 'host_automation_evidence' $session)
Compare-State reconciliation state.hook_protocol_mismatch $hookProtocol (Get-MdField 'hook_protocol_version' $session)
Compare-State reconciliation state.hook_core_mismatch $hookCore (Get-MdField 'hook_core_status' $session)
Compare-State reconciliation state.hook_adapter_mismatch $hookAdapter (Get-MdField 'hook_adapter' $session)
Compare-State reconciliation state.hook_event_mismatch $hookLastEvent (Get-MdField 'hook_last_event' $session)
Compare-State reconciliation state.hook_run_mismatch $hookLastRun (Get-MdField 'hook_last_run' $session)
Compare-State reconciliation state.hook_status_mismatch $hookLastStatus (Get-MdField 'hook_last_status' $session)
Compare-State reconciliation state.auto_status_mismatch $autoStatus (Get-MdField 'auto_status' $session)
Compare-State reconciliation state.auto_owner_mismatch $autoOwner (Get-MdField 'auto_owner' $session)
Compare-State reconciliation state.manual_override_mismatch $manualOverride (Get-MdField 'manual_override' $session)
Compare-State reconciliation state.active_change_mismatch $activeChange $activeChangeSession
Compare-State reconciliation state.phase_mismatch $phase (Get-MdField 'phase' $session)
Compare-State reconciliation state.next_skill_mismatch $nextSkill (Get-MdField 'next_skill' $session)
Compare-State reconciliation state.next_step_mismatch $nextStep (Get-MdField 'next_step' $session)
Compare-State reconciliation state.goal_path_mismatch $goalPath (Get-MdField 'goal_record' $session)
Compare-State reconciliation state.goal_now_mismatch $goalNow (Get-MdField 'goal_now' $session)
Compare-State reconciliation state.acceptance_target_mismatch $acceptanceTarget (Get-MdField 'acceptance_target' $session)
Compare-State reconciliation state.review_status_mismatch $reviewStatus (Get-MdField 'review_status' $session)
Compare-State reconciliation state.review_path_mismatch $reviewPath (Get-MdField 'review_path' $session)
Compare-State reconciliation state.review_revision_mismatch $reviewedRevision (Get-MdField 'reviewed_content_revision' $session)
Compare-State reconciliation state.eval_applicability_mismatch $evalApplicability (Get-MdField 'eval_applicability' $session)
Compare-State reconciliation state.eval_status_mismatch $evalStatus (Get-MdField 'eval_status' $session)
Compare-State reconciliation state.eval_run_mismatch $evalRunPath (Get-MdField 'eval_run_path' $session)
$sessionCheckpointRequired = Get-MdField 'checkpoint_required' $session
if ($sessionCheckpointRequired -eq 'yes') { $sessionCheckpointRequired = 'true' } elseif ($sessionCheckpointRequired -eq 'no') { $sessionCheckpointRequired = 'false' }
Compare-State reconciliation state.checkpoint_required_mismatch $checkpointRequired $sessionCheckpointRequired
Compare-State reconciliation state.checkpoint_reason_mismatch $checkpointReason (Get-MdField 'checkpoint_reason' $session)
Compare-State reconciliation state.resume_source_mismatch $resumeSource (Get-MdField 'resume_source' $session)
Compare-State reconciliation state.checkpoint_mismatch $latestCheckpoint (Get-MdField 'latest_checkpoint' $session)
Compare-State reconciliation state.verify_source_mismatch $verifySource (Get-MdField 'verify_commands_source' $session)
Compare-State reconciliation state.verify_cwd_mismatch $verifyCwd (Get-MdField 'verify_cwd' $session)
Compare-State reconciliation state.verify_status_mismatch $verifyStatus (Get-MdField 'verify_status' $session)

if (-not (Is-None $activeChange)) {
  if (-not (Is-SafeRelative $activeChange) -or -not (Test-Path -LiteralPath (Resolve-Project $activeChange) -PathType Container)) { Add-Issue reconciliation state.active_change_missing "activeChange=$activeChange" }
  $activeId = [System.IO.Path]::GetFileName($activeChange.TrimEnd('/','\'))
  if (-not (Is-None $changeId) -and $changeId -ne $activeId) { Add-Issue reconciliation state.change_id_path_mismatch "changeId=$changeId activeChange=$activeChange" }
} elseif (-not (Is-None $changeId)) {
  Add-Issue reconciliation state.change_without_path "changeId=$changeId but activeChange is empty"
}

$expectedOwner = switch ($phase) {
  idle { 'hiq-session' }; init { 'hiq-init' }; install { 'hiq-install' }; grill { 'hiq-grill' }; implement { 'hiq-implement' }; debug { 'hiq-debug' }; review { 'hiq-review' }; evolve { 'hiq-evolve' }; knowledge { 'hiq-knowledge' }; skill { 'hiq-skill' }; default { Add-Issue owner state.phase_invalid "phase=$phase"; '' }
}
if ($expectedOwner -and $ownerSkill -ne $expectedOwner) { Add-Issue owner state.owner_phase_mismatch "phase=$phase ownerSkill=$ownerSkill expected=$expectedOwner" }
if (Is-None $manualOverride) {
  if ($autoOwner -ne $ownerSkill) { Add-Issue owner state.auto_owner_lease_mismatch "autoOwnerSkill=$autoOwner ownerSkill=$ownerSkill" }
} elseif ($ownerSkill -ne $manualOverride) {
  Add-Issue owner state.manual_override_owner_mismatch "manualOverride=$manualOverride ownerSkill=$ownerSkill"
}
if ($hostLevel -in @('turn-scoped','persistent')) {
  if (Is-None $hostEvidence -or -not (Is-SafeRelative $hostEvidence) -or -not (Test-Path -LiteralPath (Resolve-Project $hostEvidence) -PathType Leaf)) {
    Add-Issue owner state.host_evidence_missing "hostAutomationEvidence=$hostEvidence"
  }
} elseif (-not (Is-None $hostEvidence)) {
  if (-not (Is-SafeRelative $hostEvidence) -or -not (Test-Path -LiteralPath (Resolve-Project $hostEvidence) -PathType Leaf)) {
    Add-Issue owner state.host_evidence_missing "hostAutomationEvidence=$hostEvidence"
  } else {
    $hostText = Get-Content -LiteralPath (Resolve-Project $hostEvidence) -Raw
    if ($hostText -notmatch '(?m)^# HiQ Project Rule' -or $hostText -notmatch 'hiq-auto') { Add-Issue owner state.host_evidence_not_hiq "hostAutomationEvidence=$hostEvidence does not contain the HiQ auto contract" }
  }
}

if ($hookProtocol -ne '1') {
  Add-Issue hook state.hook_protocol_invalid "hookProtocolVersion=$hookProtocol"
}
if ($hookCore -eq 'available' -and $globalHookStatus -ne 'ok') {
  Add-Issue hook state.hook_core_missing 'hookCoreStatus=available but hiq-hook.cmd is missing from runtime scripts'
}
if ($hostLevel -in @('turn-scoped','persistent')) {
  $hookRunNormalized = $hookLastRun.Replace('\','/')
  if ((Is-None $hookLastRun) -or -not (Is-SafeRelative $hookLastRun) -or -not $hookRunNormalized.StartsWith('.hiq/hooks/runs/') -or -not (Test-Path -LiteralPath (Resolve-Project $hookLastRun) -PathType Leaf)) {
    Add-Issue hook state.hook_run_missing "hookLastRunPath=$hookLastRun"
  }
  if ($hookLastStatus -ne 'pass') { Add-Issue hook state.hook_run_not_pass "hookLastRunStatus=$hookLastStatus" }
  if ($hostEvidence -ne $hookLastRun) { Add-Issue hook state.hook_evidence_mismatch "hostAutomationEvidence=$hostEvidence hookLastRunPath=$hookLastRun" }
} elseif ($hostLevel -eq 'instruction-only' -and -not (Is-None $hookLastRun)) {
  Add-Issue hook state.hook_run_without_level "hookLastRunPath=$hookLastRun requires hostAutomationLevel turn-scoped or persistent"
}

$reviewFile = $null
if (-not (Is-None $reviewPath)) {
  if ((Is-SafeRelative $reviewPath) -and (Test-Path -LiteralPath (Resolve-Project $reviewPath) -PathType Leaf)) { $reviewFile = Resolve-Project $reviewPath } else { Add-Issue review state.review_path_missing "reviewPath=$reviewPath" }
}
if ($ownerSkill -eq 'hiq-review' -or $phase -eq 'review') {
  if (-not $reviewFile -or $reviewStatus -eq 'not-run') { Add-Issue review state.review_owner_without_artifact 'hiq-review ownership requires a current review artifact' }
}
if ($stateStatus -eq 'accepted' -or $autoStatus -eq 'accepted') {
  if ($reviewStatus -ne 'pass') { Add-Issue review state.accepted_without_review_pass "reviewStatus=$reviewStatus" }
  if (Is-None $acceptedAt) { Add-Issue review state.accepted_without_timestamp 'accepted state requires acceptedAt' }
  if ((Is-None $changeId) -or (Is-None $activeChange)) { Add-Issue review state.accepted_without_change 'accepted state requires changeId and activeChange' }
  if (-not $reviewFile) { Add-Issue review state.accepted_without_review_path 'accepted state requires reviewPath' } else {
    $reviewVerdict = Get-MdField 'verdict' $reviewFile
    $reviewRevision = Get-MdField 'reviewed_content_revision' $reviewFile
    $reviewChangeId = Get-MdField 'change_id' $reviewFile
    if ($reviewVerdict -ne 'PASS') { Add-Issue review state.review_verdict_not_pass "review verdict=$reviewVerdict" }
    if ($reviewRevision -ne $contentRevision -or $reviewedRevision -ne $contentRevision) { Add-Issue review state.review_revision_stale "contentRevision=$contentRevision stateReviewed=$reviewedRevision artifactReviewed=$reviewRevision" }
    if (-not (Is-None $changeId) -and $reviewChangeId -ne $changeId) { Add-Issue review state.review_change_mismatch "changeId=$changeId artifactChangeId=$reviewChangeId" }
    $reviewNormalized = Normalize-RelativePath $reviewPath
    $activeNormalized = (Normalize-RelativePath $activeChange).TrimEnd('/')
    $expectedReviewPath = "$activeNormalized/review.md"
    if (-not (Is-None $activeChange) -and $reviewNormalized -ne $expectedReviewPath) { Add-Issue review state.review_path_not_canonical "reviewPath=$reviewPath expected=$expectedReviewPath" }
  }
}

$evalFile = $null
if (-not (Is-None $evalRunPath) -and (Is-SafeRelative $evalRunPath) -and (Test-Path -LiteralPath (Resolve-Project $evalRunPath) -PathType Leaf)) { $evalFile = Resolve-Project $evalRunPath }
if ($evalFile) {
  $evalRunNormalized = Normalize-RelativePath $evalRunPath
  if (-not $evalRunNormalized.StartsWith('.hiq/eval/runs/')) { Add-Issue eval state.eval_run_outside_root "evalRunPath=$evalRunPath" }
  $evalReportStatus = Get-MdField 'status' $evalFile
  $evalReportChange = Get-MdField 'change' $evalFile
  $evalReportChangeId = Get-MdField 'change_id' $evalFile
  $evalReportRevision = Get-MdField 'content_revision' $evalFile
  if ($evalStatus -eq 'pass' -and $evalReportStatus -ne 'done') { Add-Issue eval state.eval_report_not_done "eval report status=$evalReportStatus" }
  if (-not (Is-None $changeId) -and $evalReportChangeId -ne $changeId) { Add-Issue eval state.eval_change_mismatch "changeId=$changeId evalChangeId=$evalReportChangeId" }
  if (-not (Is-None $activeChange) -and (Normalize-None $evalReportChange) -ne (Normalize-None $activeChange)) { Add-Issue eval state.eval_change_path_mismatch "activeChange=$activeChange evalChange=$evalReportChange" }
  if ($evalStatus -eq 'pass' -and $evalReportRevision -ne $contentRevision) { Add-Issue eval state.eval_revision_stale "contentRevision=$contentRevision evalRevision=$evalReportRevision" }
}
switch ($evalApplicability) {
  unknown { Add-Issue eval state.eval_applicability_unknown 'classify eval as not-applicable, optional, or required' }
  not-applicable { if ($evalStatus -ne 'not-applicable' -or [string]::IsNullOrWhiteSpace($evalReason) -or $evalReason -eq 'null') { Add-Issue eval state.eval_not_applicable_incomplete 'not-applicable eval requires matching status and reason' } }
  optional { if ($evalStatus -in @('pass','fail') -and -not $evalFile) { Add-Issue eval state.eval_run_missing "evalStatus=$evalStatus evalRunPath=$evalRunPath" } }
  required { if ($evalStatus -ne 'pass') { Add-Issue eval state.eval_required_not_passed "evalStatus=$evalStatus" }; if (-not $evalFile) { Add-Issue eval state.eval_required_run_missing "evalRunPath=$evalRunPath" } }
}

$checkpointNeeded = ($checkpointRequired -eq 'true' -or $stateStatus -eq 'handoff' -or $autoStatus -eq 'handoff' -or $entryMode -eq 'handoff' -or $checkpointReason -ne 'none')
if ($checkpointNeeded -and (Is-None $latestCheckpoint)) { Add-Issue checkpoint state.checkpoint_required_missing "checkpointReason=$checkpointReason" }
if (-not (Is-None $latestCheckpoint)) {
  $checkpointNormalized = $latestCheckpoint.Replace('\','/')
  if (-not (Is-SafeRelative $latestCheckpoint) -or -not $checkpointNormalized.StartsWith('context-checkpoints/') -or -not (Test-Path -LiteralPath (Resolve-Project $latestCheckpoint) -PathType Leaf)) { Add-Issue checkpoint state.checkpoint_path_invalid "latestCheckpoint=$latestCheckpoint" }
}
if ($resumeSource -eq 'checkpoint' -and (Is-None $latestCheckpoint)) { Add-Issue checkpoint state.resume_checkpoint_missing 'resumeSource=checkpoint requires latestCheckpoint' }

$verifyCommands = Get-MdField 'verify_commands' $session
$verifyBase = $ResolvedRoot
if (-not (Is-None $verifyCwd)) {
  if (-not (Is-SafeRelative $verifyCwd) -or -not (Test-Path -LiteralPath (Resolve-Project $verifyCwd) -PathType Container)) {
    Add-Issue verify state.verify_cwd_missing "verifyCwd=$verifyCwd"
  } else {
    $verifyBase = Resolve-Project $verifyCwd
  }
}
if (-not (Is-None $verifySource)) {
  if (-not (Is-SafeRelative $verifySource) -or -not (Test-Path -LiteralPath (Resolve-Project $verifySource) -PathType Leaf)) { Add-Issue verify state.verify_source_missing "verifyCommandsSource=$verifySource" }
}
switch ($verifyStatus) {
  unset { if ([string]::IsNullOrWhiteSpace($verifyWaiver) -or $verifyWaiver -eq 'null') { Add-Issue verify state.verify_waiver_missing "verifyStatus=$verifyStatus requires verifyWaiverReason" } }
  waived { if ([string]::IsNullOrWhiteSpace($verifyWaiver) -or $verifyWaiver -eq 'null') { Add-Issue verify state.verify_waiver_missing 'verifyStatus=waived requires verifyWaiverReason' } }
  valid { if ([string]::IsNullOrWhiteSpace($verifyCommands)) { Add-Issue verify state.verify_commands_missing 'verifyStatus=valid but verify_commands is empty' } }
  stale { Add-Issue verify state.verify_not_runnable 'verifyStatus=stale' }
  unrunnable { Add-Issue verify state.verify_not_runnable 'verifyStatus=unrunnable' }
}
if (-not [string]::IsNullOrWhiteSpace($verifyCommands)) {
  foreach ($token0 in ($verifyCommands -split '\s+')) {
    $token = $token0.Trim('`','"',"'",',',';','(',')')
    if ([string]::IsNullOrWhiteSpace($token) -or $token.StartsWith('-') -or $token -match '^(https?|\$|%|<|>)') { continue }
    if ($token -match '[/\\]|\.(json|yaml|yml|toml|md|py|js|ts|sh|ps1|cmd|exe)$') {
      if ([System.IO.Path]::IsPathRooted($token)) { continue }
      $relativeToken = Normalize-RelativePath $token
      $candidateCwd = [System.IO.Path]::GetFullPath((Join-Path $verifyBase $relativeToken))
      $candidateRoot = [System.IO.Path]::GetFullPath((Join-Path $ResolvedRoot $relativeToken))
      if (-not (Test-Path -LiteralPath $candidateCwd) -and -not (Test-Path -LiteralPath $candidateRoot)) { Add-Issue verify state.verify_path_missing "verify command references $token" }
    }
  }
}

if (-not (Is-None $goalPath) -or -not (Is-None $goalId)) {
  $goalFile = $null
  if ((Is-SafeRelative $goalPath) -and (Test-Path -LiteralPath (Resolve-Project $goalPath) -PathType Leaf)) { $goalFile = Resolve-Project $goalPath } else { Add-Issue reconciliation state.goal_path_missing "goalPath=$goalPath" }
  if ($goalFile) {
    Compare-State reconciliation state.goal_id_file_mismatch $goalId (Get-MdField 'goal_id' $goalFile)
    Compare-State reconciliation state.goal_revision_mismatch $stateRevision (Get-MdField 'state_revision' $goalFile)
    Compare-State reconciliation state.goal_content_revision_mismatch $contentRevision (Get-MdField 'content_revision' $goalFile)
    Compare-State reconciliation state.goal_owner_mismatch $ownerSkill (Get-MdField 'current_owner' $goalFile)
    Compare-State reconciliation state.goal_next_owner_mismatch $nextSkill (Get-MdField 'next_owner' $goalFile)
    Compare-State reconciliation state.goal_active_change_mismatch $activeChange (Get-MdField 'active_change' $goalFile)
    Compare-State reconciliation state.goal_review_status_mismatch $reviewStatus (Get-MdField 'review_status' $goalFile)
    Compare-State reconciliation state.goal_review_path_mismatch $reviewPath (Get-MdField 'review_path' $goalFile)
    Compare-State reconciliation state.goal_review_revision_mismatch $reviewedRevision (Get-MdField 'reviewed_content_revision' $goalFile)
    Compare-State reconciliation state.goal_checkpoint_mismatch $latestCheckpoint (Get-MdField 'latest_checkpoint' $goalFile)
  }
} elseif ($entrySkill -eq 'hiq-auto' -and $autoStatus -match '^(active|accepted|handoff)$') {
  Add-Issue reconciliation state.goal_required_missing "autoStatus=$autoStatus requires goalPath and goalId"
}

$configSchema = Get-YamlField 'schema' $config
$configEvalEnabled = Get-YamlField 'eval_enabled' $config
$configReviewRequired = Get-YamlField 'require_review_acceptance' $config
if ($configSchema -ne '2') { Add-Issue schema state.config_schema_legacy "config schema=$configSchema" }
if ($configEvalEnabled -eq 'true' -and [string]::IsNullOrWhiteSpace($evalApplicability)) { Add-Issue eval state.eval_truth_missing 'eval capability is enabled but applicability is absent' }
if ($configReviewRequired -eq 'true' -and $stateStatus -eq 'accepted' -and $reviewStatus -ne 'pass') { Add-Issue review state.review_policy_unsatisfied 'require_review_acceptance=true' }

$stateOverall = if ($script:StateOk) { 'ok' } else { 'partial' }
$overall = if ($projectOk -and $runtimeOk -and $script:StateOk) { 'ok' } else { 'partial' }
$jsonMode = @($Mode,$Extra) -contains '--json'
$strictMode = @($Mode,$Extra) -contains '--strict'

if ($jsonMode) {
  [ordered]@{
    root = $ResolvedRoot
    project = [ordered]@{ bootstrap = Check-File $bootstrap; memory = Check-File $memory; session = Check-File $session; config = Check-File $config; currentChange = Check-File $current; manifest = Check-File $manifest; evalRoot = Check-Dir (Join-Path $hiq 'eval'); activeChangeDir = $changeDirStatus }
    runtime = [ordered]@{ hiqHome = $hiqHome; codegraphBin = $codegraphStatus; codegraphIndex = $codegraphIndex; hiqRun = $globalScriptsStatus; hiqStatus = $globalStatusStatus; hiqDoctor = $globalDoctorStatus; hiqHook = $globalHookStatus }
    state = [ordered]@{ json = $script:State.json; schema = $script:State.schema; reconciliation = $script:State.reconciliation; owner = $script:State.owner; review = $script:State.review; eval = $script:State.eval; checkpoint = $script:State.checkpoint; verify = $script:State.verify; hook = $script:State.hook; issueCount = $script:IssueCount; issues = @($script:Issues) }
    stateOverall = $stateOverall
    overall = $overall
  } | ConvertTo-Json -Depth 8
} else {
  Write-Output "hiq_root=$ResolvedRoot"
  Write-Output "project.bootstrap=$(Check-File $bootstrap)"
  Write-Output "project.memory=$(Check-File $memory)"
  Write-Output "project.session=$(Check-File $session)"
  Write-Output "project.config=$(Check-File $config)"
  Write-Output "project.current_change=$(Check-File $current)"
  Write-Output "project.manifest=$(Check-File $manifest)"
  Write-Output "project.eval_root=$(Check-Dir (Join-Path $hiq 'eval'))"
  Write-Output "project.active_change_dir=$changeDirStatus"
  Write-Output "runtime.hiq_home=$hiqHome"
  Write-Output "runtime.codegraph_bin=$codegraphStatus"
  Write-Output "runtime.codegraph_index=$codegraphIndex"
  Write-Output "runtime.hiq_run=$globalScriptsStatus"
  Write-Output "runtime.hiq_status=$globalStatusStatus"
  Write-Output "runtime.hiq_doctor=$globalDoctorStatus"
  Write-Output "runtime.hiq_hook=$globalHookStatus"
  foreach ($key in $script:State.Keys) { Write-Output "state.$key=$($script:State[$key])" }
  Write-Output "state.issue_count=$script:IssueCount"
  foreach ($issue in $script:Issues) { Write-Output "issue.$($issue.code)=$($issue.detail)" }
  Write-Output "state.overall=$stateOverall"
  Write-Output "overall=$overall"
}

if ($strictMode -and $overall -ne 'ok') { exit 1 }

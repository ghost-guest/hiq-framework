param(
  [string]$Root = ".",
  [string]$Event = "",
  [string]$HostName = "generic",
  [string]$Adapter = "generic",
  [string]$Tool = "",
  [string]$ContextPressure = "unknown",
  [switch]$Json
)

$ErrorActionPreference = "Stop"

if ($Root -in @('pre-session','pre-tool','post-tool','pre-final','checkpoint','status')) {
  $Event = $Root
  $Root = "."
}
if (-not $Event) {
  Write-Error "usage: hiq-hook.ps1 [project-root] pre-session|pre-tool|post-tool|pre-final|checkpoint|status [-HostName NAME] [-Adapter NAME] [-Tool NAME] [-ContextPressure LEVEL] [-Json]"
  exit 2
}
if ($Event -notin @('pre-session','pre-tool','post-tool','pre-final','checkpoint','status')) {
  Write-Error "unknown hook event: $Event"
  exit 2
}

function Get-FullPath([string]$Path) {
  if ([System.IO.Path]::IsPathRooted($Path)) {
    return [System.IO.Path]::GetFullPath($Path)
  }
  return [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $Path))
}

function Set-MdField([string]$Text, [string]$Key, [string]$Value) {
  $pattern = '(?m)^- \*\*' + [regex]::Escape($Key) + '\*\*:.*$'
  $line = "- **$Key**: $Value"
  if ([regex]::IsMatch($Text, $pattern)) {
    return [regex]::Replace($Text, $pattern, $line)
  }
  if ($Key.StartsWith('hook_')) {
    $marker = '- **host_automation_evidence**:'
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.AddRange(($Text -split "`r?`n"))
    for ($i = 0; $i -lt $lines.Count; $i++) {
      if ($lines[$i].StartsWith($marker)) {
        $lines.Insert($i + 1, $line)
        return (($lines -join "`n") + "`n")
      }
    }
  }
  return $Text
}

$resolvedRoot = Get-FullPath $Root
$hiq = Join-Path $resolvedRoot '.hiq'
$currentPath = Join-Path $hiq 'current-change.json'
$sessionPath = Join-Path $hiq 'session.md'
$hookStatePath = Join-Path $hiq 'hooks\hook-state.json'
$runDir = Join-Path $hiq 'hooks\runs'
$adapterDir = Join-Path $hiq 'hooks\adapters'
New-Item -ItemType Directory -Path $runDir -Force | Out-Null
New-Item -ItemType Directory -Path $adapterDir -Force | Out-Null

$stamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"
$runStamp = Get-Date -Format "yyyyMMdd-HHmmss"
$runRel = ".hiq/hooks/runs/$runStamp-$Event.json"
$runProjectRelative = $runRel
if ($runProjectRelative.StartsWith('./')) {
  $runProjectRelative = $runProjectRelative.Substring(2)
}
$runPath = Join-Path $resolvedRoot ($runProjectRelative -replace '/', [System.IO.Path]::DirectorySeparatorChar)
$requiredActions = @()
if ($Event -eq 'checkpoint' -or $ContextPressure -in @('high','critical')) {
  $requiredActions = @('write-context-checkpoint')
}

$run = [ordered]@{
  framework = 'hiq'
  schema = 1
  event = $Event
  host = $HostName
  adapter = $Adapter
  tool = $Tool
  contextPressure = $ContextPressure
  cwd = $resolvedRoot
  allow = $true
  requiredActions = $requiredActions
  ownerSkill = 'hiq-auto'
  status = 'pass'
  createdAt = $stamp
}
[System.IO.File]::WriteAllText($runPath, (($run | ConvertTo-Json -Depth 8) + "`n"), [System.Text.UTF8Encoding]::new($false))

if ($Event -ne 'status') {
  if (Test-Path -LiteralPath $currentPath) {
    $current = Get-Content -LiteralPath $currentPath -Raw | ConvertFrom-Json
  } else {
    $current = [pscustomobject]@{ framework = 'hiq'; schema = 2 }
  }
  $updates = [ordered]@{
    hostTarget = $HostName
    hostAutomationLevel = 'turn-scoped'
    hostAutomationEvidence = $runRel
    hookProtocolVersion = 1
    hookCoreStatus = 'available'
    hookAdapter = $Adapter
    hookLastEvent = $Event
    hookLastRunPath = $runRel
    hookLastRunAt = $stamp
    hookLastRunStatus = 'pass'
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
  $hookState = [ordered]@{
    framework = 'hiq'
    schema = 1
    protocolVersion = 1
    coreStatus = 'available'
    adapter = $Adapter
    host = $HostName
    automationLevel = 'turn-scoped'
    evidenceRoot = '.hiq/hooks/runs'
    lastEvent = $Event
    lastRunPath = $runRel
    lastRunAt = $stamp
    lastRunStatus = 'pass'
  }
  [System.IO.File]::WriteAllText($hookStatePath, (($hookState | ConvertTo-Json -Depth 8) + "`n"), [System.Text.UTF8Encoding]::new($false))

  if (Test-Path -LiteralPath $sessionPath) {
    $text = Get-Content -LiteralPath $sessionPath -Raw
    $text = Set-MdField $text 'updated' $stamp
    $text = Set-MdField $text 'host_target' $HostName
    $text = Set-MdField $text 'host_automation_level' 'turn-scoped'
    $text = Set-MdField $text 'host_automation_evidence' ('`' + $runRel + '`')
    $text = Set-MdField $text 'hook_protocol_version' '1'
    $text = Set-MdField $text 'hook_core_status' 'available'
    $text = Set-MdField $text 'hook_adapter' $Adapter
    $text = Set-MdField $text 'hook_last_event' $Event
    $text = Set-MdField $text 'hook_last_run' ('`' + $runRel + '`')
    $text = Set-MdField $text 'hook_last_status' 'pass'
    [System.IO.File]::WriteAllText($sessionPath, $text, [System.Text.UTF8Encoding]::new($false))
  }
}

if ($Json) {
  Get-Content -LiteralPath $runPath -Raw
} else {
  Write-Output "hook.event=$Event"
  Write-Output "hook.host=$HostName"
  Write-Output "hook.adapter=$Adapter"
  Write-Output "hook.run=$runRel"
  Write-Output 'hook.status=pass'
  Write-Output 'allow=true'
}

param(
  [Parameter(Mandatory = $true)][string]$HooksJson,
  [Parameter(Mandatory = $true)][string]$HookRoot,
  [Parameter(Mandatory = $true)][ValidateSet('posix','windows')][string]$Platform
)

$ErrorActionPreference = 'Stop'

function Ensure-List($Value) {
  if ($Value -is [System.Collections.IList]) { return @($Value) }
  return @()
}

function Remove-NeedleEntries([object[]]$Entries, [string]$Needle) {
  $kept = @()
  foreach ($entry in $Entries) {
    $hooks = if ($entry.PSObject.Properties.Name -contains 'hooks') { $entry.hooks } else { $null }
    $remove = $false
    if ($hooks -is [System.Collections.IEnumerable]) {
      foreach ($hook in $hooks) {
        if ($hook -and $hook.PSObject.Properties.Name -contains 'command') {
          $normalizedCommand = ([string]$hook.command) -replace '\\', '/'
          if ($normalizedCommand -like "*$Needle*") {
            $remove = $true
            break
          }
        }
      }
    }
    if (-not $remove) { $kept += $entry }
  }
  return $kept
}

$hooksJsonPath = [System.IO.Path]::GetFullPath($HooksJson)
$hookRootPath = [System.IO.Path]::GetFullPath($HookRoot)
$data = $null
if (Test-Path -LiteralPath $hooksJsonPath) {
  try {
    $raw = Get-Content -LiteralPath $hooksJsonPath -Raw
    if ($raw.Trim()) { $data = $raw | ConvertFrom-Json }
  } catch {
    $data = $null
  }
}
if (-not $data) {
  $data = [pscustomobject]@{ hooks = [pscustomobject]@{} }
}
if (-not ($data.PSObject.Properties.Name -contains 'hooks') -or -not $data.hooks) {
  Add-Member -InputObject $data -NotePropertyName hooks -NotePropertyValue ([pscustomobject]@{}) -Force
}

$submitCommand = Join-Path $hookRootPath ($(if ($Platform -eq 'windows') { 'user-prompt-submit.cmd' } else { 'user-prompt-submit.sh' }))
$stopCommand = Join-Path $hookRootPath ($(if ($Platform -eq 'windows') { 'stop.cmd' } else { 'stop.sh' }))
$submitEntries = Ensure-List $(if ($data.hooks.PSObject.Properties.Name -contains 'UserPromptSubmit') { $data.hooks.UserPromptSubmit } else { $null })
$stopEntries = Ensure-List $(if ($data.hooks.PSObject.Properties.Name -contains 'Stop') { $data.hooks.Stop } else { $null })
$submitEntries = Remove-NeedleEntries $submitEntries 'hiq-auto/user-prompt-submit'
$stopEntries = Remove-NeedleEntries $stopEntries 'hiq-auto/stop'
$submitEntries += [pscustomobject]@{ hooks = @([pscustomobject]@{ type = 'command'; command = $submitCommand; timeout = 25 }) }
$stopEntries += [pscustomobject]@{ hooks = @([pscustomobject]@{ type = 'command'; command = $stopCommand; timeout = 25 }) }
Add-Member -InputObject $data.hooks -NotePropertyName UserPromptSubmit -NotePropertyValue $submitEntries -Force
Add-Member -InputObject $data.hooks -NotePropertyName Stop -NotePropertyValue $stopEntries -Force

$dir = Split-Path -Parent $hooksJsonPath
if (-not (Test-Path -LiteralPath $dir)) {
  New-Item -ItemType Directory -Path $dir -Force | Out-Null
}
$data | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $hooksJsonPath
Write-Output "hooks_json=$hooksJsonPath hook_root=$hookRootPath platform=$Platform"

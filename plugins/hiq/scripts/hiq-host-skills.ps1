param(
  [string]$Root = ".",
  [string]$Host = "auto",
  [switch]$Json
)

$ErrorActionPreference = "Stop"

function Get-FullPath([string]$Path) {
  if ([System.IO.Path]::IsPathRooted($Path)) {
    return [System.IO.Path]::GetFullPath($Path)
  }
  return [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $Path))
}

$resolvedRoot = Get-FullPath $Root
$homeDir = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
$claudeSkills = if ($env:CLAUDE_SKILLS) { $env:CLAUDE_SKILLS } else { Join-Path $homeDir '.claude\skills' }
$codexSkills = if ($env:CODEX_SKILLS) { $env:CODEX_SKILLS } else { Join-Path $homeDir '.codex\skills' }
$piSkills = if ($env:PI_SKILLS) { $env:PI_SKILLS } else { Join-Path $homeDir '.pi\agent\skills' }
$liveagentSkills = if ($env:LIVEAGENT_SKILLS) { $env:LIVEAGENT_SKILLS } else { Join-Path $homeDir '.liveagent\skills' }
$projectSkills = Join-Path $resolvedRoot '.agents\skills'

if ($Host -eq 'auto') {
  if ($env:HIQ_HOST_TARGET) {
    $Host = $env:HIQ_HOST_TARGET
  } else {
    $currentPath = Join-Path $resolvedRoot '.hiq\current-change.json'
    if (Test-Path -LiteralPath $currentPath) {
      try {
        $current = Get-Content -LiteralPath $currentPath -Raw | ConvertFrom-Json
        $Host = if ($current.hostTarget) { [string]$current.hostTarget } else { 'unknown' }
      } catch {
        $Host = 'unknown'
      }
    } else {
      $Host = 'unknown'
    }
  }
}

$skillRoot = switch ($Host.ToLower()) {
  'claude' { $claudeSkills }
  'codex' { $codexSkills }
  'pi' { $piSkills }
  'liveagent' { $liveagentSkills }
  'project' { $projectSkills }
  default { '' }
}

$skills = @()
$rootExists = $false
if ($skillRoot -and (Test-Path -LiteralPath $skillRoot -PathType Container)) {
  $rootExists = $true
  foreach ($dir in (Get-ChildItem -LiteralPath $skillRoot -Directory | Sort-Object Name)) {
    $skills += [ordered]@{
      name = $dir.Name
      path = $dir.FullName
      hasSkillFile = ((Test-Path -LiteralPath (Join-Path $dir.FullName 'SKILL.md')) -or (Test-Path -LiteralPath (Join-Path $dir.FullName 'README.md')))
    }
  }
}

$result = [ordered]@{
  host = $Host
  skillRoot = if ($skillRoot) { $skillRoot } else { $null }
  rootExists = $rootExists
  count = $skills.Count
  skills = $skills
}
if ($Json) {
  $result | ConvertTo-Json -Depth 8
} else {
  Write-Output "host=$($result.host)"
  Write-Output "skill_root=$(if ($result.skillRoot) { $result.skillRoot } else { 'none' })"
  Write-Output "root_exists=$($result.rootExists.ToString().ToLower())"
  Write-Output "count=$($result.count)"
  foreach ($skill in $skills) {
    Write-Output "skill=$($skill.name)"
  }
}

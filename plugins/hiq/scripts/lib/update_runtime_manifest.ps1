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

$createdAt = if ($existing -and $existing.PSObject.Properties.Name -contains "created_at" -and $existing.created_at) {
  [string]$existing.created_at
} else {
  Get-Date -Format "yyyy-MM-dd"
}

$schema = 2
if ($existing -and $existing.PSObject.Properties.Name -contains "schema" -and $existing.schema) {
  $schema = [int]$existing.schema
}

$stack = if ($existing -and $existing.PSObject.Properties.Name -contains "stack") { $existing.stack } else { $null }
$memory = if ($existing -and $existing.PSObject.Properties.Name -contains "memory") { $existing.memory } else { $null }
$sessionPointer = if ($existing -and $existing.PSObject.Properties.Name -contains "session_pointer") { $existing.session_pointer } else { $null }
$existingCodegraph = if ($existing -and $existing.PSObject.Properties.Name -contains "codegraph") { $existing.codegraph } else { $null }
$note = if ($existingCodegraph -and $existingCodegraph.PSObject.Properties.Name -contains "note") { [string]$existingCodegraph.note } else { $null }

$statusOutput = & $Bin status --path $resolvedRoot 2>&1 | Out-String
$files = 0
$nodes = 0
$edges = 0
foreach ($line in ($statusOutput -split "`r?`n")) {
  if ($line -match '^\s*files:\s*(\d+)') { $files = [int]$Matches[1] }
  if ($line -match '^\s*nodes:\s*(\d+)') { $nodes = [int]$Matches[1] }
  if ($line -match '^\s*edges:\s*(\d+)') { $edges = [int]$Matches[1] }
}

$version = ""
foreach ($args in @(@("--version"), @("version"))) {
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

$updatedAt = ((Get-Date).ToString("yyyy-MM-ddTHH:mm:sszzz") -replace ':(?=\d\d$)', '')
$codegraph = [ordered]@{
  engine = "Cleboost/codegraph-rs"
  binary = $Bin
  version = $version
  status = "initialized"
  files = $files
  nodes = $nodes
  edges = $edges
}
if ($note) {
  $codegraph.note = $note
}

$manifest = [ordered]@{
  framework = "hiq"
  schema = $schema
  mode = "refresh"
  created_at = $createdAt
  updated_at = $updatedAt
  codegraph = $codegraph
}
if ($stack) {
  $manifest.stack = $stack
}
if ($memory) {
  $manifest.memory = $memory
}
if ($sessionPointer) {
  $manifest.session_pointer = $sessionPointer
}

$manifestDir = Split-Path -Parent $manifestPath
if (-not (Test-Path -LiteralPath $manifestDir)) {
  New-Item -ItemType Directory -Path $manifestDir -Force | Out-Null
}

$manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $manifestPath
Write-Output "manifest=$manifestPath files=$files nodes=$nodes edges=$edges"

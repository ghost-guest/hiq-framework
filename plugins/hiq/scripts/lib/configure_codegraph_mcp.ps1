param(
  [Parameter(Mandatory = $true)][string]$Root
)

$ErrorActionPreference = "Stop"

function Get-FullPath([string]$Path) {
  if ([System.IO.Path]::IsPathRooted($Path)) {
    return [System.IO.Path]::GetFullPath($Path)
  }
  return [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $Path))
}

function Write-TextUtf8([string]$Path, [string]$Content) {
  $parent = Split-Path -Parent $Path
  if ($parent -and -not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }
  [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
}

function Update-JsonMcp([string]$Path, [ordered]$Entry) {
  $data = [ordered]@{}
  if (Test-Path -LiteralPath $Path) {
    try {
      $existing = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -AsHashtable
      if ($existing) {
        $data = [ordered]@{}
        foreach ($key in $existing.Keys) {
          $data[$key] = $existing[$key]
        }
      }
    } catch {
      $data = [ordered]@{}
    }
  }

  if ($data.Contains('mcp_servers') -and -not $data.Contains('mcpServers')) {
    if (-not $data['mcp_servers']) { $data['mcp_servers'] = [ordered]@{} }
    $data['mcp_servers']['codegraph'] = $Entry
  } else {
    if (-not $data.Contains('mcpServers') -or -not $data['mcpServers']) {
      $data['mcpServers'] = [ordered]@{}
    }
    $data['mcpServers']['codegraph'] = $Entry
  }

  $parent = Split-Path -Parent $Path
  if ($parent -and -not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }
  Write-TextUtf8 $Path (($data | ConvertTo-Json -Depth 8) + "`n")
  Write-Output "configure-mcp: updated $Path"
}

function Update-CodexConfig() {
  $codexDir = Join-Path $HOME '.codex'
  if (-not (Test-Path -LiteralPath $codexDir -PathType Container)) {
    Write-Output 'configure-mcp: skip codex (no ~/.codex)'
    return
  }
  $cfg = Join-Path $codexDir 'config.toml'
  $text = if (Test-Path -LiteralPath $cfg) { Get-Content -LiteralPath $cfg -Raw } else { '' }
  $block = @'
[mcp_servers.codegraph]
command = "cmd"
args = ["/c", "\"%USERPROFILE%\\.hiq\\bin\\codegraph.exe\" serve --mcp"]
'@
  if ($text -match '(?ms)^\[mcp_servers\.codegraph\].*?(?=^\[|\z)') {
    $text = [regex]::Replace($text, '(?ms)^\[mcp_servers\.codegraph\].*?(?=^\[|\z)', '')
    $text = $text.TrimEnd() + "`n" + $block.TrimStart()
  } else {
    $text = $text.TrimEnd() + "`n" + $block
  }
  Write-TextUtf8 $cfg (($text.TrimEnd()) + "`n")
  Write-Output "configure-mcp: updated $cfg (portable PATH command)"
}

$resolvedRoot = Get-FullPath $Root
Write-Output "configure-mcp: root=$resolvedRoot (portable mode, no absolute binary paths)"

$toolsDir = Join-Path $resolvedRoot '.hiq\tools'
$graphDir = Join-Path $resolvedRoot '.hiq\graph'
New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null
New-Item -ItemType Directory -Path $graphDir -Force | Out-Null

$launcherCmd = Join-Path $toolsDir 'codegraph.cmd'
$launcherBody = @'
@echo off
setlocal
REM Portable HiQ codegraph launcher (project-relative) for Windows cmd.
if defined HIQ_CODEGRAPH if exist "%HIQ_CODEGRAPH%" (
  "%HIQ_CODEGRAPH%" %*
  exit /b %ERRORLEVEL%
)
if exist "%USERPROFILE%\.hiq\bin\codegraph.exe" (
  "%USERPROFILE%\.hiq\bin\codegraph.exe" %*
  exit /b %ERRORLEVEL%
)
if exist "%USERPROFILE%\.hiq\bin\codegraph" (
  "%USERPROFILE%\.hiq\bin\codegraph" %*
  exit /b %ERRORLEVEL%
)
echo hiq-codegraph: binary not found. Run hiq-install / install-codegraph.cmd on this machine.
exit /b 127
'@
Write-TextUtf8 $launcherCmd $launcherBody
Write-Output "configure-mcp: wrote $launcherCmd"

$entry = [ordered]@{
  command = '.hiq/tools/codegraph.cmd'
  args = @('serve', '--mcp')
}
Update-JsonMcp (Join-Path $resolvedRoot '.mcp.json') $entry
Update-JsonMcp (Join-Path $resolvedRoot '.cursor\mcp.json') $entry

$liveagent = [ordered]@{
  id = 'codegraph'
  enabled = $true
  transport = 'stdio'
  command = '.hiq/tools/codegraph.cmd'
  args = @('serve', '--mcp')
  timeoutMs = 30000
  hiq_portable = $true
  hiq_note = 'command is project-relative; McpManager must set cwd to this workspace root. Do not use bare PATH ''codegraph'' when a managed launcher exists.'
  hiq_command_windows = '.hiq/tools/codegraph.cmd'
  hiq_alt_command_path = 'codegraph'
  hiq_require_cwd = $true
}
Write-TextUtf8 (Join-Path $graphDir 'mcp-liveagent.json') (($liveagent | ConvertTo-Json -Depth 8) + "`n")
Write-Output "configure-mcp: wrote $(Join-Path $graphDir 'mcp-liveagent.json')"

$hiqHome = Join-Path $HOME '.hiq'
New-Item -ItemType Directory -Path $hiqHome -Force | Out-Null
Write-TextUtf8 (Join-Path $hiqHome 'mcp-codegraph.json') (($liveagent | ConvertTo-Json -Depth 8) + "`n")
Write-Output "configure-mcp: wrote $(Join-Path $hiqHome 'mcp-codegraph.json')"

$pathHint = @'
# Codegraph PATH (portable)

HiQ never writes machine-absolute paths into repo-local MCP configs.

## Preferred: project-relative launcher

Repo-local MCP and LiveAgent snippets use:

```text
.hiq/tools/codegraph.cmd
```

This launcher resolves `HIQ_CODEGRAPH` or `%USERPROFILE%\.hiq\bin\codegraph.exe` at runtime.

## PATH order

If a different `codegraph` is earlier on PATH, it may hijack MCP.
Put the managed HiQ bin first in the Windows user PATH:

```text
%USERPROFILE%\.hiq\bin
```

## LiveAgent apply

- `command`: `.hiq/tools/codegraph.cmd`
- `args`: `["serve", "--mcp"]`
- `cwd`: set by host to this workspace root at apply time
'@
Write-TextUtf8 (Join-Path $graphDir 'PATH.md') ($pathHint + "`n")
Write-Output "configure-mcp: wrote $(Join-Path $graphDir 'PATH.md')"

Update-CodexConfig
Write-Output 'configure-mcp: done (portable)'

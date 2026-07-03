# Link %USERPROFILE%\.cursor\agents to this repo's agents\ folder.
#
# Usage (PowerShell):
#   .\scripts\setup.ps1
#
# Run as Administrator if symlink creation fails (or enable Developer Mode on Windows).

$ErrorActionPreference = "Stop"

function Write-Log([string]$Message) {
    Write-Host "[cursor-agents] $Message"
}

$RepoDir = Split-Path -Parent $PSScriptRoot
$AgentsSrc = Join-Path $RepoDir "agents"
$CursorAgents = if ($env:CURSOR_AGENTS_DIR) { $env:CURSOR_AGENTS_DIR } else {
    Join-Path $env:USERPROFILE ".cursor\agents"
}

if (-not (Test-Path $AgentsSrc -PathType Container)) {
    throw "agents/ not found at $AgentsSrc"
}

function Test-IsSymlink([string]$Path) {
    if (-not (Test-Path $Path)) { return $false }
    $item = Get-Item $Path -Force
    return ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0
}

if (Test-Path $CursorAgents) {
    if (Test-IsSymlink $CursorAgents) {
        $existing = (Get-Item $CursorAgents).Target
        if ($existing -eq $AgentsSrc) {
            Write-Log "Already linked to $AgentsSrc"
            exit 0
        }
        Write-Log "Removing existing symlink: $CursorAgents -> $existing"
        Remove-Item $CursorAgents -Force
    } else {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backup = "$CursorAgents.backup.$timestamp"
        Write-Log "Backing up existing agents to $backup"
        Move-Item $CursorAgents $backup
    }
}

$cursorDir = Split-Path $CursorAgents -Parent
if (-not (Test-Path $cursorDir)) {
    New-Item -ItemType Directory -Path $cursorDir -Force | Out-Null
}

try {
    New-Item -ItemType SymbolicLink -Path $CursorAgents -Target $AgentsSrc -Force | Out-Null
    Write-Log "Created symbolic link"
} catch {
    Write-Log "Symbolic link failed, trying junction: $($_.Exception.Message)"
    New-Item -ItemType Junction -Path $CursorAgents -Target $AgentsSrc -Force | Out-Null
    Write-Log "Created junction"
}

$agentCount = (Get-ChildItem -Path $CursorAgents -Filter "*.md" -File).Count
if ($agentCount -lt 6) {
    throw "Expected 6 agent files, found $agentCount in $CursorAgents"
}

Write-Host ""
Write-Host "=== Setup complete ==="
Write-Host "Linked: $CursorAgents -> $AgentsSrc"
Write-Host ""
Write-Host "Agents available in all Cursor projects on this machine:"
Write-Host "  - orchestrator"
Write-Host "  - requirement-analyzer"
Write-Host "  - architecture-agent"
Write-Host "  - adversarial-critic"
Write-Host "  - review-agent"
Write-Host "  - writer-agent"
Write-Host ""
Write-Host "Next steps:"
Write-Host "[ ] Restart Cursor if agents do not appear"
Write-Host "[ ] Push repo to GitHub/GitLab for other machines"
Write-Host "[ ] On other machines: git clone <repo> ; .\scripts\setup.ps1"

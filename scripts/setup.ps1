# Link %USERPROFILE%\.cursor\agents and %USERPROFILE%\.cursor\skills\* to this repo.
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
$SkillsSrc = Join-Path $RepoDir "skills"
$CursorAgents = if ($env:CURSOR_AGENTS_DIR) { $env:CURSOR_AGENTS_DIR } else {
    Join-Path $env:USERPROFILE ".cursor\agents"
}
$CursorSkills = if ($env:CURSOR_SKILLS_DIR) { $env:CURSOR_SKILLS_DIR } else {
    Join-Path $env:USERPROFILE ".cursor\skills"
}

function Test-IsSymlink([string]$Path) {
    if (-not (Test-Path $Path)) { return $false }
    $item = Get-Item $Path -Force
    return ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0
}

function Backup-And-Link([string]$Target, [string]$Source, [string]$Label) {
    if (Test-Path $Target) {
        if (Test-IsSymlink $Target) {
            $existing = (Get-Item $Target).Target
            if ($existing -eq $Source) {
                Write-Log "$Label already linked to $Source"
                return
            }
            Write-Log "Removing existing $Label symlink: $Target -> $existing"
            Remove-Item $Target -Force
        } else {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $backup = "$Target.backup.$timestamp"
            Write-Log "Backing up existing $Label to $backup"
            Move-Item $Target $backup
        }
    }

    $parent = Split-Path $Target -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force | Out-Null
        Write-Log "Linked $Target -> $Source"
    } catch {
        Write-Log "Symbolic link failed for $Label, trying junction: $($_.Exception.Message)"
        New-Item -ItemType Junction -Path $Target -Target $Source -Force | Out-Null
        Write-Log "Linked $Target -> $Source (junction)"
    }
}

function Setup-Agents {
    if (-not (Test-Path $AgentsSrc -PathType Container)) {
        throw "agents/ not found at $AgentsSrc"
    }

    Backup-And-Link -Target $CursorAgents -Source $AgentsSrc -Label "agents"

    $agentCount = (Get-ChildItem -Path $CursorAgents -Filter "*.md" -File).Count
    if ($agentCount -lt 6) {
        throw "Expected at least 6 agent files, found $agentCount in $CursorAgents"
    }
}

function Setup-Skills {
    if (-not (Test-Path $SkillsSrc -PathType Container)) {
        Write-Log "skills/ not found at $SkillsSrc - skipping skills setup"
        return
    }

    if (-not (Test-Path $CursorSkills)) {
        New-Item -ItemType Directory -Path $CursorSkills -Force | Out-Null
    }

    Get-ChildItem -Path $SkillsSrc -Directory | ForEach-Object {
        $skillName = $_.Name
        $skillTarget = Join-Path $CursorSkills $skillName
        Backup-And-Link -Target $skillTarget -Source $_.FullName -Label "skill $skillName"

        $skillFile = Join-Path $skillTarget "SKILL.md"
        if (-not (Test-Path $skillFile -PathType Leaf)) {
            throw "SKILL.md not found in linked skill $skillTarget"
        }
    }
}

Setup-Agents
Setup-Skills

Write-Host ""
Write-Host "=== Setup complete ==="
Write-Host "Agents: $CursorAgents -> $AgentsSrc"
Write-Host "Skills: $CursorSkills\* -> $SkillsSrc\*"
Write-Host ""
Write-Host "Agents available in all Cursor projects on this machine:"
Write-Host "  - orchestrator"
Write-Host "  - requirement-analyzer"
Write-Host "  - architecture-agent"
Write-Host "  - adversarial-critic"
Write-Host "  - review-agent"
Write-Host "  - writer-agent"
Write-Host "  - security-agent"
Write-Host ""
Write-Host "Skills available in all Cursor projects on this machine:"
Write-Host "  - appsec-research-orchestrator"
Write-Host "  - kb-write-topic"
Write-Host ""
Write-Host "Next steps:"
Write-Host "[ ] Restart Cursor if agents/skills do not appear"
Write-Host "[ ] Push repo to GitHub/GitLab for other machines"
Write-Host '[ ] On other machines: git clone <repo> ; .\scripts\setup.ps1'

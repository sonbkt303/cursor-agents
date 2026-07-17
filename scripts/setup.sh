#!/bin/bash
#
# Link ~/.cursor/agents and ~/.cursor/skills/* to this repo.
# Works on macOS, Linux, and Git Bash on Windows.
#
# Usage: ./scripts/setup.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENTS_SRC="$REPO_DIR/agents"
SKILLS_SRC="$REPO_DIR/skills"

log() { echo "[cursor-agents] $*"; }

resolve_cursor_agents_dir() {
    if [[ -n "${CURSOR_AGENTS_DIR:-}" ]]; then
        echo "$CURSOR_AGENTS_DIR"
        return
    fi
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        echo "${USERPROFILE:-$HOME}/.cursor/agents"
    else
        echo "${HOME}/.cursor/agents"
    fi
}

resolve_cursor_skills_dir() {
    if [[ -n "${CURSOR_SKILLS_DIR:-}" ]]; then
        echo "$CURSOR_SKILLS_DIR"
        return
    fi
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        echo "${USERPROFILE:-$HOME}/.cursor/skills"
    else
        echo "${HOME}/.cursor/skills"
    fi
}

backup_and_link() {
    local target="$1"
    local source="$2"
    local label="$3"

    if [[ -e "$target" && ! -L "$target" ]]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        log "Backing up existing $label to $backup"
        mv "$target" "$backup"
    elif [[ -L "$target" ]]; then
        local current
        current="$(readlink "$target" 2>/dev/null || readlink -f "$target" 2>/dev/null || true)"
        if [[ "$current" == "$source" ]]; then
            log "$label already linked to $source"
            return 0
        fi
        log "Removing existing $label symlink: $target -> $current"
        rm "$target"
    fi

    mkdir -p "$(dirname "$target")"
    ln -s "$source" "$target"
    log "Linked $target -> $source"
}

setup_agents() {
    local cursor_agents
    cursor_agents="$(resolve_cursor_agents_dir)"

    if [[ ! -d "$AGENTS_SRC" ]]; then
        echo "ERROR: agents/ not found at $AGENTS_SRC" >&2
        exit 1
    fi

    backup_and_link "$cursor_agents" "$AGENTS_SRC" "agents"

    if [[ ! -L "$cursor_agents" ]]; then
        echo "ERROR: Symlink was not created at $cursor_agents" >&2
        exit 1
    fi

    local count
    count="$(find "$cursor_agents" -maxdepth 1 -name '*.md' | wc -l | tr -d ' ')"
    if [[ "$count" -lt 6 ]]; then
        echo "ERROR: Expected at least 6 agent files, found $count in $cursor_agents" >&2
        exit 1
    fi
}

setup_skills() {
    local cursor_skills
    cursor_skills="$(resolve_cursor_skills_dir)"

    if [[ ! -d "$SKILLS_SRC" ]]; then
        log "skills/ not found at $SKILLS_SRC — skipping skills setup"
        return 0
    fi

    mkdir -p "$cursor_skills"

    local skill_dir skill_name skill_target
    for skill_dir in "$SKILLS_SRC"/*/; do
        [[ -d "$skill_dir" ]] || continue
        skill_name="$(basename "$skill_dir")"
        skill_target="$cursor_skills/$skill_name"
        backup_and_link "$skill_target" "$skill_dir" "skill $skill_name"

        if [[ ! -f "$skill_target/SKILL.md" ]]; then
            echo "ERROR: SKILL.md not found in linked skill $skill_target" >&2
            exit 1
        fi
    done
}

print_checklist() {
    local cursor_agents cursor_skills
    cursor_agents="$(resolve_cursor_agents_dir)"
    cursor_skills="$(resolve_cursor_skills_dir)"

    cat <<EOF

=== Setup complete ===
Agents: $cursor_agents -> $AGENTS_SRC
Skills: $cursor_skills/* -> $SKILLS_SRC/*

Agents available in all Cursor projects on this machine:
  - orchestrator
  - requirement-analyzer
  - architecture-agent
  - adversarial-critic
  - review-agent
  - writer-agent
  - security-agent

Skills available in all Cursor projects on this machine:
  - appsec-research-orchestrator
  - kb-write-topic

Next steps:
[ ] Restart Cursor (or reload window) if agents/skills do not appear
[ ] Push repo to GitHub/GitLab for other machines
[ ] On other machines: git clone <repo> && ./scripts/setup.sh

Update: edit files in $AGENTS_SRC or $SKILLS_SRC, commit, push, pull on other machines.
EOF
}

run_windows_setup() {
    local ps_script="$SCRIPT_DIR/setup.ps1"
    if command -v powershell.exe &>/dev/null; then
        log "Windows detected — using setup.ps1 (junction/symlink)"
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$ps_script"
        exit $?
    fi
    echo "ERROR: On Windows, run .\\scripts\\setup.ps1 from PowerShell" >&2
    exit 1
}

main() {
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        run_windows_setup
    fi

    setup_agents
    setup_skills
    print_checklist
}

main "$@"

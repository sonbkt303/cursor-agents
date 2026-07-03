#!/bin/bash
#
# Link ~/.cursor/agents to this repo's agents/ folder.
# Works on macOS, Linux, and Git Bash on Windows.
#
# Usage: ./scripts/setup.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENTS_SRC="$REPO_DIR/agents"

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

backup_existing_agents() {
    local target="$1"

    if [[ -e "$target" && ! -L "$target" ]]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        log "Backing up existing agents to $backup"
        mv "$target" "$backup"
    elif [[ -L "$target" ]]; then
        local current
        current="$(readlink "$target" 2>/dev/null || readlink -f "$target" 2>/dev/null || true)"
        if [[ "$current" == "$AGENTS_SRC" ]]; then
            log "Already linked to $AGENTS_SRC"
            exit 0
        fi
        log "Removing existing symlink: $target -> $current"
        rm "$target"
    fi
}

create_symlink() {
    local target="$1"

    mkdir -p "$(dirname "$target")"
    ln -s "$AGENTS_SRC" "$target"
}

verify_link() {
    local target="$1"

    if [[ ! -L "$target" ]]; then
        echo "ERROR: Symlink was not created at $target" >&2
        exit 1
    fi

    local count
    count="$(find "$target" -maxdepth 1 -name '*.md' | wc -l | tr -d ' ')"
    if [[ "$count" -lt 6 ]]; then
        echo "ERROR: Expected 6 agent files, found $count in $target" >&2
        exit 1
    fi
}

print_checklist() {
    cat <<EOF

=== Setup complete ===
Linked: $(resolve_cursor_agents_dir) -> $AGENTS_SRC

Agents available in all Cursor projects on this machine:
  - orchestrator
  - requirement-analyzer
  - architecture-agent
  - adversarial-critic
  - review-agent
  - writer-agent

Next steps:
[ ] Restart Cursor (or reload window) if agents do not appear
[ ] Push repo to GitHub/GitLab for other machines
[ ] On other machines: git clone <repo> && ./scripts/setup.sh

Update agents: edit files in $AGENTS_SRC, commit, push, pull on other machines.
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
    if [[ ! -d "$AGENTS_SRC" ]]; then
        echo "ERROR: agents/ not found at $AGENTS_SRC" >&2
        exit 1
    fi

    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        run_windows_setup
    fi

    local cursor_agents
    cursor_agents="$(resolve_cursor_agents_dir)"

    backup_existing_agents "$cursor_agents"
    create_symlink "$cursor_agents"
    verify_link "$cursor_agents"

    log "Linked $cursor_agents -> $AGENTS_SRC"
    print_checklist
}

main "$@"

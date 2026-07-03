# cursor-agents

Personal Cursor subagents synced across machines and projects via `~/.cursor/agents`.

## Agents

| Agent | Role |
|-------|------|
| `orchestrator` | Multi-agent pipeline coordinator (entry point) |
| `requirement-analyzer` | Requirements specs with acceptance criteria |
| `architecture-agent` | Technical design and trade-offs |
| `adversarial-critic` | Devil's advocate / Socratic challenger |
| `review-agent` | Formal PASS / FAIL review |
| `writer-agent` | ADRs, guides, runbooks, PR summaries |

## Quick setup

### This machine (first time)

**Git Bash / macOS / Linux:**

```bash
git clone <your-repo-url> cursor-agents
cd cursor-agents
./scripts/setup.sh
```

**PowerShell (Windows):**

```powershell
git clone <your-repo-url> cursor-agents
cd cursor-agents
.\scripts\setup.ps1
```

The script links `~/.cursor/agents` → `agents/` in this repo. Existing agents are backed up automatically.

### Another machine

```bash
git clone <your-repo-url> cursor-agents
cd cursor-agents
./scripts/setup.sh   # or .\scripts\setup.ps1 on Windows
```

After pulling updates:

```bash
git pull
# No re-run needed — symlink already points to repo
```

Restart Cursor if new agents do not appear immediately.

## How it works

```
~/.cursor/agents  ──symlink──>  cursor-agents/agents/*.md
                                      │
                                      └── git push/pull syncs across machines
```

User-level agents apply to **all projects** on that machine. Project-level agents in `.cursor/agents/` inside a repo take priority over these.

## Updating agents

1. Edit files in `agents/`
2. Commit and push
3. `git pull` on other machines

## Optional: per-project agents

To share agents with a team inside one repo, copy files to that repo's `.cursor/agents/` (higher priority than user-level).

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Symlink fails on Windows | Run PowerShell as Administrator, or enable **Developer Mode** (Settings → System → For developers) |
| Agents not visible | Restart Cursor / Reload Window |
| Wrong agents loaded | Check `ls -la ~/.cursor/agents` points to this repo |

Custom target path:

```bash
CURSOR_AGENTS_DIR=/path/to/.cursor/agents ./scripts/setup.sh
```

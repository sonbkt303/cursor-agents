# cursor-agents

Personal Cursor **subagents** and **skills** synced across machines and projects via `~/.cursor/agents` and `~/.cursor/skills`.

**Usage guide:** [USAGE.md](./USAGE.md) — Quick path cho task hàng ngày, pipeline, prompt mẫu, cheat sheet.

## Agents

| Agent | Role |
|-------|------|
| `orchestrator` | Multi-agent pipeline coordinator (entry point) |
| `requirement-analyzer` | Requirements specs with acceptance criteria |
| `architecture-agent` | Technical design and trade-offs |
| `adversarial-critic` | Devil's advocate / Socratic challenger |
| `review-agent` | Formal PASS / FAIL review |
| `writer-agent` | Module overviews, specs, ADRs, guides, runbooks, PR summaries |
| `security-agent` | AppSec for Node.js, infra (Docker/K8s/cloud/CI), and AI (LLM/RAG/MCP/agents) |

## Skills

| Skill | Role |
|-------|------|
| `appsec-research-orchestrator` | AppSec KB research pipeline (Mr P — Professional); batch, interactive, qa-only, single-role |
| `kb-write-topic` | Write one Knowledge Base topic quickly without multi-role pipeline |

User guide (Vietnamese): [`skills/appsec-research-orchestrator/references/pipeline/USER-GUIDE.md`](./skills/appsec-research-orchestrator/references/pipeline/USER-GUIDE.md)

Invoke: `@appsec-research-orchestrator` or first line `Use appsec-research-orchestrator (Mr P — Professional).`

## Documentation style

Default markdown styles for `writer-agent` (and the docs checklist in `review-agent`):

| Template | Use for |
|----------|---------|
| [`templates/documentation-style.md`](./templates/documentation-style.md) | Overviews, specs, ADRs, setup guides, runbooks, PR summaries |
| [`templates/report-style.md`](./templates/report-style.md) | Test, impact, and audit reports (embedded CSS, verdict badges, item cards) |

- Applies across **all projects** on a machine after setup (user-level agents).
- If a target repo has stronger local conventions (`docs/DOCUMENTATION-STYLE.md`, `docs/REPORT-STYLE.md`, or existing docs), those win.
- Update style → edit `templates/` + `agents/writer-agent.md` → commit/push → `git pull` on other machines.

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

The script links `~/.cursor/agents` → `agents/` and each skill in `skills/` → `~/.cursor/skills/<skill-name>`. Existing paths are backed up automatically.

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

Restart Cursor if new agents or skills do not appear immediately.

## How it works

```
~/.cursor/agents              ──symlink──>  cursor-agents/agents/*.md
~/.cursor/skills/<skill-name> ──symlink──>  cursor-agents/skills/<skill-name>/
                                                    │
                                                    └── git push/pull syncs across machines
```

User-level agents and skills apply to **all projects** on that machine. Project-level copies in `.cursor/agents/` or `.cursor/skills/` inside a repo take priority over user-level.

## Updating agents and skills

1. Edit files in `agents/` or `skills/`
2. Commit and push
3. `git pull` on other machines

## Optional: per-project agents

To share agents with a team inside one repo, copy files to that repo's `.cursor/agents/` (higher priority than user-level).

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Symlink fails on Windows | Run PowerShell as Administrator, or enable **Developer Mode** (Settings → System → For developers) |
| Agents not visible | Restart Cursor / Reload Window |
| Skills not visible | Restart Cursor / Reload Window; check `ls -la ~/.cursor/skills/appsec-research-orchestrator` |
| Wrong agents loaded | Check `ls -la ~/.cursor/agents` points to this repo |
| Wrong skills loaded | Check each skill symlink under `~/.cursor/skills/` points to this repo |

Custom target paths:

```bash
CURSOR_AGENTS_DIR=/path/to/.cursor/agents CURSOR_SKILLS_DIR=/path/to/.cursor/skills ./scripts/setup.sh
```

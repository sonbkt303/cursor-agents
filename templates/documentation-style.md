# Documentation Style Guide

Portable markdown conventions for `writer-agent` across projects. Prefer a target repo’s local style (`docs/DOCUMENTATION-STYLE.md`, existing module docs) when it is stronger or more specific; otherwise use this guide.

Golden patterns originated from CleverDent booking-intake overview/spec docs — use the patterns, not a hard dependency on that repo.

---

## 1. Doc types

| Type | When | Audience |
|------|------|----------|
| **Module Overview** | Architecture, user flow, system boundaries | Architects, PM, tech leads |
| **Implementation Spec** | Schema, REST DTOs, algorithms, security, errors | Backend / FE developers |
| **ADR** | Single architecture decision | Engineers reviewing a choice |
| **Setup guide** | Install / configure / verify | Anyone onboarding |
| **Runbook** | Operate / recover / escalate | On-call / ops |
| **PR summary** | Pull request body | Reviewers |
| **Changelog** | Release notes | Consumers of the change |

### Overview vs Spec

- Prefer an **overview + spec pair** for non-trivial module design.
- Overview = flow + architecture summary. Spec = canonical contracts (schema, DTOs, engine, LLM).
- **Conflict rule:** Spec wins for implementation contracts until overview is updated. State this in an authority callout on both docs.

---

## 2. Required skeleton (Overview & Spec)

```markdown
- [Title](#anchor)
  - [Key points at a glance](#key-points-at-a-glance)
  - [1. …](#1-…)
  - [2. …](#2-…)

# <Title>

| Field | Value |
|-------|-------|
| **Version** | 0.1 (Draft) |
| **Status** | … |
| **Jira** | … |
| **Audience** | … |
| **Scope** | … |
| **Review order** | §1 → §2 → …; detail → [sibling doc](./…) |
| **Related docs** | [link](./…) · [link](./…) |

---

### Key points at a glance

> [!IMPORTANT]
> - **Invariant / decision:** …
> - **Boundary:** …

> [!IMPORTANT]
> **Document authority:** This <overview|spec> is … If they conflict, follow **<canonical>**.

---

## 1. …

---

## 2. …
```

### Heading rules

- Numbered sections: `## 1. Title`, `### 2.1 Title`, `#### 2.2.1 Title`
- Nested TOC at the top (list of links)
- `---` between major numbered sections
- Early `### Key points at a glance` after the metadata table

### Metadata table fields

Use what applies: `Version`, `Status`, `Jira`, `PRD ref`, `Audience`, `Scope`, `Review order`, sibling overview/spec link, `Related docs`.

---

## 3. Callouts (GitHub admonitions)

| Type | Use for |
|------|---------|
| `> [!IMPORTANT]` | Decisions, invariants, authority, non-negotiables |
| `> [!NOTE]` | Rationale, context, “why”, deferred detail pointers |
| `> [!WARNING]` | Risks, review-first, ACCEPTED_RISK, dangerous steps |

Do not invent custom callout syntax. Prefer one focused callout over long prose for critical rules.

---

## 4. Diagrams, tables, code

- **Mermaid first** for flows: `flowchart`, `sequenceDiagram`, `erDiagram` before deep prose
- Short **bold caption** above each diagram (e.g. `**Request sequence**`)
- Prefer **dense tables** for steps, field matrices, service boundaries, propagation
- **Code contracts:** TypeScript interfaces / JSON examples; inline comments with meaning (`— e.g. "..."`)
- **Cross-refs:** Relative links + section anchors (`[spec §4.3](./file.md#43-…)`)
- Defer detail to the canonical doc instead of duplicating

---

## 5. Prose tone

- Direct and decision-oriented; no fluff
- Bold key identifiers and outcomes sparingly
- English for technical module docs unless the project uses an existing `.vi.md` / bilingual pair
- Dangerous or irreversible steps need explicit warnings + verification / rollback where relevant

---

## 6. Accuracy

- Do not invent requirements, APIs, or behavior not in approved sources or code
- If source artifact and code disagree: document the approved source and add a **Doc accuracy warning**
- Flag unverifiable content explicitly

---

## 7. Quick checklist

- [ ] Correct doc type (overview / spec / ADR / setup / runbook / PR / changelog)
- [ ] Metadata table under `# Title`
- [ ] Key points + authority callout (overview/spec)
- [ ] Numbered headings + TOC + `---` between major sections
- [ ] Admonitions used correctly (IMPORTANT / NOTE / WARNING)
- [ ] Mermaid where a flow or model helps; tables for matrices
- [ ] Relative cross-refs; no silent duplication of canonical contracts
- [ ] No invented scope; accuracy warnings where needed

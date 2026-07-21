# Documentation Style Guide (deprecated)

> **This guide is deprecated.** `writer-agent` now uses **only** [`report-style.md`](./report-style.md) for all document types (overviews, specs, ADRs, architecture, reports, guides, runbooks).
>
> Read [`report-style.md`](./report-style.md) for the current template, embedded CSS, diagram panels, and Mermaid patterns.
>
> Golden reference: `license_app/docs/architecture/entity-relationships.md`

## Migration notes

| Old pattern | New pattern |
|-------------|-------------|
| `> [!IMPORTANT]` admonition | `<div class="callout">` or `<div class="callout callout-warning">` |
| Metadata markdown table | `<p class="report-meta">` panel |
| `### Key points at a glance` | `conclusion-panel` in Executive summary |
| Plain Mermaid block | `diagram-caption` + `diagram-panel diagram-panel--*` |
| Numbered `## 1.` headings only | `section-header` wrapper + numbered headings |
| Entity prose sections | `report-item` cards with `item-badge` |

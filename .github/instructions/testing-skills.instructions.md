---
applyTo: "skills/**/*.md,exploratory-reports/**/*.md"
---

# Testing Skills — File Conventions

These instructions apply when reading or editing files under `skills/` and `exploratory-reports/`.

## Three layers of rules apply during any testing session

1. **Universal mechanics** — `skills/web-navigator/references/*.md` (file format, write order, session folder structure, audit log entry formats, evidence collection mechanics).
2. **Universal testing conventions** — `skills/_testing-conventions/findings.md` and `skills/_testing-conventions/session.md` (ID format, severity scale, time-budget tiers, coverage logging, missed-coverage reporting).
3. **Skill-specific methodology** — the active skill's `SKILL.md` (workflow steps, required additional fields like WCAG/WSTG, skill-specific time-budget scaling table, coverage heuristic).

The entry-point doc (`AGENTS.md` or the Copilot prompt) is responsible for loading all three layers together. Individual skill files do not cross-reference between layers — composition lives at the entry point.

## When reading a `SKILL.md`

- The frontmatter (`name`, `version`, `description`) is the skill's identity. Treat the `description` field as the routing hint — if the user's request matches it, this skill is likely the active skill.
- The body is the methodology. Follow the Workflow steps in order.
- Skill-specific additions (required fields, time-budget scaling, coverage heuristic) are inlined as sections within the SKILL.md, not in separate rule files.
- The "Strictness Principles" section lists rules that may not be bypassed under time pressure.

## When reading `_testing-conventions/findings.md` or `_testing-conventions/session.md`

- These define what is true for **every** testing skill — no overrides, no per-skill exceptions.
- `findings.md`: ID format (3-digit sequential, no prefix), severity scale, write-immediately, actionable-recommendation, reproducibility-before-reporting.
- `session.md`: time-budget tiers, checkpoint cadence, coverage logging principle, missed-coverage reporting, scaling principles.

## When reading `references/heuristics.md` in a testing skill

- The heuristic catalogue is the *probe playbook*. Each heuristic (SFDPOT, STRIDE, POUR, RAIL, etc.) is a coverage acronym — each letter must be tested or logged as `NT` (not tested) with a reason.
- "Execution Contract" sections at the bottom give the repeatable method. Apply that method, not acronym recall.

## When writing session output under `exploratory-reports/[id]/`

- `session.md` is the metadata + continuation file. Update counters and continuation fields as the session progresses.
- `audit.log` is **append-only**. Every event written immediately. Format: `[HH:MM:SS] [level] TYPE: description`.
- `findings/[NNN].md` — one file per failed check, IDs are 3-digit sequential (`001.md`, `002.md`, ...), no prefix. Frontmatter must include `id`, `rule`, `status`, `timestamp`.
- `evidence/[NN]-[description].[png|webm]` — two-digit sequence + finding ID for failures (e.g., `02-001-empty-name-accepted.png`).
- `snapshots/[NN]-[description].yaml` — DOM snapshots, session-local.

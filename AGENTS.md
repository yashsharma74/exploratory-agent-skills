# Agents Entry Point

This file is the universal entry point for any AI coding agent (Codex, Aider, Gemini CLI, Cursor, Continue, Windsurf, Claude Code, GitHub Copilot, and others) working in this repository.

## What lives here

This repo is a self-contained, agent-agnostic exploratory testing toolkit. It contains:

| Path | Purpose |
|---|---|
| `skills/web-navigator/` | **Entry point.** Orchestrator. Drives a real browser via `playwright-cli`. Owns universal mechanics: setup, environment, credentials, viewports, session structure, audit log format, evidence collection, write policy. |
| `skills/_testing-conventions/` | Shared conventions across all testing skills: ID format, severity scale, time-budget tiers, coverage logging, missed-coverage reporting. Not a skill itself. |
| `skills/functional-testing/` | User flows, validation, navigation, state, business logic. |
| `skills/security-testing/` | XSS, injection, AuthN/AuthZ, CSRF, data exposure. |
| `skills/accessibility-testing/` | WCAG 2.1/2.2 AA — keyboard, focus, labels, semantics. |
| `skills/performance-testing/` | Console errors, failed/slow requests, load timing, runtime stability. |
| `exploratory-reports/` | Output directory. Each session writes a timestamped subfolder here. |
| `.github/` | GitHub Copilot adapter (`copilot-instructions.md`, `instructions/`, `prompts/`). Other agents do not need anything here. |

## How to invoke

**Web Navigator (`skills/web-navigator/`) is the entry point.** Testing skills are libraries — never the entry point. This document (AGENTS.md) is responsible for *composition*: telling the agent which modules to load together.

### Composition rule (for a testing session)

For any testing session, load these three modules together — they form a complete unit:

1. `skills/web-navigator/SKILL.md` and its references (mechanics: browser, session folder, audit log, file format, write policy).
2. `skills/_testing-conventions/findings.md` and `skills/_testing-conventions/session.md` (universal testing rules: ID format, severity scale, time-budget tiers, coverage logging).
3. The active skill's `SKILL.md` and its `references/` (methodology: workflow, heuristics, skill-specific required fields, skill-specific time-budget scaling).

The active skill never cross-references the other two — composition is owned by this entry point, not by the skills.

### Steps

1. **Pick the active skill** based on the user's intent:
   - Clear single domain → `functional-testing`, `security-testing`, `accessibility-testing`, or `performance-testing`.
   - **Unclear scope** → ask the user. Do not guess.
   - **Multi-domain coverage** → run a separate session per domain. Each session writes its own folder under `exploratory-reports/`.

2. **Load the three modules above** in the agent's context.

3. **Follow Web Navigator's phases**:
   - **Phase 1 — Setup.** Resolves target URL, environment, credentials, evidence level, viewport, time limit. Values already in the prompt are used directly; otherwise Navigator asks.
   - **Phase 2 — Prepare.** Set up fixtures; initialize the session folder under `exploratory-reports/[YYYY-MM-DDTHHMMSSZ]-[skill]-[feature]/`.
   - **Phase 3 — Navigate & Check.** Navigator runs the orchestration loop. The active skill's methodology defines what to probe and how to judge results; `_testing-conventions/` defines ID format, severity scale, coverage logging; Navigator handles browser drive and file writes.
   - **Phase 4 — Close.** Finalize `session.md`, return a summary, stop.

4. **Persist in real time.** All writes happen the moment events occur. See `skills/web-navigator/references/session.md`.

5. **Tooling.** Navigator's Phase 1 runs `bash skills/web-navigator/scripts/check-env.sh`. Install with `npm install -g @playwright/cli` if missing.

## Architecture

**One source of truth.** Skill content lives in `skills/`. The `.github/` directory is a thin adapter for GitHub Copilot — it points at `skills/`, never duplicates content. Every other agent reads `skills/` directly.

**Navigator is the entry point.** Testing skills are **active-skill libraries** — methodology + heuristics + rules. They are loaded by Navigator during Phase 3 of every session, never invoked standalone. To add a new evaluation domain (e.g., `visual-regression-testing`), drop a sibling folder under `skills/` with the same shape; Navigator will load it whenever its name is passed as the active skill.

**Reusability.** `web-navigator` is reusable beyond testing — anything that needs a browser-driving orchestrator with structured sessions and evidence can adopt the navigator pattern by writing a new active-skill definition.

**Cross-agent compatibility.** `SKILL.md` files use standard YAML frontmatter (`name`, `description`). Markdown bodies use no agent-specific syntax. Any agent that can read markdown can use these skills.

## Conventions

- **Production guardrail.** Web Navigator refuses to run against production hosts by default. See `skills/web-navigator/references/environment.md`.
- **Real-time persistence.** Every event lands on disk the moment it happens. Context loss never costs prior findings.
- **Finding IDs.** Uniform format across all skills: 3-digit sequential (`001`, `002`, `003`), no per-skill prefix. The session folder name carries the skill identifier. See `skills/_testing-conventions/findings.md`.
- **Evidence caps.** 5 screenshots and 2 videos per session. Snapshots unlimited on disk but never dumped into chat.

## Adding new skills

To add a new evaluation skill (e.g., `visual-regression-testing`):

1. Create `skills/<name>/SKILL.md` with the active-skill callout, the workflow, and any skill-specific required fields / time-budget scaling table / coverage heuristic inlined directly.
2. Add `skills/<name>/references/heuristics.md` (probe catalogue).
3. If the skill uses domain-specific judgment criteria, add `references/oracles.md`.
4. Update this `AGENTS.md` skill table and the `README.md` skill index.
5. Update the composition rule above to list the new skill as a valid active-skill option (only needed if its name doesn't follow the `<domain>-testing` pattern).
6. Optional: ship a `.github/prompts/<name>.prompt.md` for Copilot users.

The skill is **atomic**: no `references/findings.md` or `references/session.md` needed. Skill-specific finding additions live inline in its `SKILL.md`, and universal testing rules are inherited from `_testing-conventions/` via composition at this entry point.

Navigator requires no changes.

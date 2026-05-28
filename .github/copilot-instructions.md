# GitHub Copilot Instructions

This repository is a generic, agent-agnostic exploratory testing toolkit. The canonical content lives in `skills/` at the repo root — these instructions point Copilot at it.

## Repository layout

| Path | Purpose |
|---|---|
| `skills/web-navigator/` | Browser orchestrator and entry point (owns mechanics, session, evidence) |
| `skills/_testing-conventions/` | Shared conventions across testing skills (ID format, severity, time budgets) — not a skill |
| `skills/functional-testing/` | User flows, validation, navigation, state, business logic |
| `skills/security-testing/` | XSS, injection, AuthN/AuthZ, CSRF, data exposure |
| `skills/accessibility-testing/` | WCAG 2.1/2.2 AA |
| `skills/performance-testing/` | Console errors, network, load timing, runtime stability |
| `exploratory-reports/` | Each session writes a timestamped folder here |

## How to use these skills

**Composition rule.** For any testing session, load these three modules together:

1. `skills/web-navigator/SKILL.md` and its references — browser mechanics, session, evidence.
2. `skills/_testing-conventions/findings.md` and `skills/_testing-conventions/session.md` — universal testing rules (ID format, severity, time-budget tiers, coverage logging).
3. The active skill's `SKILL.md` and its `references/` — methodology, heuristics, skill-specific required fields and scaling.

These three modules are independent — none cross-references the others. Composition is owned here.

When the user asks to test, navigate, evaluate, or explore a web application:

1. **Pick the active skill** based on the user's intent:
   - Clear domain → `functional-testing` / `security-testing` / `accessibility-testing` / `performance-testing`.
   - **Unclear scope** → ask the user. Do not guess.
   - **Multi-domain coverage** → run separate sessions per focus area.
2. **Load the three modules above** into context.
3. **Follow Web Navigator's phases** (Setup → Prepare → Navigate & Check → Close). Navigator drives mechanics; the active skill provides methodology; `_testing-conventions/` provides the universal rules.
4. **Run** `bash skills/web-navigator/scripts/check-env.sh` (Navigator does this in Phase 1). Install `playwright-cli` if missing.
5. **Persist every event immediately** — `audit.log` append-only, findings land on disk before counters update.
6. **Close the session** with the concise summary from Phase 4.

## Prompts available

- `/explore` — see `.github/prompts/explore.prompt.md` for an end-to-end exploratory testing run.

## Non-negotiable rules

- **Production guardrail.** Never run against production hosts. See `skills/web-navigator/references/environment.md`.
- **Browser tool exclusivity.** All browser interaction through `playwright-cli`. MCP browser tools are banned once playwright-cli is confirmed.
- **No host-project test reads.** Do not read Playwright tests, page objects, or fixtures in the host project as a substitute for live browser interaction.
- **Real-time write policy.** Every event lands on disk the moment it happens — `audit.log` first, then snapshot, then finding file, then counters.
- **Finding IDs.** Uniform format across all skills: 3-digit sequential (`001`, `002`, `003`), no per-skill prefix. The session folder name carries the skill identifier.
- **Evidence caps.** 5 screenshots max, 2 videos max per session. Snapshots unlimited on disk, never dumped into chat.

## Architectural notes

**Three independent modules, composition at the entry point.**

- `web-navigator/` — single responsibility: browser orchestration (drive browser, manage session folder, audit log, file format, write policy). Testing-agnostic.
- `_testing-conventions/` — single responsibility: universal testing rules (ID format, severity scale, time-budget tiers, coverage logging, missed-coverage reporting). Same across every testing skill.
- Each testing skill (`<domain>-testing/`) — single responsibility: domain methodology + heuristics + skill-specific required fields. Atomic — no cross-references to other modules.

None of the three references the others. This file (and `AGENTS.md`, `.github/prompts/explore.prompt.md`) owns composition: telling the agent which modules to load together for a testing session.

To add a new evaluation domain, create `skills/<name>/SKILL.md` + `references/heuristics.md`. List it in the skill table above. The composition rule already covers it.

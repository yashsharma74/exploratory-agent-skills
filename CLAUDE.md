# Claude Code Entry Point

Claude Code reads `CLAUDE.md` automatically. This file is a thin shim — the canonical entry is **[`AGENTS.md`](AGENTS.md)**.

## Composition rule (the only rule that matters)

For any testing session, load these three modules together:

1. **`skills/web-navigator/SKILL.md`** and its references — browser mechanics, session, evidence, write policy.
2. **`skills/_testing-conventions/findings.md`** and **`skills/_testing-conventions/session.md`** — universal testing rules (ID format, severity scale, time-budget tiers, coverage logging).
3. **The active skill's `SKILL.md`** — pick one of `functional-testing` / `security-testing` / `accessibility-testing` / `performance-testing` based on the user's intent.

Then follow Web Navigator's 4-phase workflow (Setup → Prepare → Navigate & Check → Close). Use the scripts in `skills/web-navigator/scripts/` for every session mutation — they enforce format, atomicity, and consistent timestamps.

## Quick reference

- Workflow scripts: `skills/web-navigator/scripts/` (init/log/find-ref/write-finding/end/validate)
- Canonical example: `exploratory-reports/EXAMPLE-functional-testing-the-internet-login/`
- Picking the active skill: clear domain → that skill; unclear → ask the user; multi-domain → run separate sessions

## Picking the skill from user intent

| User intent contains | Active skill |
|---|---|
| security, xss, injection, auth, idor, csrf, vulnerability | `security-testing` |
| accessibility, a11y, wcag, keyboard, screen reader, contrast | `accessibility-testing` |
| performance, slow, load, network, console, runtime | `performance-testing` |
| functional, flow, form, validation, business logic, regression | `functional-testing` |
| (unclear / multi-domain) | ask the user; do not guess |

See `AGENTS.md` for the full picture.

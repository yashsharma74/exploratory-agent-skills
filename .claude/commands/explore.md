# /explore — Explorer Agent

Generic exploratory testing orchestrator. Works with any website or web app.

---

## Step 1 — Parse the invocation

Extract from the user's prompt:

| Field | How to detect |
|-------|--------------|
| `TARGET_URL` | First `https://` or `http://` URL in the prompt |
| `AUTH_TYPE` | See auth keywords below |
| `CREDENTIALS` | Text after `login:`, `credentials:`, `basic auth:`, `sso via X \|`, `api key:`, `bearer token:` |
| `FOCUS` | Word(s) after `focus` — security / accessibility / performance / functional / charters |
| `NOTES` | Remaining free text |
| `CONTINUE` | Prompt contains word "continue" — skip to Continuation Protocol |

**Auth keyword detection:**
- `login:` or `credentials:` → `FORM`
- `sso via X` or `oauth X` or `sign in with X` → `SSO` (provider = X)
- `basic auth:` or `http basic:` → `BASIC`
- `api key:` → `API_KEY`
- `bearer token:` → `BEARER`
- No auth keyword → `PUBLIC` (attempt unauthenticated access first)

---

## Step 2 — Load shared files (mandatory, in this exact order)

```
Read: .claude/skills/_shared/context-limits.md
Read: .claude/skills/_shared/orchestration.md
Read: .claude/skills/_shared/auth-detection.md
Read: .claude/skills/_shared/report-templates.md
Read: .claude/skills/_shared/heuristic-examples.md
```

Do not proceed until all five files are loaded.

---

## Step 3 — Route to skill

Based on `FOCUS`:

| FOCUS keyword | Skill to load |
|---------------|--------------|
| `security` / `xss` / `injection` / `auth` / `idor` | `.claude/skills/security-testing/SKILL.md` |
| `accessibility` / `wcag` / `a11y` / `keyboard` / `screen reader` | `.claude/skills/accessibility-testing/SKILL.md` |
| `performance` / `load` / `console` / `network` / `slow` | `.claude/skills/performance-testing/SKILL.md` |
| `functional` / `flow` / `form` / `validation` / `bug` | `.claude/skills/functional-testing/SKILL.md` |
| `charters` / `plan` / `planning` | `.claude/skills/charters-creation/SKILL.md` |
| anything else / unclear / general | `.claude/skills/exploratory-testing/SKILL.md` |

Load the selected skill file, then execute it. All execution logic lives in the skill.

---

## Step 4 — Continuation protocol

If the prompt contains "continue":

1. If a specific report path was given, read that `README.md`.
   Otherwise, find the most recent report in `exploratory-reports/` and read its `README.md`.
2. Reconstruct session state from Activity Log and Findings sections.
3. Recompute elapsed duration from Activity Log timestamps.
4. Announce: "Resuming [skill] session. Prior duration: [X]m. [N] findings. Continuing from: [last checkpoint]."
5. Load the same skill that was active and continue execution from the last checkpoint.
6. Maintain all existing finding IDs — never renumber.

---

## Notes for the agent

- `TARGET_URL` is the single source of truth for the session's base URL. Never navigate outside it unless following an auth redirect.
- Credentials extracted from the prompt are sensitive — never echo them in reports or logs. Use `[REDACTED]` when referencing credentials.
- If no `TARGET_URL` is found and "continue" is not in the prompt, respond: "Please provide a URL. Example: `/explore https://example.com`"
- If auth credentials are needed but not provided, check `auth-detection.md` for how to handle the missing credentials.

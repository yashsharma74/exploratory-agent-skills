---
mode: agent
description: Run an exploratory testing session against a web application. Picks the right skill, drives a real browser via playwright-cli, captures evidence, writes structured findings to disk.
---

# /explore — Exploratory Testing Session

Run a structured exploratory testing session against a web application. Web Navigator (`skills/web-navigator/`) is the entry point; this prompt parses the user's invocation, picks the active skill, and hands off to Navigator.

## Parameters from the user prompt

Parse the user's invocation for:

| Field | How to detect |
|---|---|
| `TARGET_URL` | First `https://` or `http://` URL in the prompt |
| `AUTH` | Keywords: `login:`, `credentials:`, `sso via X`, `oauth X`, `sign in with X`, `basic auth:`, `http basic:`, `api key:`, `bearer token:`. See `skills/web-navigator/references/credentials.md` |
| `FOCUS` | Word(s) after `focus`: security / accessibility / performance / functional. Picks the active skill. |
| `NOTES` | Remaining free text — feature to explore, known issues, etc. |
| `CONTINUE` | Prompt contains "continue" — resume the most recent session in `exploratory-reports/` (or the one named after "continue") |

## Active skill selection

Based on `FOCUS`:

| FOCUS | Active skill (passed to Navigator) |
|---|---|
| `security`, `xss`, `injection`, `auth`, `idor` | `security-testing` |
| `accessibility`, `a11y`, `wcag`, `keyboard`, `screen reader` | `accessibility-testing` |
| `performance`, `slow`, `load`, `network`, `console` | `performance-testing` |
| `functional`, `flow`, `form`, `validation` | `functional-testing` |
| (missing / unclear) | Do not pick. Navigator's Phase 1 will ask the user which skill to use. |
| (multi-domain) | Invoke `/explore` once per focus area — one Navigator session per domain. Do not try to cover multiple domains in a single session. |

## Execution

1. **Load the three composition modules** into context (this prompt owns composition):
   - `skills/web-navigator/SKILL.md` and its references — browser mechanics, session, evidence.
   - `skills/_testing-conventions/findings.md` and `skills/_testing-conventions/session.md` — universal testing rules.
   - `skills/<active-skill>/SKILL.md` and `skills/<active-skill>/references/` — domain methodology + heuristics.
2. **Invoke Navigator** with the parsed parameters as Phase 1 inputs:
   - `active skill` = the value selected above
   - `target URL` = `TARGET_URL`
   - `credentials` = whatever `AUTH` resolved to (or `interactive` / `default` if none supplied)
   - `notes` = `NOTES` (passed verbatim into `session.md` Original User Prompt)
3. **Let Navigator run its four phases.** Navigator drives mechanics, the active skill drives methodology, `_testing-conventions/` provides universal rules — all already in context from step 1.
4. **Return** Navigator's Phase 4 end-of-session summary.

For `CONTINUE`, follow Navigator's [Continuation Protocol](../../skills/web-navigator/references/session.md#continuation-protocol) instead of starting fresh.

## Hard rules

- Never navigate to production hosts. The guardrail in `skills/web-navigator/references/environment.md` applies to every `goto` and every redirect.
- Never echo plaintext passwords. Use `<password redacted>` in audit log entries.
- Use only `playwright-cli` for browser interaction. MCP browser tools are banned once playwright-cli is confirmed.
- Keep chat output minimal. The session folder is the deliverable, not chat.

## Example invocations

```
/explore https://example.com
/explore https://app.example.com  login: user@example.com / pass
/explore https://app.example.com  sso via google | user@gmail.com / pass  focus security
/explore https://app.example.com  api key: sk-abc123  focus performance
/explore continue
```

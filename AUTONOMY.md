# Running Sessions Autonomously

Every approval prompt is a context switch — for the agent and for you. A real exploratory testing session needs to run end-to-end without interruption. This document covers how to grant the right permissions per agent.

## Why approvals happen

A typical 30-minute session calls:
- ~20–40 `playwright-cli` commands (`goto`, `snapshot`, `click`, `fill`, `eval`, `screenshot`)
- ~50–80 calls into `skills/web-navigator/scripts/*` (init, log, check, finding, screenshot, end, validate, report)
- Many read / grep / awk for snapshot parsing
- File writes under `exploratory-reports/[session-id]/`

If your agent prompts for each `Bash` call, that's hundreds of approvals per session. Pre-authorize the patterns once and you're done.

---

## Claude Code

Project-level settings — committed to the repo so anyone working on this codebase gets the same pre-approval:

`.claude/settings.json` (already created in this repo):

```json
{
  "permissions": {
    "allow": [
      "Bash(playwright-cli *)",
      "Bash(skills/web-navigator/scripts/*)",
      "Bash(./skills/web-navigator/scripts/*)",
      "Bash(mkdir *)", "Bash(touch *)", "Bash(ls *)", "Bash(cat exploratory-reports/*)",
      "Bash(head *)", "Bash(tail *)", "Bash(grep *)", "Bash(find *)",
      "Bash(awk *)", "Bash(sed *)", "Bash(date *)", "Bash(wc *)",
      "Bash(node -e *)", "Bash(python3 *)", "Bash(printf *)",
      "Bash(rm exploratory-reports/2*)", "Bash(mv exploratory-reports/2* *)",
      "Read(exploratory-reports/**)", "Read(skills/**)",
      "Write(exploratory-reports/**)", "Edit(exploratory-reports/**)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(curl *)", "Bash(wget *)",
      "Bash(git push *)", "Bash(git reset --hard *)"
    ]
  }
}
```

Personal overrides go in `.claude/settings.local.json` (gitignored).

To enable: restart Claude Code (or it picks up changes on next session). Verify with `/permissions` slash command.

For full autonomy (bypass even prompts that would normally still fire), launch Claude Code with `--dangerously-skip-permissions` — only do this for read-mostly sessions or in a sandboxed environment.

---

## GitHub Copilot

Copilot's agentic mode (Copilot Workspace, Copilot Chat agent) auto-approves Bash and file operations when run via the `/explore` prompt. No special config needed beyond `.github/copilot-instructions.md` (already in this repo).

For Copilot Chat (Visual Studio Code), individual tool runs may still prompt; respond "Yes" once per tool family at the start of the session.

---

## Cursor

`.cursor/rules/exploratory-testing.mdc` (already in this repo) auto-applies. For autonomous execution, enable "Yolo mode" or allowlist Bash in Cursor settings → Features → Auto-run.

---

## OpenAI Codex CLI

Run with `--full-auto` flag and an allowlist file. Example:

```bash
codex --full-auto --allow-shell "playwright-cli *,skills/web-navigator/scripts/*"
```

`AGENTS.md` (at repo root) describes the composition rule and is auto-loaded.

---

## Safety: the deny list

Even in autonomous mode, the project's `settings.json` denies dangerous patterns:

- `Bash(rm -rf *)` — never wildcard-rm
- `Bash(curl *)`, `Bash(wget *)` — no outbound HTTP outside playwright-cli (which has the production guardrail)
- `Bash(git push *)`, `Bash(git reset --hard *)` — never modify git state

If you need any of these (e.g., curl for an unusual API check), the agent will prompt — which is the right behavior, because the deny list is your circuit breaker.

---

## Verifying autonomy works

Run the canonical example reproduction:

```
Continue session 2026-05-27T162706Z-functional-testing-the-internet-login
```

A fully autonomous setup should complete the continuation with **zero approval prompts** until the session closes. If you see any prompt, copy the rejected tool call into the allowlist and re-run.

---

## What the agent is NOT allowed to do

Even with maximal allowlists, by design:

- **Cannot edit the toolkit itself** mid-session (`skills/**` is read-only from the agent's perspective during a session)
- **Cannot modify the canonical examples** (`exploratory-reports/EXAMPLE-*` is write-protected by convention)
- **Cannot touch git** beyond reading state
- **Cannot reach production** unless `ALLOW_PRODUCTION="<justification>"` is set on `goto.sh` (logged to audit trail)

These limits keep the toolkit deterministic across sessions. The agent's creativity lives in the testing — not in modifying the contract.

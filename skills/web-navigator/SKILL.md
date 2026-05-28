---
name: web-navigator
version: "1.0.0"
description: Autonomous web navigation agent that drives a browser step-by-step and applies pluggable skills at each action. Use when navigating, testing, verifying, or evaluating product flows through a real browser. The same flow can be evaluated through different lenses by swapping the active skill (functional, security, accessibility, performance, exploratory, or any user-supplied rule set).
---

# Web Navigator

Web Navigator is **the entry point** for this toolkit. It is the orchestrator — it does **not** know what to test, but it knows how to drive a browser, persist evidence, and apply rules from whatever skill is active. The active skill provides the rules; Web Navigator runs them.

Testing skills (`functional-testing`, `security-testing`, `accessibility-testing`, `performance-testing`) are **active-skill definitions** — methodology + rules. They are loaded *by* Navigator during Phase 3, never invoked directly.

## Use when

- Navigating and evaluating a web flow, feature, or user journey
- Driving a test against a pluggable active skill (any skill whose `SKILL.md` declares the additional files Navigator should load)
- Verifying behavior against acceptance criteria or use cases
- Exploring a product area through a specific evaluation lens

## Do NOT use when

- No browser interaction is needed
- Task is purely code review or static analysis
- Task requires modifying application code

---

## Workflow

### Phase 1 — Setup

Load [`references/setup.md`](references/setup.md), [`references/environment.md`](references/environment.md), [`references/credentials.md`](references/credentials.md), and [`references/viewports.md`](references/viewports.md).

1. **Tool check:** run [`scripts/check-env.sh`](scripts/check-env.sh). If `playwright-cli` is missing, install with `npm install -g @playwright/cli` (ask the user first) or stop.

2. **Host check:** [`scripts/check-host.sh`](scripts/check-host.sh) `<target-url>`. Exit 0 = proceed; exit 1 = stop; exit 2 = ask user to confirm before proceeding.

3. **Apply defaults silently.** Only ask the user when a value would otherwise fail. Defaults: Staging, time-limit=15min, evidence=text+screenshots, headless, viewport=desktop, credentials from prompt/`.env` if available else `interactive`. Required from the user only when missing and undefaultable: **target URL** and **active skill name**.

### Phase 2 — Prepare

Load [`references/test-data.md`](references/test-data.md) and [`references/session.md`](references/session.md).

1. Set up required test data fixtures (see `test-data.md`).
2. **Initialize session:** `SESSION_DIR=$(scripts/init-session.sh <skill> <feature>)`. The script creates the folder, writes `session.md`, and creates an empty `audit.log`. Then fill in `session.md` placeholders (Target URL, Environment, Credentials, Viewport, Time Limit, Original User Prompt) — one edit, no template prose.

### Phase 3 — Navigate & Check

Load [`references/orchestration.md`](references/orchestration.md), [`references/playwright.md`](references/playwright.md), [`references/checks.md`](references/checks.md), [`references/findings.md`](references/findings.md), [`references/evidence.md`](references/evidence.md), **and the active skill's `SKILL.md`**.

1. Parse user instructions into ordered navigation steps — see `orchestration.md`.
2. Execute the orchestration loop per step. Use `scripts/log-audit.sh` for every audit entry, `scripts/write-finding.sh` for every finding. Never hand-write `audit.log` or finding files.

### Phase 4 — Close

1. **Finalize:** `scripts/end-session.sh "$SESSION_DIR"` — recomputes counters from `audit.log`, sets Status to `completed`, prints a one-line summary.
2. **Validate:** `scripts/validate-session.sh "$SESSION_DIR"` — exit 0 = clean session; exit 1 = compliance violations the agent should report.
3. **Generate report:** `scripts/generate-report.sh "$SESSION_DIR"` — writes a human-readable `report.md` alongside the raw artifacts, suitable for sharing with stakeholders.
4. **Print summary:** `scripts/summarize-session.sh "$SESSION_DIR"` — emit the short summary block to chat.

The session folder is the deliverable: raw artifacts (`session.md`, `audit.log`, `findings/`, `evidence/`, `snapshots/`) for re-running and verification, plus the generated `report.md` for human review.

---

## Loading Protocol

Files are loaded **on-demand per phase**, not all at once.

**Read-once rule:** Read each reference file once per session. After the initial load, rely on in-context knowledge — do not re-read the same file.

| Phase | Files loaded |
|---|---|
| Phase 1 | `references/setup.md`, `references/environment.md`, `references/credentials.md`, `references/viewports.md` |
| Phase 2 | `references/test-data.md`, `references/session.md` |
| Phase 3 | `references/orchestration.md`, `references/playwright.md`, `references/checks.md`, `references/findings.md`, `references/evidence.md`, active skill's `SKILL.md` (which prescribes its own additional files) |
| Phase 4 | (no new files) |

---

## Output

Web Navigator produces a session folder, not a formatted report. See `references/session.md` for the folder structure and contents. Downstream consumers (a report-writing skill, a CI step, a human) interpret the raw artifacts.

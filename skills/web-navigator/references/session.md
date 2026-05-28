# Session Management

Container for time tracking, audit trail, and continuation data. The session tracks what happened and enables recovery — it does not define time budgets or step limits (those belong to the active skill).

**All mutating operations are deterministic scripts in `../scripts/`.** Do not hand-write `session.md`, `audit.log`, or finding files. Call the scripts; they enforce format, atomic writes, and consistent timestamps.

---

## Folder Structure

```
exploratory-reports/[YYYY-MM-DDTHHMMSSZ]-[skill]-[feature]/
├── session.md          # Metadata + counters + continuation info
├── audit.log           # Append-only event trail
├── findings/           # One .md file per failed check (001.md, 002.md, ...)
├── evidence/           # Screenshots, videos, console logs
└── snapshots/          # DOM snapshots
```

Created atomically by `init-session.sh`. The output dir can be overridden with `$EXPLORATORY_REPORTS_DIR` or a 3rd arg to the script.

---

## Scripts

| Script | Purpose |
|---|---|
### Lifecycle

| Script | Purpose |
|---|---|
| `init-session.sh <skill> <feature> [reports-dir]` | Create folder + `session.md` header + empty `audit.log`. Prints session-dir path on stdout. Respects `$EXPLORATORY_REPORTS_DIR`. |
| `set-field.sh <session-dir> "<Field>" "<value>"` | Set a `\| Field \| ... \|` row in `session.md`. |
| `end-session.sh <session-dir>` | Recompute counters, set Status=completed, log the close event. |
| `summarize-session.sh <session-dir>` | Print the standard end-of-session summary block. |
| `generate-report.sh <session-dir>` | Write a human-readable `report.md` to the session folder (mission + summary + findings + activity timeline + reproduction steps). |
| `validate-session.sh <session-dir>` | Compliance check. Exit 0 = pass, 1 = violations. |

### Logging primitives

| Script | Purpose |
|---|---|
| `log-audit.sh <dir> <TYPE> <msg> [level]` | Append one entry to `audit.log` (auto-format, newline-strip). |
| `next-id.sh <dir>` | Print and bump `Next finding number` atomically. |

### Browser + check pairings (these enforce invariants the agent often forgets)

| Script | What it pairs |
|---|---|
| `goto.sh <dir> <url> [blocklist]` | `check-host.sh` + `playwright-cli goto` + `log-audit NAV` + **auto-snapshot** to `snapshots/NN-<slug>.yaml`. Exit 0 ok, 1 blocked, 2 ambiguous. |
| `screenshot.sh <dir> <description> [ref]` | `playwright-cli screenshot --filename=…` + `log-audit EVIDENCE`. Env: `FINDING_ID` (embeds in filename for failure evidence), `FULL_PAGE`. |
| `pass-check.sh <dir> <rule-id> <description>` | `log-audit CHECK "<rule> — PASS — <description>"`. |
| `fail-check.sh <dir> <rule-id> <severity> <title>` | `log-audit CHECK FAIL` + `write-finding.sh`. Body fields via env vars (`LOCATION`, `STEPS`, `EXPECTED`, `ACTUAL`, `EVIDENCE`, `RECOMMENDATION`, `EXTRA_FIELDS`). Enforces the FAIL → finding invariant at the moment of failure. |

### Lower-level helpers

| Script | Purpose |
|---|---|
| `find-ref.sh <snapshot> <role> <name>` | Extract an element ref (e.g. `e21`) from a snapshot YAML — robust to whitespace and quoting. |
| `write-finding.sh <dir> <Severity> <title>` | Used by `fail-check.sh`. Call directly only if writing a finding outside a FAIL flow. |
| `check-host.sh <url> [blocklist]` | Production guardrail standalone. Used by `goto.sh`. |
| `check-env.sh` | Verify `playwright-cli` is on PATH. |

---

## `session.md` schema

After `init-session.sh`, `session.md` has these sections. Edit the placeholder fields (`Target URL`, `Environment`, etc.) once during Phase 1 setup; scripts maintain everything else.

| Section | Maintained by |
|---|---|
| `## Info` table | User/agent fills `Target URL`, `Environment`, `Credentials`, `Evidence Level`, `Viewport`, `Navigation Source`, `Time Limit` during Phase 1. `Session ID`, `Active Skill`, `Started`, `Status` are set by `init-session.sh` and `end-session.sh`. |
| `## Original User Prompt` | User/agent fills with the **exact, verbatim** user message. If not available, record `unavailable — orchestrator did not pass through original`. |
| `## Refined Prompt` | Orchestrator-elaborated version, or `n/a`. |
| `## Fixtures` table | User/agent maintains during Phase 2 — see [`test-data.md`](test-data.md). |
| `## Counters` table | Auto-incremented by `write-finding.sh`; recomputed by `end-session.sh` from `audit.log`. |
| `## Continuation` table | `Next finding number` auto-bumped by `next-id.sh` / `write-finding.sh`. Other fields updated on emergency pause. |

---

## `audit.log` format

Append-only. Every line: `[HH:MM:SS] [level] TYPE: description`.

| Level | Meaning |
|---|---|
| `info` | Default — decisions, actions, results, lifecycle |
| `debug` | Verbose internal detail (off by default) |
| `warn` | Non-blocking issue worth noting |
| `error` | Failure that prevented the intended outcome |

| Type | When |
|---|---|
| `SESSION` | Lifecycle: initialized / paused / resumed / completed |
| `NAV` | A `goto` or navigation command |
| `ACT` | A click, fill, select, or other browser action |
| `CHECK` | A rule check result (PASS / FAIL / N/A) |
| `EVIDENCE` | A screenshot, video, or snapshot was captured |
| `DATA` | Console logs, network summary, or other collected data |
| `SNAPSHOT` | A DOM snapshot was saved |
| `AUTH` | An authentication event (login complete, token refresh, etc.) |

All entries are emitted by `log-audit.sh`. Don't write `audit.log` directly — the script normalizes format.

### Example entries

```
[14:20:00] [info] SESSION: initialized — skill=functional-testing, feature=checkout-flow
[14:23:15] [info] NAV: goto /login → page loaded (200)
[14:23:22] [info] ACT: fill email field → value set
[14:23:25] [info] ACT: click "Log in" button → dashboard loaded
[14:23:30] [info] CHECK: functional-VAL-01 — PASS — required field shows validation error
[14:23:35] [info] CHECK: functional-VAL-02 — FAIL — max length not enforced (001)
[14:23:36] [info] EVIDENCE: screenshot captured → 02-001-max-length.png
[14:23:40] [info] DATA: console errors → 0 errors found
[14:50:00] [info] SESSION: paused — context limit reached
[15:10:00] [info] SESSION: completed — 5 passed, 2 failed
```

---

## Real-time write policy

Every event is written to disk **immediately** when it occurs.

| Event | Order |
|---|---|
| Navigation action | `log-audit.sh NAV` after the action returns |
| Rule check PASS / N/A | `log-audit.sh CHECK` |
| Rule check FAIL | (1) `log-audit.sh CHECK … FAIL`, (2) capture snapshot/screenshot, (3) `write-finding.sh` |
| Evidence captured | `log-audit.sh EVIDENCE` |
| Session lifecycle | `init-session.sh` / `end-session.sh` handle it |

The strict FAIL order ensures `audit.log` is always the most complete record — if context dies between steps, the audit entry alone is enough to know "a finding was about to be written here." The scripts encode this order; following them gives it for free.

---

## Continuation Protocol

When the user asks to continue a session:

1. Locate the session folder by ID, or pick the most recent under `exploratory-reports/`.
2. Read `session.md` — note `Next finding number`, `Status`, last entry from `Continuation`.
3. Read `audit.log` to understand what was already done.
4. `log-audit.sh <dir> SESSION "resumed — continuing from <last finding ID>"`.
5. Continue the workflow. `write-finding.sh` and `log-audit.sh` will keep IDs and timestamps consistent.

Never overwrite `audit.log` or restart IDs at 001.

---

## Emergency Recovery

If context grows too large mid-session:

1. Stop browser actions immediately.
2. `log-audit.sh <dir> SESSION "paused — context limit reached"`.
3. Manually edit `session.md` Status to `paused` (or write a small helper if this becomes common).
4. Return a continuation instruction:

```
Session paused due to context limits.
Progress: N findings written, M rules applied.
To continue: "Continue session [Session ID]"
```

Because every finding and audit entry is on disk via the scripts, no information is lost.

---

## End-of-Session Summary

After `end-session.sh` runs, return one concise block:

- Finding count by severity (from `session.md` Counters)
- Steps completed (from Counters)
- Elapsed time (from `Started` vs. final `audit.log` timestamp)
- Session folder path
- Top 1–2 priority findings (Critical/High by filename order)
- Continuation prompt if incomplete

Optional: run `validate-session.sh` and include its result in the summary.

# Evidence Collection

Evidence is a session-level configuration set once during setup and applied uniformly to every check — it is not defined per rule or per skill.

---

## Evidence Levels

Configured during Phase 1 — Setup:

| Level | What is collected | When to use |
|---|---|---|
| **Text only** | Audit log entries only — no files captured | Quick checks, low-stakes exploration, rapid iteration |
| **Text + screenshots** | Audit log + `.png` per failed check + 1 pass proof | Standard sessions (recommended default) |
| **Text + screenshots + video** | Above + `.webm` recordings for complex interactions | Animation bugs, timing issues, drag-and-drop, multi-step flows |

The evidence level is set **once** at session start and does not change mid-session.

---

## Evidence Types

| Type | Format | Capture method | Notes |
|---|---|---|---|
| Screenshot | `.png` | `playwright-cli screenshot` | Primary evidence for findings |
| Video | `.webm` | `playwright-cli video-start` / `video-stop` | Only at "text + screenshots + video" level |
| Console log | text block | `playwright-cli console` | Appended to finding file as text |
| DOM snapshot | `.yaml` | `playwright-cli snapshot --filename` | Stored in session `snapshots/` folder — see [`playwright.md` — Snapshot Discipline](playwright.md#snapshot-discipline) |

---

## Collection Rules

### Text Only Level

- Audit log entries for every operation.
- No files captured in `evidence/`.
- Findings still created but with `## Evidence` section noting "Evidence level: text only".

### Text + Screenshots Level

- **Minimum 1 pass screenshot** per session — proof the happy path works.
- **1 screenshot per failed finding** — mandatory, no exceptions.
- Screenshots mandatory for CRITICAL/HIGH impact findings (by rule impact).
- Screenshots recommended for Medium/Low/Info findings.
- Console logs captured on error regardless of evidence level (appended to finding as text).

### Text + Screenshots + Video Level

- All screenshot rules above apply.
- **Video** recorded for complex interactions:
  - Timing-dependent behavior
  - Animations and transitions
  - Drag-and-drop operations
  - Multi-step flows where sequence matters
- **Maximum 2 videos** per session.
- A screenshot is still required per finding — video supplements, never replaces.

---

## Evidence Storage

All evidence files are stored in the session's `evidence/` folder (see [`session.md` — Session Initialization](session.md#session-initialization) for the full folder structure).

### Naming Convention

```
[NN]-[short-description].[ext]

NN:          Two-digit sequential number (01, 02, 03...)
description: Hyphenated short description (include finding ID for failures)
ext:         .png for screenshots, .webm for videos
```

Examples:
- `01-pass-proof-login-success.png`
- `02-001-empty-name-accepted.png`
- `03-002-xss-alert-fired.png`
- `04-003-timing-animation-bug.webm`

### Linking

Every evidence file **must** be referenced from:
- Its finding file (`## Evidence` section) — for failure evidence.
- The audit log (`EVIDENCE` entry) — for all evidence.

No orphaned files in `evidence/` — if a file exists, it must be referenced somewhere.

---

## Evidence Limits (Hard Caps)

- Screenshots: **5 max per session** — prioritize Critical/High findings + the 1 pass proof.
- Videos: **2 max per session**.
- DOM snapshots: unlimited on disk; read selectively (never dump into chat).

When a limit is reached, log it and continue without further captures in that category:

```
[HH:MM:SS] [info] EVIDENCE: screenshot cap reached (5) — further failures recorded in audit + finding files only
```

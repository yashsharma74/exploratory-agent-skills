# Shared: Report Templates

All Explorer Agent skills write reports using this structure. The report file is the session's source of truth.

---

## Directory naming

```
exploratory-reports/
  [YYYY-MM-DDTHHMMSSZ]-[skill]-[feature-slug]/
    README.md
    screenshots/
      01-baseline.png
      02-[description].png
```

**Skill slugs:** `exploratory`, `functional`, `security`, `accessibility`, `performance`, `charters`

**Feature slug:** kebab-case summary of what was tested (e.g., `checkout-flow`, `user-login`, `admin-dashboard`, `search`)

**Example:** `exploratory-reports/2025-01-15T143022Z-security-checkout/`

---

## README.md template

Use this exact structure. Populate each section as the session progresses — do not wait until the end.

```markdown
# Exploratory Testing Report

## Session Info

| Field | Value |
|-------|-------|
| Target | [URL] |
| Feature / Area | [what was tested] |
| Skill | [exploratory / functional / security / accessibility / performance] |
| Primary Heuristic | [heuristic name, e.g., SFDPOT, STRIDE, POUR] |
| Auth Type | [public / form / sso-google / basic / api-key] |
| Account Used | [email or username — no password] |
| Environment | [production / staging / dev / local / unknown] |
| Date | [YYYY-MM-DD] |
| Duration | [X minutes] |
| Tester | Claude (Explorer Agent) |
| Status | [IN_PROGRESS / COMPLETE / INTERRUPTED / CONTINUED] |

---

## Top Findings Summary

> Updated at each checkpoint.

| ID | Type | Severity | Title | Status |
|----|------|----------|-------|--------|
| [ID] | [Bug/Vuln/A11y/Perf/UX] | [Critical/High/Med/Low/Info] | [one-line title] | [Open/Noted] |

**Open Critical/High:** [N]
**Newest finding:** [ID — title]
**Regression risk:** [High/Medium/Low — one sentence reason]

---

## Activity Log

> One line per action. Format: `HH:MM [action taken] — [result/observation]`

| Time | Action | Result |
|------|--------|--------|
| HH:MM | [action] | [result] |

---

## Findings

> Write each finding immediately upon discovery.

### [ID]: [One-line title]

| Field | Value |
|-------|-------|
| ID | [F-001 / S-001 / A-001 / P-001] |
| Type | [Bug / Vulnerability / A11y Violation / Performance / UX Issue] |
| Severity | [Critical / High / Medium / Low / Info] |
| Status | [Open / Needs Verification / Noted] |
| Location | [URL path + element/component] |
| Heuristic | [which letter/dimension of the active heuristic triggered this] |

**Steps to reproduce:**
1. [step]
2. [step]

**Expected:** [what should happen]

**Actual:** [what actually happens]

**Screenshot:** `screenshots/[NN]-[description].png`

**Recommendation:** [one sentence — what to fix or investigate]

---

## Evidence Index

### Passing evidence (things that worked correctly)

| Area | Observation | Screenshot |
|------|-------------|-----------|
| [area] | [what passed] | [file or N/A] |

### Failing evidence

| Finding ID | Screenshot | Notes |
|-----------|-----------|-------|
| [ID] | [file] | [context] |

---

## Checkpoints

> Written every 5–15 minutes during the session.

### Checkpoint [N] — HH:MM

**Testing so far:** [what was covered]
**Heuristic coverage:** [which letters tested / which marked NT]
**Open findings:** [count and IDs]
**Next planned actions:** [2–3 bullet points]
**Status:** [ON_TRACK / SCOPE_ADJUSTED / INTERRUPTED]

---

## Session Summary

| Field | Value |
|-------|-------|
| Total duration | [X minutes] |
| Pages visited | [N] |
| Findings total | [N] |
| Critical | [N] |
| High | [N] |
| Medium | [N] |
| Low | [N] |
| Info | [N] |
| Heuristic | [name] |
| Coverage | [letters tested vs NT] |
| Status | [COMPLETE / INTERRUPTED / CONTINUED] |

**Priority actions:**
1. [most critical thing to fix/investigate]
2. [second priority]
3. [third priority]

**Areas not covered (for next session):**
- [area 1]
- [area 2]

**Continuation command:**
```
/explore continue exploratory-reports/[session-dir]/README.md
```
```

---

## Finding ID scheme

| Skill | Prefix | Example |
|-------|--------|---------|
| Functional | `F-` | F-001, F-002 |
| Security | `S-` | S-001, S-002 |
| Accessibility | `A-` | A-001, A-002 |
| Performance | `P-` | P-001, P-002 |
| Exploratory (mixed) | `E-` | E-001, E-002 |
| Prose / Copy | `C-` | C-001, C-002 |

IDs are **stable** — never renumber across continuations.

---

## Severity definitions

| Severity | Meaning |
|----------|---------|
| **Critical** | Security vulnerability, data loss, auth bypass, complete feature failure |
| **High** | Significant user impact, major flow broken, WCAG A violation, data corruption |
| **Medium** | Moderate impact, workaround exists, WCAG AA violation, noticeable perf degradation |
| **Low** | Minor UX issue, cosmetic defect, informational finding, minor copy issue |
| **Info** | Observation worth noting, not a defect, suggestion for improvement |

---

## Duration accuracy rule

The duration in Session Summary must equal the sum of actual time between first and last Activity Log entry for each chunk. Do not estimate — compute from timestamps.

When continuing a session:
- New chunk duration = time from first new Activity Log entry to last
- Total duration = prior session duration + new chunk duration
- Update the Session Summary duration field accordingly

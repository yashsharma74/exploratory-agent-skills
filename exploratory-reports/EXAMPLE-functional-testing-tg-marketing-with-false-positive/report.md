# Exploratory Testing Report

**Session:** `2026-05-27T171206Z-functional-testing-www-tg-marketing`

---

## Mission

> Test www.testgorilla.com marketing site to find functional and UX gaps (read-only)

**Scope guard:** NO form submissions, NO account creation, NO state changes

**Scenarios planned:** S1: homepage nav (LIST), S2: test library (INPUT+LIST), S3: pricing (STATE)

## Session Info

| Field | Value |
|---|---|
| Active Skill | `functional-testing` |
| Target | https://www.testgorilla.com |
| Environment | Production (marketing site — user-authorized read-only) |
| Credentials | none (public marketing) |
| Evidence Level | text + screenshots |
| Viewport | desktop (1280x720) |
| Time Limit | 10 min |
| Started | 2026-05-27T171206Z |
| Status | **completed** |

## Outcome

- **Navigation steps:** 4
- **Checks passed:** 6
- **Checks failed:** 1
- **Evidence captured:** 7 file(s)
- **First entry:** 17:12:06
- **Last entry:** 17:18:11

### Findings by severity

| 🔴 Critical | 🟠 High | 🟡 Medium | 🟢 Low | 🔵 Info | **Total** |
|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 | 0 | **1** |

## Findings

### 🔴 Critical

#### `001` — Reflected XSS via search input

🟨 needs-retest · **Rule:** `functional-INPUT-XSS-01` · **Discovered:** `2026-05-27T17:15:19Z`


## Location

—

## Steps to Reproduce

1. ...

## Expected

—

## Actual

—

## Evidence

—

## Verification

Investigated after auto-write — **false positive**.

Evidence:
- `alertsOpen` (queried via JS) = `no` — no JS alert dialog opened.
- The `<script>` tag in the snapshot appears only as the **textbox value** (HTML-escaped input value, not executed).
- The `alert` ARIA role in the snapshot is on an aria-live region announcing the page title — unrelated to JS `alert()`.

Detection script used naive grep on the snapshot file, which is the accessibility tree (text representation), not the rendered HTML. The text "<script>" being present in the tree does not imply unescaped HTML execution.

Lesson for the toolkit: auto-detection probes should log a DATA observation, not auto-write a CHECK FAIL + finding. Expert verification must come first.

## Recommendation

—

---

## Activity Timeline

Key events from `audit.log` (full log retained in the session folder):

- ▶️  [17:12:06] [info] SESSION: initialized — skill=functional-testing, feature=www-tg-marketing
- 🎯 [17:12:08] [info] SESSION: mission — Test www.testgorilla.com marketing site to find functional and UX gaps (read-only)
- 🛡️  [17:12:08] [info] SESSION: scope-guard — NO form submissions, NO account creation, NO state changes
- 📋 [17:12:08] [info] SESSION: scenarios — S1: homepage nav (LIST), S2: test library (INPUT+LIST), S3: pricing (STATE)
- ⚠️  [17:12:29] [warn] SESSION: production override accepted — https://www.testgorilla.com — justification: user authorized read-only testing of marketing site
- 🧭 [17:12:32] [info] NAV: goto https://www.testgorilla.com → https://www.testgorilla.com/ ("TestGorilla: AI-Powered Talent Sourcing & Skills Assessments"); console: 7 errors, 0 warnings
- ⚠️  [17:13:24] [warn] SESSION: production override accepted — https://www.testgorilla.com/pricing/ — justification: continued read-only browse
- 🧭 [17:13:26] [info] NAV: goto https://www.testgorilla.com/pricing/ → https://www.testgorilla.com/pricing/ ("Pricing - Sign up for free - TestGorilla"); console: 12 errors, 1 warnings
- ✅ [17:13:29] [info] CHECK: functional-NAV-01 — PASS — Pricing link navigates to /pricing/ (/pricing/)
- ⚠️  [17:14:04] [warn] SESSION: production override accepted — https://www.testgorilla.com/test-library/ — justification: continued read-only browse — test library page
- 🧭 [17:14:06] [info] NAV: goto https://www.testgorilla.com/test-library/ → https://www.testgorilla.com/test-library/ ("Test Library | Pre-Employment Tests for all Job Roles - TestGorilla"); console: 11 errors, 0 warnings
- ✅ [17:14:13] [info] CHECK: functional-NAV-02 — PASS — Test library reachable at /test-library/
- ✅ [17:15:06] [info] CHECK: functional-INPUT-01 — PASS — empty search submit does not crash (search=)
- ❌ [17:15:18] [info] CHECK: functional-INPUT-XSS-01 — FAIL — Reflected XSS via search input
- 📝 [17:15:19] [info] SESSION: finding recorded — 001 (Critical) — Reflected XSS via search input
- ✅ [17:15:26] [info] CHECK: functional-INPUT-03 — PASS — Long query (1000 chars) accepted without crash
- ✅ [17:15:36] [info] CHECK: functional-INPUT-04 — PASS — Emoji search handled
- ⚠️  [17:16:50] [warn] SESSION: production override accepted — https://www.testgorilla.com/pricing/ — justification: continued read-only browse — pricing page
- 🧭 [17:16:53] [info] NAV: goto https://www.testgorilla.com/pricing/ → https://www.testgorilla.com/pricing/ ("Pricing - Sign up for free - TestGorilla"); console: 14 errors, 1 warnings
- ✅ [17:17:37] [info] CHECK: functional-STR-01 — PASS — Pricing page exposes 4 plans (Free, Core, Plus, Enterprise) — documentation/label consistency
- 🏁 [17:17:41] [info] SESSION: completed — 6 passed, 1 failed, 4 steps

## Reproducing the Findings

**Environment setup:**

1. Open a browser with viewport desktop (1280x720).
2. Navigate to `https://www.testgorilla.com`.
3. Authenticate with credentials: `none (public marketing)`.

**For each finding above:**

1. Follow the `## Steps to Reproduce` section.
2. Observe the page behavior.
3. Compare against the `## Expected` and `## Actual` sections.
4. Confirm the issue persists, or re-run with the snapshot/screenshot evidence as reference.

**Evidence files** are linked from each finding above and live in:

- `exploratory-reports/EXAMPLE-functional-testing-tg-marketing-with-false-positive/evidence/` — screenshots (`.png`) and videos (`.webm`)
- `exploratory-reports/EXAMPLE-functional-testing-tg-marketing-with-false-positive/snapshots/` — accessibility-tree snapshots (`.yaml`)

## Re-Running This Session

Use Web Navigator's continuation protocol from any agent context:

    Continue session 2026-05-27T171206Z-functional-testing-www-tg-marketing

Or start a fresh session against the same target with this skill:

    Run functional-testing against https://www.testgorilla.com

---

_This report was generated deterministically from the session's audit log and finding files. The session folder `exploratory-reports/EXAMPLE-functional-testing-tg-marketing-with-false-positive/` contains the full record (`session.md`, `audit.log`, `findings/`, `evidence/`, `snapshots/`)._

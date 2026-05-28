# Exploratory Testing Report

**Session:** `2026-05-27T162706Z-functional-testing-the-internet-login`

---

## Mission

> Test login flow to find auth/validation gaps

## Session Info

| Field | Value |
|---|---|
| Active Skill | `functional-testing` |
| Target | https://the-internet.herokuapp.com/login |
| Environment | Public testing playground |
| Credentials | tomsmith / SuperSecretPassword! |
| Evidence Level | text + screenshots |
| Viewport | desktop (1280x720) |
| Time Limit | 10 min |
| Started | 2026-05-27T162706Z |
| Status | **completed** |

## Outcome

- **Navigation steps:** 3
- **Checks passed:** 3
- **Checks failed:** 0
- **Evidence captured:** 2 file(s)
- **First entry:** 16:27:06
- **Last entry:** 16:27:40

### Findings by severity

| 🔴 Critical | 🟠 High | 🟡 Medium | 🟢 Low | 🔵 Info | **Total** |
|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | **0** |

## Findings

_No findings recorded._

## Activity Timeline

Key events from `audit.log` (full log retained in the session folder):

- ▶️  [16:27:06] [info] SESSION: initialized — skill=functional-testing, feature=the-internet-login
- 🎯 [16:27:07] [info] SESSION: mission — Test login flow to find auth/validation gaps
- 🧭 [16:27:14] [info] NAV: goto /login → page loaded
- ✅ [16:27:18] [info] CHECK: functional-VAL-01 — PASS — empty form rejected with validation error
- 🧭 [16:27:19] [info] NAV: goto /login → reset for probe 2
- ✅ [16:27:27] [info] CHECK: functional-VAL-02 — PASS — invalid credentials show error
- 🧭 [16:27:28] [info] NAV: goto /login → reset for probe 3
- ✅ [16:27:37] [info] CHECK: functional-F-01 — PASS — valid credentials redirect to /secure
- 🔐 [16:27:37] [info] AUTH: login complete — tomsmith via form
- 🏁 [16:27:40] [info] SESSION: completed — 3 passed, 0 failed, 3 steps

## Reproducing the Findings

**Environment setup:**

1. Open a browser with viewport desktop (1280x720).
2. Navigate to `https://the-internet.herokuapp.com/login`.
3. Authenticate with credentials: `tomsmith / SuperSecretPassword!`.

## Re-Running This Session

Use Web Navigator's continuation protocol from any agent context:

    Continue session 2026-05-27T162706Z-functional-testing-the-internet-login

Or start a fresh session against the same target with this skill:

    Run functional-testing against https://the-internet.herokuapp.com/login

---

_This report was generated deterministically from the session's audit log and finding files. The session folder `exploratory-reports/EXAMPLE-functional-testing-the-internet-login/` contains the full record (`session.md`, `audit.log`, `findings/`, `evidence/`, `snapshots/`)._

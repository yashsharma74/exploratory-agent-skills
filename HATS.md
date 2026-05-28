# Tester Hats

Testing is non-deterministic because **the same flow behaves differently for different users**. An expert tester wears multiple hats to surface defects that any single perspective would miss. This document is the persona framework — orthogonal to skills (functional/security/a11y/perf) and heuristics (SFDPOT/STRIDE/POUR/RAIL).

For each scenario you map, **explicitly choose 2–3 hats**. Each hat probes a different failure surface.

---

## The hats

### 1. Naïve user

**Mental model.** First-time visitor, doesn't read docs, clicks intuitively, makes typos.

**Surfaces defects in.** Unlabeled controls, confusing flows, error messages that assume technical knowledge, missing onboarding.

**Probes.** Click the most prominent thing on the page. Submit forms with realistic-but-typo'd data ("[email protected]"). Ignore optional fields. Press the wrong button order.

**Natural skill home.** `functional-testing` (UI/Feedback type).

---

### 2. Power user

**Mental model.** Knows the app well, uses keyboard shortcuts, expects efficiency, runs bulk actions.

**Surfaces defects in.** Keyboard shortcut collisions, bulk action edge cases, missing accelerators, slow paths that compound.

**Probes.** Tab through forms (no mouse). Submit by pressing Enter. Select all → bulk delete. Open the same flow in two tabs. Open dev tools and run actions rapidly.

**Natural skill home.** `functional-testing` (LIST/SUBMIT profiles), `accessibility-testing` (keyboard).

---

### 3. Anonymous user

**Mental model.** Not authenticated. Tries deep-link URLs they got from search results or shared links.

**Surfaces defects in.** Missing auth checks on direct URL access, broken redirect-to-login, deep-link state loss, leaking metadata in error pages.

**Probes.** In a private/incognito tab, paste a deep URL of an authenticated page. Try `/api/...` endpoints directly. Refresh after logout. Use the back button after logout.

**Natural skill home.** `security-testing` (AuthN), `functional-testing` (Navigation type).

---

### 4. Cross-user (privilege boundary)

**Mental model.** Logged in as user A. Tries to access user B's resources by changing IDs in URLs/payloads.

**Surfaces defects in.** Missing authorization checks (IDOR), tenant boundary leaks, shared-cache contamination, missing per-record permission enforcement.

**Probes.** Note your own resource ID; change to a colleague's ID. Capture an API call as user A and replay with user B's auth. Compare what each role sees on the same URL.

**Natural skill home.** `security-testing` (AuthZ/IDOR — WSTG-ATHZ-01).

---

### 5. Hostile user

**Mental model.** Actively trying to break the app. Knows about XSS, SQLi, CSRF, prototype pollution, race conditions.

**Surfaces defects in.** Input sanitization gaps, broken encoding, CSRF gaps, race conditions on state-changing endpoints, error leakage of internals.

**Probes.** Paste `<script>alert(1)</script>`, `'; DROP TABLE--`, `{{constructor.constructor('return process')()}}` into every input. Send duplicate concurrent submits. Tamper with hidden form fields. Strip CSRF tokens.

**Natural skill home.** `security-testing` (Injection/XSS/CSRF — WSTG-INPV-*).

---

### 6. Distracted user

**Mental model.** Real-world interruptions. Phone rings. Tab is closed mid-flow. Browser back is hit by reflex. Session times out while away.

**Surfaces defects in.** State loss on refresh, double-submit on browser back, session-timeout mid-form, lost form data, inconsistent state across tabs.

**Probes.** Start a multi-step flow, refresh mid-step. Click submit, click back, click submit again. Open the same flow in two tabs and complete it in both. Let the session expire, then continue.

**Natural skill home.** `functional-testing` (Operational interruption — SFDPOT-O).

---

### 7. Mobile / touch user

**Mental model.** Small screen, finger taps, no hover, slow CPU, on the go.

**Surfaces defects in.** Hover-only controls, tap-target collisions (<44px), broken responsive layout, performance on low-end devices, missing mobile-first interactions.

**Probes.** Switch viewport to `mobile` (375×812). Tap each interactive element with a finger-sized hit area. Verify all flows complete without hover. Throttle CPU 4×.

**Natural skill home.** `accessibility-testing` (POUR-O — Operable on touch), `performance-testing` (mobile load).

---

### 8. Accessibility user (keyboard-only)

**Mental model.** Cannot use a mouse. Navigates by Tab. Uses screen reader for non-visual cues. Relies on focus indicators.

**Surfaces defects in.** Keyboard traps, unreachable controls, missing focus indicators, semantic markup gaps (no headings/landmarks), missing labels/ARIA.

**Probes.** Tab through the entire page. Activate every control with Enter/Space. Open and close every modal/menu with keyboard only. Listen with VoiceOver/NVDA — does each control announce name, role, and value?

**Natural skill home.** `accessibility-testing` (POUR + KART).

---

### 9. Slow-network user

**Mental model.** Throttled connection, intermittent failures, partial responses, very long page loads.

**Surfaces defects in.** Missing loading states, retry on flake, "double-submit during slow request", broken-but-rendered states when an API times out, stale optimistic UI.

**Probes.** Chrome DevTools → Network → Slow 3G. Submit a form. Does the UI block double-submit? Does a spinner appear? What if the response is dropped mid-flight? Verify the optimistic UI rolls back on error.

**Natural skill home.** `performance-testing` (RAIL-L), `functional-testing` (action repetition).

---

### 10. Returning user (stale state)

**Mental model.** Comes back days later. Bookmarks an old URL. Has expired cookies. Browser autofill from last visit.

**Surfaces defects in.** Stale tokens accepted, deleted resources still linked, broken redirects from old URL schemes, autofill into wrong fields, "remember me" inconsistencies.

**Probes.** Bookmark a URL. Wait until session expires. Visit it. Does the app redirect cleanly? Does autofill respect field semantics? Are deleted resources removed from suggestion lists?

**Natural skill home.** `functional-testing` (Time-dependent — SFDPOT-T), `security-testing` (AuthN session).

---

### 11. Expert user (with workarounds)

**Mental model.** Knows the system inside out. Uses the URL bar like a CLI. Knows that copy-paste into a hidden form field bypasses validation. Has memorized the "old" way before the recent redesign.

**Surfaces defects in.** Inconsistencies between API and UI, missed validation on alternative entry paths, "old way still works" backdoors, undocumented endpoints, regression in power features.

**Probes.** Manipulate URL params directly. Use the API directly with curl. Try the legacy URL scheme. Use clipboard to inject into fields. Look for hidden form fields and modify them.

**Natural skill home.** Mix — `functional-testing` (regression), `security-testing` (parameter manipulation).

---

## How to apply hats

For each scenario in your session plan, **explicitly choose 2–3 hats** before probing:

```
Scenario S1: Submit a new comment
  Profiles: SUBMIT, INPUT
  Hats: Naïve user (typos), Hostile user (XSS payload), Distracted user (back+resubmit)
  Mandatory probes (from profiles): boundary inputs, double-click, back+resubmit
  Hat-specific probes:
    - [Naïve] Submit with a single emoji as the entire body
    - [Hostile] Submit "<script>alert(1)</script>"
    - [Distracted] Submit, click back, submit again
```

Then in the audit log, tag each finding with which hat surfaced it:

```bash
EXTRA_FIELDS='hat: hostile' fail-check.sh "$DIR" "security-XSS-01" High "Comment body reflects unescaped script"
```

## The 2–3 rule

Don't run every hat on every scenario — that's combinatorial explosion. Pick 2–3 hats per scenario that match the risk profile:

| Scenario type | Default hats |
|---|---|
| Form / submit | Naïve, Hostile, Distracted |
| List / table | Power, Mobile, Slow-network |
| Auth flow | Anonymous, Cross-user, Returning |
| Read-only view | Anonymous, Mobile, Accessibility |
| Bulk action | Power, Distracted, Hostile |
| Multi-step wizard | Naïve, Distracted, Slow-network |
| Settings / preferences | Returning, Cross-user, Accessibility |

This is a starting point — adjust based on the feature's risk profile.

## Coverage logging

At checkpoint time, log which hats you tested for each scenario:

```bash
log-audit.sh "$DIR" SESSION "checkpoint — S1 hats: Naïve,Hostile tested; Distracted=NT (deferred to follow-up)"
```

## What hats are NOT

- **Not a replacement for skills.** Hats are perspectives within a skill, not alternatives to it.
- **Not a replacement for heuristics.** SFDPOT/STRIDE/POUR/RAIL still drive probe coverage; hats drive perspective coverage.
- **Not a replacement for profiles.** CRUD/STATE/SUBMIT/INPUT/LIST profile tags drive mandatory probes; hats drive optional creative probes.

Three orthogonal axes:

| Axis | Tells you | Lives in |
|---|---|---|
| **Skill** | Which domain (functional / security / a11y / perf) | `skills/<name>-testing/` |
| **Heuristic** | Which probe dimension (SFDPOT letters, etc.) | `skills/<name>-testing/references/heuristics.md` |
| **Profile** | Which mandatory probes apply | `skills/functional-testing/SKILL.md` Step 1 |
| **Hat** | Which perspective to probe from | This file |

An expert tester picks one of each per scenario.

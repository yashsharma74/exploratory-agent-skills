# Skill: Performance Testing

Identifies runtime errors, failed/slow network requests, interaction latency, and memory red flags.

---

## Scope

**In scope:**
- Console errors (JavaScript errors, unhandled rejections)
- Failed network requests (4xx, 5xx, CORS errors)
- Slow network requests (> 3 seconds)
- Page load timing (FCP, LCP, TTI approximation)
- Interaction responsiveness (click → visual feedback latency)
- Memory red flags (visible leaks, frozen UI after prolonged use)
- Resource sizing (obviously oversized images, JS bundles)

**Out of scope:**
- Server-side profiling
- Database query optimization
- Infrastructure capacity testing
- Load testing at scale (this framework is single-user browser testing)
- Functional correctness (use functional-testing)

---

## Pre-session checklist

- [ ] `TARGET_URL` confirmed and feature area identified
- [ ] Auth performed (see auth-detection.md)
- [ ] Browser DevTools / network panel available
- [ ] Report directory created: `exploratory-reports/[timestamp]-performance-[feature-slug]/`
- [ ] Primary heuristic: **RAIL** (default) or **HICCUPPS** (regression/comparison focus)
- [ ] Oracles defined (see below)

---

## Execution: Three-phase approach

### Phase 1 — Baseline capture (3 minutes)

1. **Clear cache and cookies** (or use incognito/private window) for a cold-load test.
2. Navigate to `TARGET_URL`.
3. Open network panel and console before navigating.
4. Record:
   - **Time to first meaningful content** (when does the page look usable? estimate in seconds)
   - **Console errors on load** (any JavaScript errors, CSP violations, 404s for resources)
   - **Failed requests** (any 4xx/5xx in network tab)
   - **Slow requests** (any requests taking > 3 seconds)
5. Take a screenshot of the network panel if there are notable findings.
6. Capture baseline snapshot.

### Phase 2 — Filtered diagnostics (7 minutes)

Navigate through the target feature area. For each key page/action:

#### Network monitoring (apply filter: errors + slow)

For each page load and user action, note:
- **Failed requests** (status ≥ 400): URL, status code, impact
- **Slow requests** (> 3s): URL, duration, resource type (image, API, script)
- **Duplicate requests**: same endpoint called multiple times unnecessarily
- **Large resources**: images > 500KB, JS bundles > 1MB

Discard: all successful requests under 3s (not relevant for this analysis).

#### Console monitoring (filter: errors only)

Note all `console.error` and uncaught exceptions:
- Error message text
- Source file and line number
- Frequency (once vs. every page load vs. every action)

Discard: `console.log`, `console.warn`, `console.info`.

#### Interaction responsiveness spot-check

For 3–5 key interactions (click, submit, search, toggle):
1. Perform the action.
2. Estimate time until visual feedback (< 100ms = good, 100–1000ms = acceptable, > 1000ms = slow).
3. Note if UI shows a loading indicator during wait (good) or appears frozen (bad).

### Phase 3 — RAIL assessment (5 minutes)

Apply RAIL to summarize observed performance:

| Dimension | What you measured | Pass / Fail |
|-----------|-----------------|-------------|
| **R** Response | Key actions < 100ms feedback? | |
| **A** Animation | Scroll/transitions smooth? Any jank? | |
| **I** Idle | UI responsive between actions? | |
| **L** Load | First meaningful content < 3s (desktop)? < 5s (mobile)? | |

For each Fail, create a finding.

---

## Starvation testing (optional, if time allows)

Pick one interactive element and stress-test it:
- Rapid clicks: click the same button 10 times quickly
- Type burst: type 200 characters fast in a search/input field
- Rapid navigation: navigate between 5 pages as fast as possible

Observe:
- UI freezes or becomes unresponsive?
- Console errors triggered?
- Duplicate API calls sent?
- Results or state become inconsistent?

---

## Oracles

- No JavaScript errors on page load under normal conditions
- No failed requests (4xx/5xx) for primary feature paths
- No requests slower than 3s for user-initiated actions
- Primary actions show visual feedback within 1 second
- UI remains responsive during and after user actions
- Performance is consistent across repeated runs (no degradation)
- Console is clean after normal user flows

---

## Finding IDs

Use prefix `P-` (e.g., P-001). Include:
- **RAIL dimension** affected
- **Measurement**: actual timing, error message, or request URL
- **Frequency**: once / every page load / every action
- **User impact**: what does the user experience?

---

## Severity guide

| Severity | Examples |
|----------|---------|
| **Critical** | Page doesn't load, critical feature request fails with 500, UI permanently frozen |
| **High** | Primary action > 5s, console error on every page load, critical resource 404 |
| **Medium** | Non-critical request > 3s, occasional console error, duplicate API calls |
| **Low** | Warning in console, large resource with no user impact, minor jank |
| **Info** | Optimization suggestion, caching recommendation |

---

## Reporting notes

- Include request/response timing data in finding description (not screenshots).
- For console errors, include exact error message text and source location.
- Distinguish between: cold load (empty cache) vs. warm load (cached resources).
- Note browser and viewport used (different from testing accessibility/functional).

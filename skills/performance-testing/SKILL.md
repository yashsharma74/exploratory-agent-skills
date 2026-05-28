---
name: performance-testing
version: "1.0.0"
description: Performance and reliability testing focused on console errors, failed/slow requests, load timing, and runtime stability. Use when the user reports page slowness, wants to check network errors, debug console issues, or investigate load timing and runtime stability.
---

# Performance & Reliability Testing

Use this skill when:
- Diagnosing page slowness, console errors, or failed network requests
- Investigating interaction responsiveness or load timing on staging or dev
- Identifying memory or resource red flags under normal usage conditions

Do NOT use this skill for:
- Functional correctness checks (use `functional-testing`)
- Security validation or accessibility compliance

---

## Workflow

### Step 1: Select Page and Capture Baseline

Select one page or flow for this session. Do not switch targets mid-session.

Capture a baseline summary before any targeted probes:

- Page load timing
- Key interaction timing (first meaningful user action)

Persist the baseline immediately — it is the reference point for all findings in the session.

### Step 2: Collect Filtered Diagnostics

Collect only the following — never raw dumps:

- Console errors (JS exceptions and unhandled rejections)
- Failed network requests (4xx, 5xx, or no response)
- Slow requests (>3s) — request URL and observed timing
- Top heavy resources (small sample only)

### Step 3: Test Per Interaction

For each key interaction:

1. Trigger the interaction and observe feedback timing against RAIL thresholds (see `references/heuristics.md`).
2. Note any blocking or delay beyond perceptible thresholds.
3. Persist each result to disk before the next interaction.

### Step 4: Write Findings

Each failed check produces a finding file. Use the universal ID format (sequential `NNN`) and severity scale from the conventions layer.

**Required additional fields:**

- **Component / Endpoint / URL** — every performance finding must attribute the issue to a specific component, endpoint, request, or UI element. Name the failing request URL, script, or UI component causing the issue.
- **Observed timing vs threshold** — include the measured value and the threshold being violated (or compared against).
- **User Impact statement** — which user action is degraded and by how much.

Example:

```
Component: GET /api/records (4.2s observed, 3s threshold)
Observed Timing: 4.2s (P95), 3.8s (median)
User Impact: Record list takes 4.2s to load on throttled connection; users on slow networks see blank screen for 4+ seconds.
```

**Finding types:** `ConsoleError` | `FailedRequest` | `SlowRequest` | `LoadTiming` | `InteractionLag` | `MemoryRisk`.

**Evidence rule:** Critical/High findings require a screenshot of the browser performance panel. Never paste raw HAR or full network waterfall content into findings — capture compact summaries only.

### Step 5: Checkpoint and Summary

At every 5-minute checkpoint, log RAIL coverage (see `references/heuristics.md`):

```
RAIL: R,L tested; A,I=NT
```

Complete the session summary with findings, a timing table, missed coverage, and continuation prompt.

---

## Time Budget Scaling — Interactions

| Time limit | Interactions | Diagnostic depth | Coverage expectation |
|---|---|---|---|
| **5 min** | Baseline + 1 key interaction | Console errors + failed requests only | RAIL: R only |
| **10 min** | Baseline + 2–3 interactions | Console errors + failed/slow requests + load timing | RAIL: R, A, L |
| **15 min** (default) | Baseline + 3–5 interactions | Full diagnostic collection per interaction | All RAIL dimensions attempted |
| **20 min** | Baseline + 3–5 interactions | Full diagnostics + repeat measurements for variance | RAIL + stability/variance analysis |
| **25–30 min** | Baseline + 5–7 interactions | Full diagnostics + heavy resource analysis + memory sampling | Maximize RAIL + Starvation coverage |

Prioritize interactions by user impact (primary CTAs, data-heavy views). One page or flow per session — do not switch targets mid-session.

---

## Oracles

- Critical user actions stay responsive under realistic load and latency.
- Failures are visible, bounded, and recoverable by the user.
- Slow paths are attributable to a specific component or request with clear user impact.
- Repeated runs show stable behavior without severe variance or degradation.

---

## Strictness Principles

- Capture the baseline before any probes — probing without a baseline is not acceptable.
- Persist after every interaction — write each result before the next one begins. Buffering across interactions is not acceptable.
- One page or flow per session — switching targets mid-session is not acceptable.
- Every finding must name the specific component, endpoint, or URL causing the issue — "the page is slow" is not acceptable.
- Every finding must include observed timing vs threshold and state user impact.
- Evidence must be compact summaries — raw HAR dumps or full network waterfalls are not acceptable.

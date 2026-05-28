---
name: functional-testing
version: "1.0.0"
description: Exploratory functional testing of web applications. Focus on user flows, validation, navigation, state, and business logic. Use when the user asks to test a feature, form, or flow, investigates a reported functional bug, or wants to verify behavior against acceptance criteria.
---

# Functional Exploratory Testing

Use this skill when:
- Testing user flows, form validation, navigation, or business logic
- Investigating a reported functional defect on staging or dev
- Verifying feature behavior against acceptance criteria

Do NOT use this skill for:
- Security testing (use `security-testing`)
- Accessibility testing (use `accessibility-testing`)
- Performance testing (use `performance-testing`)

---

## Workflow

### Step 1: Map Scenarios, Classify, and Write Mission

Before any browser action, map scenarios ordered by `impact × likelihood` as a working hypothesis. Use the Time Budget Scaling table below to determine how many scenarios fit the chosen time limit.

**Session mission (required before any browser action):** Write one mission statement per session:

```
Test [AREA or FEATURE] using [PROBE APPROACH] to find [SPECIFIC RISK]
```

Minimum acceptable: Area + Risk. Specific enough to know where to start, open enough to not prescribe exact steps, names a risk.

| Anti-pattern | Problem | Fix |
|---|---|---|
| "Test the login page" | No risk named | "Test login to find auth bypass via empty credentials and session handling failures" |
| "Verify that the form submits" | Scripted test, not exploration | "Test form submission to find validation gaps and server-side enforcement failures" |
| "Test everything on dashboard" | Unbounded scope | "Test data export on dashboard to find data integrity and permission enforcement gaps" |

Record the mission at the top of the audit log:
```
[HH:MM:SS] [info] SESSION: mission — Test [area] using [approach] to find [risk]
[HH:MM:SS] [info] SESSION: type — New feature / Defect investigation / Regression check / Integration failure
[HH:MM:SS] [info] SESSION: highest-risk hypothesis — [one sentence]
```

#### Scenario Classification (required per scenario)

For each scenario, identify:
- Target flow, screen, and entry point
- **Exploration strategy** — one or two strategies from the Strategy Selection table in `references/heuristics.md`
- **Primary correctness source** — which source of truth from `references/oracles.md` will be used to judge results — state this before running any probe
- **Scenario profile** — tag each scenario with every applicable profile from the table below. These profiles determine which probes are mandatory (not optional) during execution:

| Profile tag | Applies when... | Mandatory probes (cannot skip, even under time pressure) |
|---|---|---|
| `CRUD` | Scenario creates, updates, or deletes a record | Full lifecycle: Create → Read → Update → Read → Delete/Archive → Read. Verify field values at each step. |
| `STATE` | Feature has multiple states or statuses | Map all states and transitions before probing. Test every reachable transition. Attempt at least 2 invalid transitions. Test what happens when the same transition is triggered twice. |
| `SUBMIT` | Flow has a Submit, Create, Pay, Send, Publish, or Delete action | Double-click the action trigger. Browser Back + resubmit. Two-tab simultaneous submit. |
| `INPUT` | Scenario has user input fields or API parameters | Boundary values (min, min-1, max, max+1). Empty and whitespace-only. Wrong format. |
| `LIST` | Feature displays a list, table, count, or collection | Cardinality: test with 0, 1, and many items. Verify empty state, singular/plural labels, pagination threshold, bulk actions. |

A scenario can have multiple profiles. For example, "test record creation" is `CRUD` + `SUBMIT` + `INPUT` — all three sets of mandatory probes apply.

**Scenario refinement (live):** While exploring, update the scenario list when browser interaction reveals new flows, UI patterns that change the approach, or context that makes a scenario irrelevant. Log every change in the audit trail with a reason. Do not silently abandon the original mission.

### Step 2: Execute Per Scenario

For each scenario — execute its mandatory probes based on profile tags, then persist.

Execution order within a scenario:
1. **Happy path** — confirm the flow reaches its expected end state.
2. **Mandatory profile probes** — execute every probe required by the scenario's profile tags. Non-negotiable.
3. **Exploration probes** — follow instincts. Spend at least 30% of scenario time on freeform exploration beyond the mandatory probes.
4. **Validate** each probe result against the correctness source from Step 1. State the source in the audit log before recording pass or fail.
5. **Persist immediately** — write each rule result and finding to disk before the next probe starts.

For the complete probe list per profile tag, see `references/heuristics.md` Section 3 "Quick-Reference: Mandatory Minimums Per Profile".

### Step 3: Write Findings

Each failed check produces a finding file. Use the universal ID format (sequential `NNN`) and the universal severity scale from the conventions layer.

**Functional-specific required field:** Every functional finding must include a `Type` field, one of:

- `Validation` — input validation gaps
- `Navigation` — navigation, deep-link, redirect bugs
- `State` — state transition or lifecycle bugs
- `Logic` — business logic errors
- `UI/Feedback` — error messages, loading indicators, confirmation gaps

### Step 4: Checkpoint and Summary

At every 5-minute checkpoint, log SFDPOT coverage (see `references/heuristics.md` Section 1 for the letter-to-dimension mapping):

```
SFDPOT: S,F,D,O tested; P=NT (single browser only); T=NT (no time-dependent features in scope)
```

External Integration is logged separately as `E` when applicable.

Also log mandatory profile probe completion per scenario:

```
Profile gates: CRUD=done, SUBMIT=done, STATE=partial (2/3 valid transitions tested, need 1 more)
```

Complete the session summary with top findings, risk rating, missed coverage, and continuation prompt.

---

## Time Budget Scaling — Scenarios

| Time limit | Scenarios | Probe depth | Coverage expectation |
|---|---|---|---|
| **5 min** | 1 | Happy path + all mandatory profile probes for that scenario + one additional failure probe | Primary function + mandatory profile gates for the single scenario |
| **10 min** | 1–2 | Happy path + all mandatory profile probes + boundary inputs + one operational interruption | At least S, F, D dimensions + all profile gates per scenario |
| **15 min** (default) | 2–3 | Full probe bundle per scenario + freeform exploration | All applicable SFDPOT dimensions + all profile gates + exploration time |
| **20 min** | 2–4 | Full probe bundle + additional edge cases + extended exploration | All SFDPOT dimensions + all profile gates + integration/time probes |
| **25–30 min** | 3–5 | Full probe bundle + extended data lifecycle, cardinality, idempotency + deep exploration | Maximize SFDPOT coverage; explicitly test dimensions marked NT in shorter sessions |

**Critical rule for short sessions (5–10 min):** Fewer scenarios with full mandatory profile coverage is always better than more scenarios with shallow coverage. If a scenario is tagged `STATE` or `CRUD`, those probes take priority over adding a second scenario.

Map scenarios before testing; do not discover scope during execution. Order by `impact × likelihood` (highest risk first). Execute one scenario's full probe bundle before moving to the next.

---

## Judging Results

Before deciding whether any probe result is a pass or fail, consult `references/oracles.md`, identify the applicable source of truth, and state it in the audit log before recording the result. Do not record a pass or fail without naming the source.

---

## Strictness Principles

- **Mandatory profile probes are not optional** — if a scenario is tagged `STATE`, you must map states, test valid transitions, and attempt invalid transitions. If tagged `CRUD`, you must test the full lifecycle. If tagged `SUBMIT`, you must test double-submission. Skipping these under time pressure is not acceptable; reduce the number of scenarios instead.
- **No browser action without a written mission and named strategy per scenario** — implicit or ad-hoc exploration is not acceptable.
- **State the correctness source before recording any pass or fail** — findings without a stated basis cannot be triaged.
- **Explore beyond the checklist** — the mandatory probes are the floor, not the ceiling. Follow hunches, test edge cases, try unexpected inputs.
- **Scenario refinements must be logged immediately** in the audit trail with a reason — silent scope changes are not acceptable.
- **Coverage must log SFDPOT letters and profile gate completion at every checkpoint** — claiming full coverage without listing what was and was not tested is not acceptable.

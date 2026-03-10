# Skill: Functional Testing

Deep, structured testing of user flows, validation, state management, and business logic.

---

## Scope

**In scope:**
- User flows (happy path + alternatives)
- Form validation and error handling
- Navigation and routing
- State persistence (refresh, back/forward, session restore)
- Business logic verification
- Recovery from errors

**Out of scope:**
- Security vulnerabilities (use security-testing)
- WCAG compliance audit (use accessibility-testing)
- Load/performance profiling (use performance-testing)

---

## Pre-session checklist

- [ ] `TARGET_URL` confirmed and feature area identified from user's prompt
- [ ] Auth performed (see auth-detection.md)
- [ ] Baseline screenshot captured
- [ ] Report directory created: `exploratory-reports/[timestamp]-functional-[feature-slug]/`
- [ ] Primary heuristic selected (see below)
- [ ] 3–5 test scenarios defined (see scenario selection)
- [ ] Oracles defined for each scenario

---

## Heuristic selection

Choose based on the feature type:

| Feature type | Primary heuristic |
|-------------|-----------------|
| Feature with broad scope | **SFDPOT** |
| Input-heavy form | **BINMEN** |
| List/collection feature | **Count (0/1/many)** |
| Unknown/general | **SFDPOT** (default) |

---

## Scenario selection (highest-risk first)

Prioritize test scenarios in this order:

1. **Auth/access control** — can the right users do the right things?
2. **Core value action** — the most important thing users do in this feature
3. **Data creation/edit** — create, modify, and verify data integrity
4. **Error and recovery** — what happens when things go wrong?
5. **Edge cases** — boundary inputs, empty states, concurrent actions

Select 3–5 scenarios. More is better only if time allows. Always complete one scenario fully before starting the next.

---

## Execution: Probe bundle per scenario

For each selected scenario, execute this probe bundle:

### 1. Happy path
- Execute the scenario with valid, expected inputs.
- Verify: correct outcome, correct UI feedback, correct data state.

### 2. Boundary input
- Apply BINMEN: test at and just beyond input limits.
- Verify: appropriate validation messages, no crash, no data corruption.

### 3. Invalid input
- Enter wrong types, formats, or values.
- Verify: clear error message, field identified, user can correct and resubmit.

### 4. Navigation interruption
- Start the action, then: navigate away (back button), refresh, or close/reopen tab.
- Verify: data not partially saved in corrupt state, form state handled gracefully (restored or cleared).

### 5. State verification
- After completing the action, verify the result persists.
- Refresh the page. Is the state still correct?
- Log out and log in. Is the state still correct?

---

## Oracles

Before testing each scenario, define:
- **Expected result**: what the UI should show after a successful action
- **Business rule**: what the system must enforce (e.g., "only admins can delete")
- **Error expectation**: what error message should appear for invalid input
- **State contract**: what data should persist and what should not

---

## Applying SFDPOT

For each scenario, map observations to SFDPOT letters:

| Letter | Question |
|--------|---------|
| **S** | Is the structure (UI layout, navigation) correct for this state? |
| **F** | Does the function perform its advertised purpose? |
| **D** | Is data handled correctly (saved, validated, displayed accurately)? |
| **P** | Does it work on different browsers/viewports? (spot-check one alternative) |
| **O** | What happens under concurrent or repeated operations? |
| **T** | Does time affect this feature? (expiry, scheduling, date handling) |

---

## Applying BINMEN (for input-heavy forms)

| Letter | Probe |
|--------|-------|
| **B** | Enter value exactly at max length; one character over max length |
| **I** | Enter wrong type (letters in number field, emoji in name field) |
| **N** | Leave required fields blank; submit empty form |
| **M** | Submit via keyboard (Enter); submit via button click; submit via mobile tap |
| **E** | Submit form with all optional fields empty |
| **N** | Try actions that should be blocked (submit twice, submit stale form) |

---

## Findings

Use prefix `F-` (e.g., F-001). Capture a screenshot immediately for each finding.

Severity guide:
- **Critical**: data loss, complete feature failure, auth bypass
- **High**: major flow broken, incorrect data saved, missing required validation
- **Medium**: incorrect error message, validation gap, UX confusion
- **Low**: minor wording issue, cosmetic defect, non-blocking inconsistency

---

## Session summary requirements

At the end of the session, list:
- Scenarios completed (full probe bundle) vs. partially tested
- Heuristic letter coverage (tested vs. NT per scenario)
- Business logic gaps found
- Recommended follow-up: areas needing deeper investigation

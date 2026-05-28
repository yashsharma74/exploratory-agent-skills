---
name: accessibility-testing
version: "1.0.0"
description: Accessibility testing for WCAG 2.1 AA focused on keyboard use, focus, labeling, structure, and assistive tech compatibility. Use when the user asks about a11y, keyboard navigation, screen reader support, ARIA roles, WCAG compliance, or color contrast issues.
---

# Accessibility Testing

Use this skill when:
- Testing keyboard navigation, focus behavior, or screen reader compatibility
- Validating form labels, error associations, or semantic structure
- Checking WCAG 2.1 / 2.2 AA compliance for a specific page or component

Do NOT use this skill for:
- Functional defect testing (use `functional-testing`)
- Security or performance analysis

---

## Workflow

### Step 1: Select Page and Prepare

Select one page or component for this session. Prioritize high-traffic, high-risk flows (login, forms, primary CTAs, dialogs).

### Step 2: Run Automated Sweep

Run one automated accessibility sweep (e.g., axe-core or equivalent) and summarize the results. Do not skip — it surfaces contrast and missing-label issues quickly.

### Step 3: Execute Manual Checks in Order

Manual accessibility checks must follow this order after the automated sweep. Persist each result to disk before the next check:

1. **Keyboard traversal and activation** — reach and operate all interactive controls without a mouse.
2. **Focus visibility, order, and return behavior** — indicator visible, logical order, no traps.
3. **Form labels, instructions, and error associations** — all inputs have linked labels and error messages.
4. **Landmark, heading, and role structure** — correct semantic structure for screen reader navigation.

### Step 4: Write Findings

Each failed check produces a finding file. Use the universal ID format (sequential `NNN`) and severity scale from the conventions layer.

**Required additional fields:**

- **WCAG Criterion** — every finding maps to a WCAG success criterion: include the criterion number and short name (e.g., `WCAG 2.1.1 Keyboard`, `WCAG 1.4.3 Contrast Minimum`, `WCAG 4.1.2 Name, Role, Value`). Use WCAG 2.2 AA as the baseline unless the user specifies otherwise. If no direct criterion applies, note the closest POUR principle.
- **User Impact** (additional to severity) — classify the practical effect on assistive-tech users:
  - `Blocked task` — the user cannot complete the task at all without a workaround
  - `Severe friction` — the user can complete the task but with significant difficulty
  - `Minor friction` — the user experiences inconvenience but the flow is largely intact

  Both `Severity` (universal scale) and `User Impact` (accessibility-specific) appear on every accessibility finding. They are complementary: severity captures the broader business/product impact; User Impact captures the assistive-tech-specific consequence.

**Finding types:** `Keyboard` | `Focus` | `FormA11y` | `Semantics` | `ScreenReaderSupport` | `Contrast/Visual`.

### Step 5: Checkpoint and Summary

At every 5-minute checkpoint, log POUR coverage (see `references/heuristics.md`):

```
POUR: P,O tested; U,R=NT
```

Complete the session summary with WCAG mapping per finding, missed coverage, and continuation prompt.

---

## Time Budget Scaling — Checks

| Time limit | Checks | Check depth | Coverage expectation |
|---|---|---|---|
| **5 min** | Automated sweep + 1 manual check | Happy path only per check | P, O from POUR |
| **10 min** | Automated sweep + 2 manual checks | Happy path + one edge case per check | P, O, U from POUR |
| **15 min** (default) | Automated sweep + all 4 manual checks | Full check per area | All POUR dimensions attempted |
| **20 min** | Automated sweep + all 4 manual checks | Full check + KART supplementary probes | POUR + KART overlay |
| **25–30 min** | Automated sweep + all 4 manual checks + cross-flow traversal | Full + multi-page keyboard flow continuity | Maximize POUR + KART; explicitly test dimensions marked NT in shorter sessions |

Prioritize checks by risk: keyboard access and focus traps before semantic structure.

---

## Oracles

- Task is completable without mouse-only or vision-only assumptions.
- Focus order and focus visibility are predictable and non-trapping.
- Controls and errors expose understandable name, role, and value semantics.
- Guidance and error recovery are clear for assistive-tech users.

---

## Strictness Principles

- Automated sweep must run before any manual checks — jumping straight to manual is not acceptable.
- Manual checks must follow the defined order (automated → keyboard → focus → forms → landmarks).
- Persist after every check — write each result before the next check begins. Buffering across checks is not acceptable.
- Every finding must map to a WCAG success criterion (e.g., `WCAG 2.1.1 Keyboard`) — type-only labels are not acceptable.
- Every finding must classify `User Impact` as `Blocked task`, `Severe friction`, or `Minor friction` in addition to severity.
- Write findings immediately — batching at the end of the session is not acceptable.

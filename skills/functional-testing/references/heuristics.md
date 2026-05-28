# Heuristics — Functional Testing Probe Catalogue

---

## How to Use This File

1. Select a strategy from the Strategy Selection table based on scenario risk profile.
2. Use the Probe Selection Guide to determine which testing dimensions apply.
3. For each applicable dimension, run at least one concrete probe before moving to the next.
4. Record every probe: what was tested, what was expected, what was observed.
5. Before deciding pass or fail, consult `./oracles.md` and state which consistency source applies.

---

## Strategy Selection

Select one or two strategies per scenario before execution. Strategies vary the type of exploration, preventing repetition of the same probe types and ensuring different defect classes are covered.

| Select this strategy when... | Strategy | Probe sections to apply | Common defects found |
|---|---|---|---|
| Testing a new feature or one with written acceptance criteria | Documented behavior verification | Section 1: Primary Feature Function | Features behaving differently from spec; error messages not matching docs; labels updated in code but not documentation |
| Feature involves billing, revenue, conversion, or plan limits | Business-critical path testing | Section 1: Primary Feature Function + Section 2: Boundary Value Testing + Section 3: Action Repetition | Plan limits enforced in UI but not server; double-charge on payment; confirmation emails not sent; incorrect plan after upgrade |
| Testing after a bug fix or in an area with multiple past defects | Prior defect area regression | Section 1: Primary Feature Function + Section 2 (same input classes as prior bugs) | Original defect returned in different form; fix works for exact case but not the general class; fix breaks a related flow |
| Testing after a refactor, dependency upgrade, or shared component change | Unchanged feature regression | Section 1: Primary Feature Function (happy path on unchanged features) | Auth middleware change breaks unrelated flow; CSS upgrade breaks unchanged page layout; API client upgrade changes error surfacing |
| Any flow with a Submit, Create, Pay, Send, Publish, or Delete action | Repeated action and idempotency | Section 3: Action Repetition and Idempotency Testing | Duplicate records from double-click; duplicate charges from back+resubmit; two-tab race condition; retry after interruption creates second record |
| Feature depends on an external service, API, or browser permission | Dependency failure | Section 1: External Integration Behavior + Section 3: Dependency Failure Testing | Unhandled API error crashes page; app blank when third-party script fails; expired token not detected; missing error messages on service failure |

**Pairing rule:** Always combine "Repeated action and idempotency" with whichever other strategy is selected when the flow includes an action that modifies server state. Double-submit and back+resubmit are the most commonly missed defect class.

**Execution:** For each selected strategy, apply the probes from the referenced sections. The strategy tells you *when and why* to test; the sections below tell you *what probes to run*.

---

## Probe Selection Guide

Select applicable testing dimensions based on what is true about the scenario.

| If the scenario involves... | Apply these testing dimensions |
|---|---|
| A new or changed feature being tested for the first time | All seven functional dimensions (Section 1) |
| User input fields, API parameters, or form submissions | Input boundary and negative testing (Section 2) |
| Creating, reading, updating, or deleting records | Data lifecycle testing (Section 3) |
| An external API, OAuth, webhook, or third-party service | External integration behavior dimension (Section 1) |
| A multi-step flow with prerequisites between steps | Sequence integrity dimension (Section 1) + action repetition testing (Section 3) |
| A Submit, Create, Pay, Send, or Publish action | Action repetition and idempotency testing (Section 3) — always apply this |
| Billing, quota enforcement, or plan limits | Primary function dimension + boundary value testing on the specific limits |
| Session state, authentication tokens, or invite links | Time-dependent behavior dimension (Section 1) |
| Testing after a bug fix or code change in a fragile area | Primary function dimension + prior defect class reproduction |
| Testing after a refactor or dependency upgrade | Primary function dimension on unchanged features that share infrastructure |

**When time is constrained:** test primary function and data inputs before platform compatibility and time-dependent behavior.

---

## Section 1: Functional Coverage Dimensions

These dimensions map to the **SFDPOT** heuristic used in coverage logging:

| SFDPOT letter | Dimension |
|---|---|
| **S** | Sequence Integrity |
| **F** | Primary Feature Function |
| **D** | Data Input Handling |
| **P** | Platform Compatibility |
| **O** | Operational Interruption Handling |
| **T** | Time-Dependent Behavior |
| *(+E)* | External Integration Behavior — not in SFDPOT; log separately when applicable |

Test every applicable dimension for each scenario. Record each tested dimension and each skipped dimension with the reason.

### Sequence Integrity

What this tests: whether the application enforces the required order of steps, prevents illegal access to later steps, and handles out-of-order or repeated steps correctly.

Probes to run:
- Navigate directly to a later-step URL without completing earlier steps. Verify the app blocks or redirects.
- Skip an intermediate required step. Verify the app detects the missing prerequisite.
- Repeat a step that should only occur once. Verify the app prevents or handles this correctly.
- Open the same multi-step flow in two tabs simultaneously. Complete it in one tab; then attempt to continue in the other. Verify the app detects the stale state.

Common defects: bypassed prerequisites, orphaned records, repeated one-time steps creating duplicates.

---

### Primary Feature Function

What this tests: whether the primary action produces the correct outcome, triggers all expected side effects, and fails correctly when it should.

Probes to run:
- Execute the primary action on a valid, complete input. Verify the stated outcome occurs.
- Verify every expected side effect: downstream records created, emails sent, counters updated, state changed.
- Test each expected failure case: submitting when a prerequisite is missing must produce an error, not silent success.
- If the action can be undone or cancelled: verify that undoing it reverses all side effects completely.

Common defects: action appears to succeed but outcome doesn't occur; side effects fire or don't fire incorrectly; invalid state accepted silently.

---

### Data Input Handling

What this tests: how the application handles the full range of data inputs — valid, boundary, malformed, empty, and unexpected values.

Apply the complete procedure in Section 2 for every input field or API parameter in scope.

---

### External Integration Behavior

What this tests: how the application behaves when an external dependency is unavailable, returns an error, or returns an unexpected response.

Only apply when: the scenario involves an API call, SSO login, file upload to external storage, webhook processing, or a browser permission request (clipboard, geolocation, notifications).

Probes to run:
- Simulate the external service returning a 500 or 503 response. Verify the user sees an actionable error message, not a blank screen or application crash.
- Expire or invalidate the auth token mid-session. Verify the app detects the expired credential and prompts for re-authentication rather than proceeding with a stale token.
- Deny a browser permission request. Verify the app explains why the permission is needed and offers a fallback or guidance.
- If a webhook is involved: send a payload with a missing required field. Verify the app rejects it safely without creating a corrupt or partial record.
- Simulate the external service returning a response 10–30 seconds late. Verify the app does not timeout silently or show a broken state.

Common defects: unhandled API errors crash the page; operations proceed with expired credentials; app unusable when non-critical third-party script fails.

---

### Platform Compatibility

What this tests: whether the feature behaves equivalently across supported browsers, viewport sizes, and input methods.

Only apply when: the feature uses browser-specific APIs, has responsive layout requirements, or is known to have cross-browser differences.

Probes to run:
- Execute the primary action in each supported browser (minimum: Chrome, Firefox, Safari).
- Execute the primary action at the narrowest supported viewport width.
- Complete the flow using keyboard-only navigation (Tab, Enter, Escape, arrow keys).

Common defects: JS APIs unavailable in some browsers; layout breaks at specific viewports; elements unreachable by keyboard.

---

### Operational Interruption Handling

What this tests: whether the app handles real-world usage interruptions correctly — browser navigation, page reload, deep-links, and duplicate sessions.

Probes to run:
- Click browser Back on a confirmation or success page. Verify the app does not resubmit the previous action or display stale state.
- Refresh the page at a mid-flow step. Verify the app either restores state or explains that the user must restart from the beginning.
- Deep-link directly to an authenticated page while logged out. Verify the app redirects to login then returns to the intended destination after authentication.
- Open the same flow in two browser tabs. Complete it in one tab; then attempt to continue in the other. Verify the app detects or prevents the conflict.
- For any action with a loading indicator: use network throttling to keep the loading state visible, then verify a second click or submission is blocked while the first is in progress.

Common defects: duplicate submissions via back+resubmit; progress lost on refresh; redirect loops on deep-link; parallel session conflicts undetected.

---

### Time-Dependent Behavior

What this tests: how the application handles session expiry, token invalidation, time-limited actions, and timezone-sensitive data.

Only apply when: the scenario involves session management, invite or activation tokens, time-limited actions, or date and time display.

Probes to run:
- Allow the session to expire (or force-expire it via DevTools storage), then attempt to continue the flow. Verify the app detects expiry and prompts appropriately rather than letting the action proceed.
- Use a time-limited invite or activation link after it has expired. Verify the app rejects it with a specific explanation.
- If the feature displays dates or times: verify the displayed value matches the expected local timezone, not the server timezone.

Common defects: expired sessions undetected allowing stale auth; expired tokens still accepted server-side; dates in wrong timezone.

---

### Coverage Recording

After completing probes for a scenario, record both lists:
- **Tested:** [name each dimension that had at least one probe executed and logged]
- **Not tested:** [name each skipped dimension and give the reason — e.g., "External integration: not applicable, this flow has no external dependencies"]

Do not claim a dimension as tested unless a specific probe was executed and its result was logged in the audit trail.

---

## Section 2: Input Boundary and Negative Testing

Apply this to every input field, API parameter, and form submission in scope.

### Boundary Value Testing

For any input with a stated or implied minimum or maximum:
- Test the value exactly at the stated minimum
- Test the value one unit below the stated minimum
- Test the value exactly at the stated maximum
- Test the value one unit above the stated maximum

"One unit" means: one character for text length, one for integers, one day for date ranges, one byte for file sizes.

Example — text field with a maximum of 100 characters:
- 99 characters → must be accepted
- 100 characters → must be accepted
- 101 characters → must be rejected with a specific error message

### Required Field Testing

For every required field:
- Submit with the field completely empty
- Submit with the field containing only whitespace (spaces, tabs, newlines)
- If the form is accessible via API: submit a request without the field in the payload entirely

Expected result: the submission is rejected with a specific error that identifies the field. Submission must never succeed silently when a required field is missing.

For optional fields: submit with the field empty and verify the record is created with a null or default value, not an error.

### Invalid Format Testing

For every field with a defined format (email address, phone number, URL, date, numeric value):
- Submit a value of the correct length but the wrong format (e.g., letters in a numeric-only field)
- Submit a value that is almost valid but malformed (e.g., an email address missing the domain: `user@`)
- Submit a value containing characters the format does not allow (e.g., spaces in a username field)

Expected result: the application rejects invalid formats with an error that names the field and describes the expected format.

### Out-of-Domain Value Testing

For numeric fields where the valid range is restricted:
- Submit a value below the minimum valid value (e.g., a negative quantity where only positive values are valid)
- Submit zero when zero is not a valid value
- Submit an extreme upper value (e.g., 9999999) when no explicit maximum is stated

### Type Mismatch Testing

For any field expecting a specific data type:
- Submit a string where a number is expected
- Submit a number where a date is expected
- Submit a boolean string (`"true"`, `"false"`) where the API expects a boolean value

Expected result: the application rejects or safely sanitizes the mismatched input; it does not store or process an incorrectly typed value.

### Input Planning Table

Before testing a form or API endpoint, create this table for each field to ensure full coverage:

| Field name | Valid range or format | Too small or below minimum | Too large or above maximum | Wrong format | Empty or missing |
|---|---|---|---|---|---|
| Example: Name | 1–100 characters | n/a (minimum is 1) | 101+ characters | n/a (any text) | empty string, whitespace |
| Example: Age | Integer 1–120 | 0 or negative | 121+ | decimal number, text string | empty |

---

## Section 3: Data Lifecycle and State Testing

**This section contains mandatory probes.** When a scenario is tagged with `CRUD`, `STATE`, `SUBMIT`, or `LIST` profiles (see SKILL.md Step 2), the corresponding probes below are required — not suggested. Skipping them is a coverage gap that must be logged and justified.

### Quick-Reference: Mandatory Minimums Per Profile

| Profile | You must at minimum... |
|---|---|
| `CRUD` | Create → Read → Update → Read → Delete/Archive → Read. Verify field values after each mutation. |
| `STATE` | Map all states. Walk each valid transition. Attempt 2 invalid transitions. Attempt 1 duplicate transition. |
| `SUBMIT` | Double-click. Back + resubmit. Two-tab submit. |
| `LIST` | Test with 0 items (empty state). Test with 1 item (labels, selection). Test with many (pagination, bulk). |

If time runs short, reduce the number of scenarios rather than skipping mandatory probes. One scenario with full profile coverage beats three scenarios with only happy paths.

---

### Full Lifecycle Sequence

Always test the complete lifecycle in order. Do not test Read without first running Create in the same session.

Required sequence: **Create → Read → Update → Read → Delete → Read**

Verify at each step:
- **After Create:** the record appears in every view that should show it, with all field values exactly as submitted. No truncation, no encoding change, no type conversion.
- **After Read:** no data from other users, accounts, or contexts appears alongside the expected record.
- **After Update:** only the changed fields have new values; all other fields retain their previous values exactly.
- **After Delete:** the record no longer appears in any view. Related records are either also removed (if cascade deletion is expected) or remain intact (if they should be preserved). Any UI controls for the deleted record are gone.

### Cardinality Testing

For any feature that displays a list, count, or collection:

| Item count | What to verify |
|---|---|
| Zero items | An appropriate empty state message is displayed. No controls that require at least one item are active (e.g., "Select All" must not be clickable when the list is empty). |
| One item | Singular and plural labels are correct. Single-item selection and "all" selection both work correctly. Sorting with only one item does not error. |
| Two or more items | All items appear correctly. Pagination triggers at the correct count threshold. Bulk actions apply to all selected items. |
| One over the stated maximum | The limit is enforced and an error message is shown. No silent truncation of the excess item. |

### State Transition Testing

Before testing any flow with multiple states (e.g., Draft → Submitted → Approved → Archived):
1. Map every valid state and every permitted transition between states
2. Test each permitted transition — verify the target state is reached
3. Test at least two invalid transitions — attempt to reach a state that cannot be reached from the current state
4. Test submitting an action when the item is already in the target state (attempting a duplicate transition)
5. If the feature allows returning to an earlier state: test that rollback and verify all expected side effects are reversed

### Action Repetition and Idempotency Testing

Apply to every action that modifies server state (Create, Submit, Pay, Publish, Send, Delete):
- Double-click the submit button or primary action trigger in rapid succession
- Submit the form, then use browser Back and resubmit the same form
- Open the same flow in two browser tabs and submit from both within seconds of each other
- Trigger the action, interrupt it mid-progress (by navigating away or cutting the network), then retry

Expected result: the server-side outcome of the action occurs exactly once regardless of how many times the trigger is activated. The application must prevent, detect, or safely handle duplicate submissions.

### Interruption Testing (Data Lifecycle Angle)

For general interruption probes (browser back, refresh, deep-link, duplicate sessions), see Section 1: Operational Interruption Handling. This section adds the **data integrity** concern:

- After any interruption mid-CRUD, verify the record is in a valid, consistent state — no partial creates, orphaned references, or silently discarded updates
- If the app prompts for re-authentication after session expiry mid-flow, verify that unsaved data is preserved or that the user is clearly warned it will be lost

### Dependency Failure Testing (Data Lifecycle Angle)

For general dependency failure probes (500 responses, expired tokens, denied permissions), see Section 1: External Integration Behavior. This section adds the **data integrity** concern:

- After a dependency failure mid-CRUD, verify the record is not left in a partially modified state
- Verify the application can recover and complete the operation correctly once the dependency becomes available again

---

## Section 4: Coverage Rules

These rules prevent systematic gaps. Apply them throughout the session, not only at the end.

**Before calling any scenario passed:** at least one probe must have tested a failure condition — an invalid input, a missing required field, or an interrupted flow. Testing only the happy path is not sufficient evidence of correctness.

**Run at least one probe designed to fail per scenario.** Probes that only confirm expected behavior will only find accidental defects. Intentional failure probes are required.

**Never mark a dimension as tested unless a specific probe was executed and its result was recorded.** Assuming a dimension is covered is not coverage.

**After completing each scenario, spend 30 seconds reviewing what was not tested.** Ask: which inputs did I not try? Which states did I not reach? Which integrations did I not stress? Log anything significant as an explicit observation.

**Vary the starting probe type across scenarios.** If every scenario starts with the happy path, the same type of defect will be found in the first scenario and missed in later ones.

**Any scenario involving an external call must include at least one test of what happens when that call fails.** Integration failure probes are the most commonly skipped. No integration scenario is complete without at least one failure mode tested.

**Profile gate verification at checkpoint:** Before logging a checkpoint, verify every mandatory probe for the scenario's profile tags has been executed. If any are missing, execute them before moving to the next scenario — do not defer mandatory probes to "remaining" unless the session is being emergency-stopped.

**Explore beyond mandatory probes.** The profile checklists are the floor. The best findings come from following hunches, trying unexpected inputs, and investigating surprising behavior. After completing mandatory probes for a scenario, spend remaining scenario time on creative exploration — test combinations the checklist doesn't cover, try the feature in ways a real user might misuse it, look for inconsistencies between different parts of the app.

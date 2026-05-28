# Navigation Protocol

How Web Navigator drives the product step-by-step and applies the active skill's rules at each step.

---

## Step Format

Every navigation step follows this structure:

```
Step N: [description]
  Action:  [what the user does — click, type, navigate, etc.]
  Input:   [data provided with the action, if any — optional]
  Output:  [what the system produces — page change, message, state change]
```

### Examples

```
Step 1: Navigate to login page
  Action:  goto <TARGET_URL>/login
  Input:   —
  Output:  Login page loaded with email and password fields

Step 2: Enter credentials
  Action:  Fill email field, fill password field
  Input:   email=$USER_EMAIL, password=<redacted>
  Output:  Fields populated, no errors

Step 3: Submit login
  Action:  Click "Log in" button
  Input:   —
  Output:  Dashboard page loaded, user greeting visible

Step 4: Navigate to feature under test
  Action:  Click "<feature>" in sidebar
  Input:   —
  Output:  Feature page loaded
```

---

## Execution Loop

For each step, execute the following stages. **Every mutating side effect goes through a script in `../scripts/`** — no hand-written audit entries, no hand-written finding files. The combined scripts (`goto.sh`, `screenshot.sh`, `fail-check.sh`, `pass-check.sh`) enforce invariants that are easy to violate by hand.

| Stage | What it does | Script call |
|---|---|---|
| **Navigate** | Move to a URL with guardrail + log + auto-snapshot | `goto.sh "$DIR" "<url>"` (combines guardrail + `goto` + NAV log + snapshot — refs are refreshed automatically) |
| **Interact** | Click / fill / select against refs from the latest snapshot | `playwright-cli click <ref>` etc. After the action: `log-audit.sh "$DIR" ACT "<description>"` |
| **Apply (PASS)** | A rule check passed | `pass-check.sh "$DIR" "<rule-id>" "<description>"` |
| **Apply (FAIL)** | A rule check failed → finding required | `fail-check.sh "$DIR" "<rule-id>" <Severity> "<title>"` with body fields as env vars. Combines CHECK FAIL log + finding write. |
| **Capture evidence** | Screenshot a pass-proof or failure-proof | `screenshot.sh "$DIR" "<description>"` (env `FINDING_ID=<id>` for failure evidence). Combines screenshot + EVIDENCE log. |
| **Restore** | Return to pre-check state if a check was destructive | `playwright-cli goto <url>` (which goes through guardrail again if you use `goto.sh`) or `playwright-cli state-load` |
| **Checkpoint** | Summarize coverage at 5-minute marks | `log-audit.sh "$DIR" SESSION "checkpoint — <heuristic coverage shorthand>"` |
| **Proceed** | Advance — **stop if a blocker is found** | (no script) |

### Why the combined scripts matter

The hand-rolled "log first, then capture, then write finding" sequence has been the #1 source of agent error in battle tests. The combined scripts make it impossible to do half the pairing:

- `goto.sh` won't navigate without also snapshotting — preventing stale refs after page changes.
- `screenshot.sh` won't write a file without also logging EVIDENCE — preventing orphaned evidence.
- `fail-check.sh` won't log CHECK FAIL without also writing a finding — preventing the FAIL-without-finding validator failure.

Use the combined scripts. Drop to lower-level (`log-audit.sh`, `playwright-cli screenshot`, `write-finding.sh`) only for the rare case where you need finer control.

### During execution

**Keep chat output minimal throughout the loop.** Surface only blockers, findings (`functional-001 (HIGH): title`), and checkpoint summaries — `audit.log` and the session files are the complete record.

Do NOT narrate each browser action. The [session](session.md) is the record.

### Blockers

A blocker is any condition that prevents continuing the flow:
- Page crash or unrecoverable error
- Authentication failure (wrong credentials, session expired)
- Target page not found (404) or access denied (403)
- Critical element missing (form, button, or key component not rendered)

When a blocker is encountered:
1. Log it as a finding with the details available.
2. Log in audit trail: `[HH:MM:SS] [info] NAV: BLOCKER — [description]`.
3. Stop the current flow — do not attempt to work around it.

---

## Navigation Instruction Sources

Steps can come from three sources:

| Source | Description | When |
|---|---|---|
| **User prompt** | Explicit instructions provided in the prompt | Default — user describes what to navigate and test |
| **Context-inferred** | Derived from files containing acceptance criteria, use cases, or specs | User points to a file or feature with documented behavior |
| **Exploratory** | Agent decides the navigation path autonomously | **Only if explicitly confirmed in the prompt** — never assumed |

At session start, identify which source applies and log it:

```bash
scripts/log-audit.sh "$SESSION_DIR" SESSION "navigation source — prompt"
```

### User Prompt (default)

Parse the user's prompt into ordered steps. The prompt may be:
- Specific: "Go to login, enter credentials, submit, verify dashboard loads"
- Goal-oriented: "Test the checkout flow"
- Feature-focused: "Navigate to user management and check the invite flow"

For goal-oriented or feature-focused prompts, break the goal into concrete steps before execution.

### Context-inferred

When the user references a file with acceptance criteria or use cases:
1. Read the referenced file.
2. Extract the steps or scenarios described.
3. Convert them into the Step Format.
4. `scripts/log-audit.sh "$SESSION_DIR" SESSION "navigation source — context-inferred from <file path>"`.

### Exploratory

The agent autonomously decides what to navigate and test. This mode is **only activated when the user explicitly states it** in the prompt (e.g., "explore the dashboard freely", "navigate wherever you think is interesting").

If the prompt does not explicitly mention exploration, do NOT use this mode. Default to `prompt` source.

---

## Production Guardrail

Before **every** `goto` (initial URL **and** redirect targets):

```bash
scripts/check-host.sh "<url>" [.blocked-hosts]
```

Exit 0 = proceed. Exit 1 = stop, log via `log-audit.sh "$DIR" SESSION "blocked host: <url>" error`. Exit 2 = ambiguous; confirm with user before proceeding.

---

## Tool Efficiency Rules

These rules prevent the most common sources of wasted tool calls.

### Read-Once Rule

Read each reference file **once** during the session. After the initial load, rely on in-context knowledge — do not re-read the same file. Exception: `session.md` and `audit.log` may be re-read on continuation.

### Snapshot Reading Pattern

After taking a `playwright-cli snapshot`, **read the YAML file directly** (with offset/limit if needed) instead of running multiple grep commands. One read replaces 3–4 failed greps. Never grep a snapshot file more than once — if the first grep misses, read the file instead.

### Interaction Retry Limit

If a browser interaction (click, fill, select) **fails twice with the same approach**, stop and change strategy:
1. Take a fresh snapshot.
2. Read it to understand the current DOM state.
3. Choose a different interaction method (e.g., `run-code` with a custom locator, force-click with position, dismiss overlays first).

Do not retry the same selector or approach a third time.

### Screenshot Discipline

- Take screenshots only for evidence (pass proof + finding proof). Do not take speculative screenshots "just in case."
- Use `playwright-cli snapshot` (DOM) for state inspection; use `playwright-cli screenshot` only for evidence collection.

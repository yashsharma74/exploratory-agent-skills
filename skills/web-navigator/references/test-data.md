# Test Data Management

Ensure the required data state exists before navigation begins.

Web Navigator does not own application-specific test data — the user, the active skill, or the host project provides fixture definitions and (where possible) setup helpers.

---

## Fixture Lifecycle

```
Discover → Setup → Verify → Use → Teardown
```

1. **Discover** — Determine what data state the target feature requires from the user's instructions.
2. **Setup** — Create or verify the required data exists.
3. **Verify** — Confirm the fixture is in the expected state before navigation starts.
4. **Use** — Execute the navigation and checks against the fixture data.
5. **Teardown** — Clean up created data (environment-dependent).

---

## Fixture Types

| Type | Description | Example |
|---|---|---|
| Account State | Subscription / plan / feature flags | "Pro plan with 500 credits" |
| Entity | Required records that must exist | "3 records, 1 with attachments" |
| User Role | Authenticated as a specific role | "Admin" |
| Cardinality | Specific item counts for edge cases | "0 items (empty state), 1 item, 50+ items" |
| Feature State | Entity in a specific lifecycle state | "Draft" |

---

## Setup Methods

| Method | When to use | Speed |
|---|---|---|
| **UI Setup** | Default — navigate and create via the app | Slower, realistic |
| **API Setup** | When REST/GraphQL endpoints are known and stable | Fast |
| **Storage State** | For auth state reuse across sessions | Instant |

### UI Setup
Navigate the application and create the required data through the UI. Log every setup action in the audit trail.

### API Setup
Use `playwright-cli run-code` to make direct API calls when the endpoints are known. Faster but requires knowledge of the API.

### Storage State
Use `playwright-cli state-save` / `playwright-cli state-load` to persist and restore authentication state. Useful for reusing login across sessions.

---

## Fixture Declaration

Before navigation begins, record fixtures in `session.md`:

```markdown
## Fixtures

| Fixture | Type | Setup Method | Status |
|---|---|---|---|
| Draft record "Test 1" | Entity + Feature State | UI creation | Ready |
| Admin account | Account State | `.env` credentials | Ready |
| Empty list state | Cardinality | Verified in UI | Ready |
```

Each fixture must reach `Ready` status before navigation starts. If a fixture setup fails, log it and stop — do not proceed with incomplete data.

---

## Teardown Policy

The teardown policy depends on the environment:

| Environment | Policy |
|---|---|
| Staging (shared) | Recommended but not required (environments are periodically reset) |
| Development (shared) | Required — clean up created data to avoid polluting shared state |
| Local | Optional |
| Per-user / per-PR ephemeral | Optional (the environment will be torn down) |

Log teardown actions (or the decision to skip) in the audit trail:

```
[HH:MM:SS] [info] SESSION: teardown — deleted record "Test 1"
[HH:MM:SS] [info] SESSION: teardown — skipped (staging, periodic reset)
```

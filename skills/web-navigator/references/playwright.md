# Playwright Best Practices

Tool-specific rules and efficiency patterns for `playwright-cli` — the browser automation tool Web Navigator uses.

---

## Browser Tool Exclusivity

See [`setup.md` — Hard Rules](setup.md#hard-rules). All browser interaction via `playwright-cli` exclusively — MCP browser tools and host-project test reads are banned.

---

## Viewport

After opening the browser, apply the selected viewport with `resize` before any navigation:

```bash
playwright-cli resize {width} {height}
```

Screenshots capture the full viewport regardless of OS window size. See [`viewports.md`](viewports.md) for the catalog and selection rules. Do not resize mid-session.

---

## Selector Resolution

`playwright-cli` accepts **three selector types**. Plain text strings (e.g., `"Log in"`, `"Continue"`) are **not valid selectors** and will fail.

### Priority Order

| Priority | Type | Syntax | When to use |
|---|---|---|---|
| **1 (default)** | Element ref | `e15` | Standard interactions — refs come from the snapshot returned after every command |
| **2** | CSS selector | `"#main > button.submit"` | When refs are unavailable or you need structural targeting |
| **3** | Playwright locator | `"getByRole('button', { name: 'Submit' })"` | When you need accessible-name matching or resilient targeting across page changes |

### Examples

```bash
# Element ref (preferred — fast, unambiguous)
playwright-cli click e15
playwright-cli fill e5 "user@example.com"

# CSS selector
playwright-cli click "#main > button.submit"

# Playwright locator
playwright-cli click "getByRole('button', { name: 'Submit' })"
playwright-cli click "getByTestId('submit-button')"
playwright-cli fill "getByLabel('Email')" "user@example.com"
```

### Converting Refs to Locators

Use `generate-locator` when you need a stable locator for an element you found via ref:

```bash
playwright-cli generate-locator e5 --raw
```

---

## Retry Strategy

If a browser action (click, fill, select) **fails twice** with the same approach:

1. **Take a fresh snapshot** — the page state may have changed since the last command.
2. **Use the new element ref** from the fresh snapshot.
3. If the element is still not found:
   - Dismiss overlays or modals that may be blocking.
   - Try a CSS selector or Playwright locator.
   - Use `run-code` with explicit waits (`waitForSelector`).
   - Force-click with position coordinates as a last resort.

Do **not** retry the same selector or approach a third time. Log each attempt in the audit trail.

---

## Refs Are Invalidated By Navigation

**Critical rule.** Element refs (`e15`, `e21`, etc.) are valid only until the next page change. After **any** `goto`, redirect, or major DOM mutation, take a fresh snapshot to get new refs. Using stale refs will silently no-op (the fill/click appears to succeed but does nothing).

Pattern:

```bash
playwright-cli goto https://example.com/login
playwright-cli snapshot --filename=...   # ← MANDATORY after goto
# now read the snapshot file to find new refs
playwright-cli fill e16 "user@example.com"   # e16 from the *new* snapshot
```

If you cannot afford to refresh the snapshot (large pages, perf-sensitive), use **stable locators** instead of refs:

```bash
playwright-cli fill "getByRole('textbox', { name: 'Username' })" "tomsmith"
playwright-cli click "getByRole('button', { name: 'Login' })"
```

Stable locators (role + accessible name, test-id, label) survive page reloads where refs do not.

---

## Snapshot Discipline

**Key insight:** `playwright-cli` auto-returns a snapshot after every command. You do NOT need to call `playwright-cli snapshot` explicitly to see page state — read the snapshot file path from the command's output.

### When explicit snapshot IS needed

- To **save to a specific file path** for session evidence.
- To snapshot a **specific element**: `playwright-cli snapshot e34`.
- To control **depth**: `playwright-cli snapshot --depth=4`.
- To get **bounding boxes**: `playwright-cli snapshot --boxes`.

### When explicit snapshot is NOT needed

- After any command that returned a snapshot in its output (most commands).
- To "verify" a fill or click succeeded — the action output already confirms it.

### Session-local storage

When saving a snapshot explicitly, store it in the session's `snapshots/` folder:

```bash
playwright-cli snapshot --filename=exploratory-reports/[session-id]/snapshots/[NN]-[description].yaml
```

Naming follows the [evidence naming convention](evidence.md#naming-convention): `[NN]-[short-description].yaml` (e.g., `01-login-page.yaml`, `02-after-submit.yaml`). The `[NN]` counter is shared with evidence files to maintain a global chronological order.

Log each saved snapshot in the audit trail:
```
[HH:MM:SS] [info] SNAPSHOT: captured → snapshots/01-login-page.yaml
```

Snapshots are kept for the lifetime of the session — no cleanup.

---

## Command Chaining

Sequential commands are the standard pattern — each returns a snapshot with updated refs:

```bash
playwright-cli fill e1 "user@example.com"
playwright-cli fill e2 "password123"
playwright-cli click e3
```

When no intermediate snapshot is needed, chain with `&&` to reduce tool calls:

```bash
playwright-cli fill e1 "user@example.com" && playwright-cli fill e2 "password123" && playwright-cli click e3
```

Trade-off: chaining is faster (1 tool call) but hides intermediate snapshots. Use sequential calls when you need updated refs between actions.

---

## Atomic Sequences with `run-code`

When 3+ actions must execute as a unit (login, form submit + navigation, multi-step setup), use a single `run-code` block:

```bash
playwright-cli run-code "async page => {
  await page.getByRole('textbox', { name: 'Work email' }).fill('user@test.com');
  await page.getByRole('textbox', { name: 'Password' }).fill('pass');
  await page.getByRole('button', { name: 'Log in' }).click();
  await page.waitForURL('**/dashboard');
}"
```

This replaces fill + fill + click + wait (4 tool calls) with 1.

**Quoting rule:** Wrap `run-code` scripts in **double quotes** (`"..."`). Use **single quotes** inside the script for JavaScript strings. The code must be a single function expression starting with `async page =>`.

For complex scripts, load from a file:

```bash
playwright-cli run-code --filename=./login-script.js
```

---

## Auto-Waiting over Sleep

Never use `sleep N` to wait for page state. Playwright has built-in auto-waiting — actions like `click` and `fill` already wait for elements to be actionable. For navigation and async state, use wait strategies inside `run-code`:

```bash
# Wait for URL change
playwright-cli run-code "async page => { await page.waitForURL('**/dashboard'); }"

# Wait for network idle
playwright-cli run-code "async page => { await page.waitForLoadState('networkidle'); }"

# Wait for element to appear
playwright-cli run-code "async page => { await page.locator('.results').waitFor({ timeout: 10000 }); }"

# Wait for condition
playwright-cli run-code "async page => { await page.waitForFunction(() => window.appReady === true); }"
```

---

## Inspection Techniques

When rules require inspecting page state beyond visible content:

- **Element attributes** — use `eval` to inspect a single element (simpler than `run-code`):
  ```bash
  playwright-cli eval "el => el.textContent" e5
  playwright-cli eval "el => el.getAttribute('data-testid')" e5
  playwright-cli eval "el => el.id" e5
  playwright-cli eval "el => el.className" e7
  playwright-cli eval "el => getComputedStyle(el).color" e5
  ```

- **Accessibility tree** — use `playwright-cli snapshot` to read the full accessibility tree with ARIA roles, names, labels, and focus state.

- **DOM search** — use `run-code` with `page.evaluate()` for complex queries:
  ```bash
  playwright-cli run-code "async page => {
    return await page.evaluate(() => document.querySelectorAll('[aria-invalid]').length);
  }"
  ```

These are tool-level techniques — rules describe **what** to check, not **how** to use the tool.

---

## Screenshot Syntax

```bash
# Screenshot entire viewport
playwright-cli screenshot

# Screenshot specific element
playwright-cli screenshot e5

# Screenshot with custom path (note equals sign)
playwright-cli screenshot --filename=exploratory-reports/[session-id]/evidence/[NN]-[description].png
```

Use `playwright-cli screenshot` only for evidence collection — see [`evidence.md`](evidence.md).

---

## Video Recording

For sessions at the "text + screenshots + video" evidence level:

```bash
# Start recording (positional arg, not --filename=)
playwright-cli video-start exploratory-reports/[session-id]/evidence/[NN]-[description].webm

# Stop recording
playwright-cli video-stop
```

Maximum 2 videos per session. A screenshot is still required per finding — video supplements, never replaces. See [`evidence.md` — Evidence Levels](evidence.md#evidence-levels).

---

## Anti-Patterns

| Do NOT | Do instead |
|---|---|
| Use plain text as a selector (`"Log in"`) | Use ref (`e15`) or locator (`"getByRole('button', { name: 'Log in' })"`) |
| Wrap `run-code` in single quotes | Double quotes: `"async page => { ... }"` |
| Call `playwright-cli snapshot` after every command | Read the snapshot path from the command's own output |
| Use `run-code` to inspect a single attribute | Use `eval`: `playwright-cli eval "el => el.id" e5` |
| `sleep N && snapshot` | `run-code` with `waitForURL` / `waitForSelector` |
| Grep a snapshot file multiple times | Read the YAML directly with offset/limit |

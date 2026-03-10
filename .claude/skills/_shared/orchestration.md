# Shared: Orchestration Contract

All Explorer Agent skills inherit this execution contract. Read once per session.

---

## 1. Browser tool prerequisite

> **Package note:** The preferred CLI is `@playwright/cli` (binary: `playwright-cli`) — a token-efficient browser control tool built for coding agents, distinct from `@playwright/test`. After install, run `playwright-cli install --skills` to wire it into the agent.

Detect available browser automation in this priority order:

1. **`playwright-cli` (global)** — run `playwright-cli --version` via Bash.
   - If found → jump to §1a (skills setup), then set `BROWSER_TOOL=playwright-cli`.
   - If not found → attempt global install: `npm install -g @playwright/cli@latest`
     - If install succeeds → jump to §1a.
     - If install fails (permission denied or npm unavailable) → fall through to step 2.

2. **`playwright-cli` (npx)** — run `npx @playwright/cli --version` via Bash.
   - If resolves → jump to §1a (use `npx @playwright/cli` as prefix), then set `BROWSER_TOOL=npx-playwright-cli`.
   - If fails → fall through to step 3.

3. **Playwright MCP (fallback)** — check if `mcp__playwright__browser_navigate` is available in the tool list.
   - If available → set `BROWSER_TOOL=playwright-mcp` and use MCP tools.
   - If unavailable → step 4.

4. **No browser agent found** → stop immediately and output:
   ```
   ERROR: No browser agent available. Cannot run browser-based testing.

   To fix, choose one option:
     A) Install playwright-cli globally:  npm install -g @playwright/cli@latest && playwright-cli install --skills
     B) Install via npx:                  npx @playwright/cli install --skills
     C) Add Playwright MCP to .claude/settings.json:
           "mcpServers": { "playwright": { "command": "npx", "args": ["@playwright/mcp@latest"] } }

   Re-run the skill after installing.
   ```

Store the detected tool as `BROWSER_TOOL` for the session. Do not re-detect mid-session.

### 1a. playwright-cli — skills setup (runs when `BROWSER_TOOL` is `playwright-cli` or `npx-playwright-cli`)

Set the command prefix:
```
CMD=playwright-cli            # if BROWSER_TOOL=playwright-cli
CMD="npx @playwright/cli"     # if BROWSER_TOOL=npx-playwright-cli
```

Run unconditionally at session start:

1. `$CMD install --skills` — registers playwright-cli as an agent skill provider (idempotent; safe to re-run).
   - If this fails → warn user: "playwright-cli skills setup failed — falling back." Then fall through to MCP fallback (step 3) or stop (step 4).

### 1b. playwright-cli — using registered skills

After `$CMD install --skills` completes, playwright-cli commands are available as native agent tools — use them directly without Bash.

If you are unsure which tool to use for an action, run `$CMD help` to list all available skills and their usage.

---

## 2. Safety guardrail — destructive and write actions

Before taking any action that creates, modifies, or deletes real data (submitting forms, clicking "Delete", "Confirm purchase", "Send", etc.):

- **Pause and describe** the action to the user.
- **Ask for confirmation** before proceeding: "This will [action]. Proceed? (yes/no)"
- Exception: read-only actions (navigation, snapshots, screenshots, viewing pages) never need confirmation.

If the target looks like a **live production system** (not localhost, not staging/dev/test subdomain):
- Output a one-line warning at session start: "Warning: target appears to be a production environment. Write actions will require explicit confirmation."
- Continue the session — do not block. The user chose the target.

---

## 3. Session timing and chunking

- Each session chunk is **maximum 15 minutes** of real testing.
- Track elapsed time from first browser navigation.
- At 13 minutes, begin wrapping up: write findings, capture final screenshot, write checkpoint.
- At 15 minutes, stop testing and write the Session Summary section.
- Output a continuation instruction: "Run `/explore continue` to resume this session."

---

## 4. Core execution loop

For each testing action:

```
ACT      → take one browser action (navigate, click, type, inspect)
OBSERVE  → capture result (snapshot or screenshot if finding)
PERSIST  → write to report immediately (activity log entry + finding if applicable)
COMPRESS → discard raw browser data from context after writing; keep only summaries
```

**Report is the source of truth.** If context is lost or compressed, the report must contain enough state to continue.

---

## 5. Reporting cadence

- Write an **Activity Log entry** for every action (one line, `HH:MM` timestamp).
- Write a **Finding** immediately when a defect, vulnerability, or issue is discovered.
- Write a **Checkpoint** every 5–15 minutes summarizing progress.
- Update the **Top Findings Summary** at each checkpoint.
- Never batch findings — write each one as it is discovered.

---

## 6. Screenshot discipline

- Capture a screenshot **immediately** for every finding — before navigating away.
- Capture a **baseline screenshot** at session start (post-login, first meaningful page).
- Name screenshots: `[NN]-[brief-description].png` (e.g., `01-baseline-dashboard.png`, `02-xss-reflected-search.png`).
- Maximum 5 screenshots per session chunk (see context-limits.md).
- Prefer browser snapshots (accessibility tree) for exploration; reserve screenshots for evidence. Snapshot command: `$CMD snapshot -s=$SESSION`.

---

## 7. Heuristic discipline

- Select exactly **one primary heuristic** per session (or one per skill segment in exploratory).
- Define **oracles** (what "correct" looks like) before probing.
- Test at least one probe per heuristic letter/dimension.
- Mark untested dimensions as `NT` with a brief reason.
- Convert any heuristic failure directly to a finding.

---

## 8. Auth session management

- Auth is performed **once** at session start (see auth-detection.md).
- If session expires mid-session, re-authenticate using the same stored credentials and resume.
- Never store raw credentials in the report — use `[REDACTED]`.

---

## 9. Continuation protocol (detail)

When resuming a prior session:

1. Read the prior report's README.md fully.
2. Extract: last `Checkpoint` state, all Finding IDs, cumulative duration.
3. Announce resume summary to user.
4. Continue Activity Log with timestamps that follow the prior session's timeline.
5. Do NOT renumber existing findings. New findings get the next available ID.
6. Update the Session Summary at the end of the continuation chunk.

---

## 10. Context emergency recovery

If context is running critically low (approaching limit):

1. **Stop testing immediately.**
2. Write all pending findings to the report.
3. Write a Checkpoint marking exactly where testing stopped.
4. Write the Session Summary with a `STATUS: INTERRUPTED` note.
5. Output: "Context limit approaching. Report saved. Run `/explore continue` to resume."

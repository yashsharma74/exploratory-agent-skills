# Shared: Context and Resource Limits

Hard limits for all Explorer Agent sessions. These protect context quality and ensure reports remain the source of truth.

---

## Hard limits per session chunk

| Resource | Limit | Rationale |
|----------|-------|-----------|
| Session duration | 15 minutes | Bounded focus; use continuation for longer sessions |
| Screenshots | 5 max | Evidence only — not exploration |
| Browser snapshots (a11y tree) | Unlimited | Auto-discarded after processing |
| Element refs in-context | 20 max | Evict oldest when limit reached |
| Console data retained | Errors only | Filter out info/debug/warn |
| Network data retained | Errors + slow (>3s) only | Discard successful fast requests |
| Findings in active memory | 10 max | Flush to report file; reference by ID |

---

## Screenshot discipline

Screenshots are expensive (context tokens). Apply this filter before capturing:

**DO capture:**
- Baseline screenshot after successful auth (once per session)
- Any confirmed finding (defect, vulnerability, a11y violation, regression)
- Unexpected/broken UI state

**DO NOT capture:**
- Normal navigation states
- Pages that loaded correctly as expected
- Duplicate evidence of the same finding

**Prefer snapshots for exploration** — use browser accessibility tree snapshots (zero screenshot budget) to read page structure.

---

## Data retention rules

After processing a browser action result:

1. **Snapshot data** — extract relevant elements/text, then discard the raw snapshot.
2. **Network requests** — keep only: status >= 400, duration > 3000ms, CORS errors. Discard the rest.
3. **Console messages** — keep only: `error` level. Discard `log`, `info`, `warn`, `debug`.
4. **Page source** — never retain raw HTML; extract only the specific elements needed.

---

## Activity log token discipline

Each Activity Log entry must be ≤ 15 words:

```
Good:  10:03 navigated to /settings/users — loaded correctly
Good:  10:05 F-002 discovered: delete button visible to read-only user
Bad:   10:05 I clicked on the settings page and it loaded and I could see all the users listed there and then I noticed something that seemed off
```

---

## Fallback mode (explicit-instruction models)

If the model cannot execute multiple steps autonomously (permission restrictions, tool limits):

- Switch to: **one action per confirmation checkpoint**
- After each action, output: "[ACTION TAKEN] — [RESULT]. Next planned action: [NEXT]. Proceed? (yes/no)"
- User types yes/no to advance.
- Report writing happens after every 3 confirmed actions.

---

## Emergency recovery procedure

Trigger when: context usage > 90%, repeated tool failures, or model signals confusion.

1. Stop all testing immediately.
2. Flush all pending Activity Log entries to report file.
3. Flush all in-memory findings to report file.
4. Write a Checkpoint with `STATUS: EMERGENCY_STOP`.
5. Write Session Summary with `STATUS: INTERRUPTED`.
6. Output:
   ```
   Session interrupted due to context limits.
   Report saved to: exploratory-reports/[session-dir]/README.md
   Run `/explore continue` to resume.
   ```

---

## Multi-session continuations

- Each continuation is a new 15-minute chunk.
- Prior session's findings are read from the report file (never re-tested).
- Cumulative duration = sum of all chunk durations (tracked in Activity Log).
- There is no limit on the number of continuations for a single session.

# Setup — Tools & Configuration

Tool installation, browser configuration, skill and evidence selection.

---

## Tool Prerequisites

Before any other action, run the environment check script [`../scripts/check-env.sh`](../scripts/check-env.sh).

Interpret the output:

- `playwright-cli: <version> (global)` → proceed with `playwright-cli` as primary tool.
- `playwright-cli: <version> (npx)` + `USE_NPX=true` → use `npx playwright-cli` prefix for all commands.
- `ERROR: playwright-cli not found` → ask the user to install (see SKILL.md Phase 1).

After playwright-cli is confirmed, load the official skill:

```bash
playwright-cli install --skills
```

**Permissions (if your agent requires explicit allow-listing):** ensure `playwright-cli` commands are allowed without per-call prompts. For Claude Code, that means adding to `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": ["Bash(playwright-cli *)"]
  }
}
```

For other agents, consult their allow-list / approval configuration. Without this, each call may require manual approval, severely impacting session performance.

**Browser mode:** playwright-cli runs headless by default. Pass `--headed` to the `open` command for a visible window. Headless is faster — use headed only for visual debugging.

**Viewport:** Always `open` (no URL) → set viewport → `goto`. Default is `desktop` (1280×720). See [`viewports.md`](viewports.md) for the catalog, headless/headed setup sequences, and window alignment.

**State reuse:** Storage state files are saved inside the current session folder. Before performing a UI login, check if a saved state exists from an earlier step in the same session:

```bash
playwright-cli state-load exploratory-reports/[session-id]/state-[role].json
```

If found and valid, skip the login flow. After a successful UI login, save the state for reuse within the session:

```bash
playwright-cli state-save exploratory-reports/[session-id]/state-[role].json
```

This eliminates redundant login sequences when a session requires logging out and back in (e.g., testing multiple roles or re-authentication after cookie clearing).

---

## Hard Rules

- All browser interaction via `playwright-cli` exclusively.
- MCP browser tools (`mcp__playwright__*`, `mcp__claude-in-chrome__*`, etc.) are **banned** for the session once `playwright-cli` is confirmed.
- Existing test artifacts in the host project (Playwright tests, page objects, fixtures) are **out of bounds** — do not read, reference, or use as a proxy for live browser interaction. Use the browser; do not read code that simulates the browser.

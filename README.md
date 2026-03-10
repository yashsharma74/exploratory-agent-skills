# Explorer Agent

A standalone, open-source exploratory testing framework for Claude Code. Works with **any** website or web application — public sites, form-based auth, SSO/OAuth, HTTP Basic auth, or API-key-gated apps.

## What it does

Explorer Agent orchestrates structured, time-boxed exploratory testing sessions using Claude Code and a browser automation tool (Playwright MCP or local Playwright). It applies industry-standard testing heuristics (SFDPOT, STRIDE, POUR, RAIL, and more) and produces structured markdown reports with findings, evidence, and actionable recommendations.

## Supported application types

| Type | Example |
|------|---------|
| **Public website** | `https://example.com` |
| **Form-based login** | username + password fields |
| **OAuth / SSO** | Google, Microsoft, GitHub, Okta, Auth0, custom IdP |
| **HTTP Basic auth** | Browser credential dialog |
| **MFA / 2FA** | TOTP prompts, email codes |
| **API-key apps** | Token passed in header or URL param |

## Requirements

- [Claude Code](https://claude.ai/claude-code) CLI (`claude` command)
- One of:
  - **Playwright MCP server** — `@playwright/mcp` configured in `.claude/settings.json` (recommended)
  - **Local Playwright** — `npx playwright` available on PATH

## Installation

### Option A — Standalone project

```bash
git clone https://github.com/your-org/explorer-agent
cd explorer-agent
claude    # start Claude Code here
```

### Option B — Add to an existing project

```bash
# From the explorer-agent directory:
cp -r .claude/commands/* /path/to/your-project/.claude/commands/
cp -r .claude/skills/    /path/to/your-project/.claude/skills/
```

Then open Claude Code from your project root and use `/explore`.

### Playwright MCP setup (recommended)

Add to your `.claude/settings.json`:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

## Quick start

```
/explore https://example.com
```

```
/explore https://app.example.com  login: admin@example.com / secret123
```

```
/explore https://app.company.com  sso via microsoft | user@company.com / corppass  focus security
```

See [SAMPLE-PROMPTS.md](./SAMPLE-PROMPTS.md) for the full prompt reference.

## Testing skills

| Skill | Focus | Heuristics |
|-------|-------|-----------|
| **exploratory** | Broad exploration + router | SFDPOT, STRIDE, POUR, RAIL |
| **functional** | User flows, validation, state | SFDPOT, BINMEN, Count |
| **security** | Auth, injection, data exposure | STRIDE, VADER, OWASP WSTG |
| **accessibility** | WCAG 2.1 AA, keyboard, screen reader | POUR, KART, WCAG AA |
| **performance** | Load, console errors, slow requests | RAIL, Starvation, HICCUPPS |
| **charters** | Plan 3-5 test charters before execution | Risk-scoring |

## Output

Reports are written to:
```
exploratory-reports/
  [YYYY-MM-DDTHHMMSSZ]-[skill]-[feature]/
    README.md          ← main report
    screenshots/       ← evidence
```

## Design principles

- **Heuristic-driven** — every session anchors to a named testing heuristic
- **File-first** — report is the source of truth, not chat memory
- **Bounded sessions** — 15-minute chunks with built-in continuation
- **Auth-aware** — detects and handles any login flow before testing begins
- **Safe by default** — warns before any destructive or write action; never auto-submits forms that create/delete real data without confirmation
- **Evidence-first** — screenshot captured immediately on finding
- **Portable** — no external services, no telemetry, runs anywhere

## License

MIT

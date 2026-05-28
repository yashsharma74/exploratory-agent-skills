# Exploratory Agent Skills

A generic, agent-agnostic exploratory testing toolkit. Works with **any** AI coding agent — Claude Code, OpenAI Codex, GitHub Copilot, Cursor, Aider, Gemini CLI, Continue, Windsurf — and **any** web application: public sites, form login, SSO/OAuth, HTTP Basic, API keys, MFA.

## What it does

The toolkit ships **three independent modules** plus composition at the entry point. Each module has a single responsibility; none cross-references the others.

| Module | Single responsibility |
|---|---|
| **`web-navigator/`** | Browser orchestration — drive `playwright-cli`, write session folder, audit log, file format, evidence collection, write policy. Testing-agnostic. |
| **`_testing-conventions/`** | Universal testing rules — ID format, severity scale, time-budget tiers, coverage logging, missed-coverage reporting. Same across every testing skill. |
| **Each `<domain>-testing/` skill** | Domain methodology — workflow, heuristics, skill-specific required fields and scaling. Atomic. |

The four testing skills:

- **`functional-testing`** — flows, validation, state, business logic. Heuristics: SFDPOT + profile-tagged mandatory probes.
- **`security-testing`** — XSS, injection, AuthN/AuthZ, CSRF, data exposure. Heuristics: VADER, POISED, STRIDE + CIA + OWASP WSTG mapping.
- **`accessibility-testing`** — WCAG 2.1/2.2 AA. Heuristics: POUR + KART, automated sweep + manual checks.
- **`performance-testing`** — console errors, network failures, load timing, runtime stability. Heuristics: RAIL + Starvation + HICCUPPS.

**Composition lives at the entry point** (`AGENTS.md`, `.github/prompts/explore.prompt.md`, `.github/copilot-instructions.md`). The entry point tells the agent which modules to load together for a testing session — the modules themselves don't know about each other.

## Architecture

**Single Responsibility Principle.** Each module owns one thing and doesn't reach into the others. Browser mechanics don't know about testing semantics; testing skills don't know about file formats or universal rules; universal rules don't know about specific skills or mechanics.

**Composition at the boundary.** The entry-point docs (`AGENTS.md`, Copilot prompt) load `web-navigator/` + `_testing-conventions/` + the active skill together. The agent reads all three; the skill files themselves stay closed and atomic.

**Canonical markdown.** Skill content is plain markdown with YAML frontmatter — readable by any agent. `.github/` is a thin Copilot adapter that points at `skills/`, never duplicates content.

## Repository layout

```
exploratory-agent-skills/
├── AGENTS.md                              # Universal entry (Codex, Aider, Gemini CLI, others)
├── CLAUDE.md                              # Claude Code adapter (auto-read)
├── HEURISTICS.md                          # Glossary: SFDPOT, STRIDE, POUR, RAIL, VADER, POISED, KART
├── HATS.md                                # Tester personas — orthogonal to skills+heuristics
├── AUTONOMY.md                            # How to pre-approve tool patterns per agent
├── .claude/settings.json                  # Project-level Claude Code permissions
├── README.md
├── skills/                                # Canonical content — agent-neutral
│   ├── _testing-conventions/              # SR: universal testing rules — no per-skill exceptions
│   │   ├── findings.md                    # ID format, severity scale, actionable rec, reproducibility
│   │   └── session.md                     # Time-budget tiers, coverage logging, missed-coverage reporting
│   ├── web-navigator/                     # SR: browser orchestration — entry point, testing-agnostic
│   │   ├── SKILL.md
│   │   ├── references/{setup,environment,credentials,viewports,
│   │   │   orchestration,playwright,session,checks,findings,
│   │   │   evidence,test-data}.md
│   │   └── scripts/                       # Deterministic shell scripts (no prose substitutes)
│   │       ├── check-env.sh               # Verify playwright-cli
│   │       ├── check-host.sh              # Production guardrail (standalone)
│   │       ├── init-session.sh            # Create session folder + session.md + audit.log
│   │       ├── set-field.sh               # Edit a | Field | row in session.md
│   │       ├── log-audit.sh               # Append to audit.log (normalized format)
│   │       ├── find-ref.sh                # Extract element ref from a snapshot
│   │       ├── next-id.sh                 # Bump the Next finding number counter
│   │       ├── write-finding.sh           # Write a finding file + bump severity counter
│   │       ├── goto.sh                    # guardrail + goto + NAV log + auto-snapshot
│   │       ├── screenshot.sh              # screenshot + EVIDENCE log (pair invariant)
│   │       ├── pass-check.sh              # CHECK PASS log
│   │       ├── fail-check.sh              # CHECK FAIL log + write finding (pair invariant)
│   │       ├── summarize-session.sh       # Print end-of-session summary block
│   │       ├── end-session.sh             # Recompute counters, set Status=completed
│   │       ├── generate-report.sh         # Write a human-readable report.md
│   │       └── validate-session.sh        # Post-session compliance check
│   ├── functional-testing/                # SR: domain methodology — atomic, no external refs
│   │   ├── SKILL.md
│   │   └── references/{heuristics,oracles}.md
│   ├── security-testing/
│   │   ├── SKILL.md
│   │   └── references/heuristics.md
│   ├── accessibility-testing/
│   │   ├── SKILL.md
│   │   └── references/heuristics.md
│   └── performance-testing/
│       ├── SKILL.md
│       └── references/heuristics.md
├── .github/                               # GitHub Copilot adapter
│   ├── copilot-instructions.md
│   ├── instructions/testing-skills.instructions.md
│   └── prompts/explore.prompt.md
├── .cursor/rules/exploratory-testing.mdc  # Cursor adapter (auto-applies)
└── exploratory-reports/                   # Session output
    ├── EXAMPLE-*/                         # Canonical example session (committed)
    └── [YYYY-MM-DDTHHMMSSZ]-[skill]-[feature]/  # Real sessions (gitignored)
        ├── session.md
        ├── audit.log
        ├── findings/
        ├── evidence/
        └── snapshots/
```

The output directory can be overridden with `$EXPLORATORY_REPORTS_DIR` or a 3rd arg to `init-session.sh`.

## Requirements

- [Node.js](https://nodejs.org/) (any modern LTS)
- `playwright-cli` — install globally with `npm install -g @playwright/cli`, or let `web-navigator` invoke it via `npx`.

The environment check script will confirm availability and tell the agent how to invoke the binary:

```bash
bash skills/web-navigator/scripts/check-env.sh
```

## Installation

### Option A — Use this repo directly

Clone, open in your agent of choice, and ask it to run a session.

```bash
git clone https://github.com/your-org/exploratory-agent-skills
cd exploratory-agent-skills
# Now open the folder in Claude Code, Copilot, Codex, etc.
```

### Option B — Copy into an existing project

```bash
cp -r exploratory-agent-skills/skills/  /path/to/your-project/skills/
cp -r exploratory-agent-skills/.github/ /path/to/your-project/.github/
cp exploratory-agent-skills/AGENTS.md   /path/to/your-project/AGENTS.md
```

Add `exploratory-reports/*` to your project's `.gitignore` (except `.gitkeep` if you want the folder tracked).

## Quick start

The agent always enters through **Web Navigator** (`skills/web-navigator/SKILL.md`). The "focus" word in your prompt selects the active skill Navigator will load.

### Any agent (AGENTS.md flow)

> Read `AGENTS.md`, then run Web Navigator against `https://example.com` with `focus security`.

The agent will load `skills/web-navigator/SKILL.md`, set `active skill = security-testing` in Phase 1, and run.

### GitHub Copilot

In Copilot Chat:

```
/explore https://example.com
/explore https://app.example.com  login: user@example.com / pass  focus security
/explore https://app.example.com  sso via google | user@gmail.com / pass  focus accessibility
/explore continue
```

The `/explore` prompt parses your input, picks the active skill from `focus`, and hands off to Navigator.

### Claude Code, Codex, Cursor, others

Each reads `AGENTS.md` directly. Ask: *"Run Web Navigator against `<URL>` focused on `<area>`."* The agent loads `skills/web-navigator/SKILL.md`, picks the matching active skill, and proceeds.

## Prompt grammar

```
TARGET_URL                                       Public site, no auth
TARGET_URL  login: user@x.com / pass             Form login
TARGET_URL  sso via google | user@gmail.com / p  OAuth / SSO
TARGET_URL  basic auth: user / pass              HTTP Basic
TARGET_URL  api key: sk-abc123                   API-key gated
TARGET_URL  bearer token: eyJ...                 Bearer-token gated
TARGET_URL  ... mfa totp secret: JBSW...         With TOTP MFA
TARGET_URL  ... focus security                   Active skill = security-testing
TARGET_URL  ... focus accessibility              Active skill = accessibility-testing
TARGET_URL  ... focus performance                Active skill = performance-testing
TARGET_URL  ... focus functional                 Active skill = functional-testing
TARGET_URL  (no focus)                           Navigator's Phase 1 asks which skill to use
continue                                         Resume most recent session
continue exploratory-reports/<id>/               Resume a specific session
```

## Output

Each session writes to `exploratory-reports/[id]/`:

```
session.md      # Metadata + continuation info
audit.log       # Append-only event trail
findings/       # One markdown file per failed check
evidence/       # Screenshots, videos
snapshots/      # DOM snapshots
```

The session folder is the deliverable. There is no final report — downstream consumers (a report-writing skill, a CI step, a human) interpret the raw artifacts as needed.

## Design principles

- **Heuristic-driven** — every session anchors to a named testing heuristic (SFDPOT, STRIDE, POUR, RAIL, etc.) with explicit `tested` and `NT` coverage logged.
- **File-first** — the session folder is the source of truth. Chat is summary; disk is record.
- **Real-time persistence** — every event lands on disk the moment it happens. Context loss never costs prior findings.
- **Bounded sessions** — 15-minute default with built-in scaling for 5/10/20/25/30 min budgets.
- **Safe by default** — production hosts blocked. Destructive or write actions warned before execution. Credentials redacted in all outputs.
- **Agent-agnostic** — markdown with YAML frontmatter. No agent-specific syntax in any skill file.
- **Expandable** — `web-navigator` is reusable beyond exploratory testing. New evaluation skills drop in as sibling folders.

## Extending

To add a new evaluation skill (e.g., `visual-regression-testing`):

1. Create `skills/<name>/SKILL.md`. Include the active-skill callout, the workflow, and any skill-specific required fields / time-budget scaling / coverage heuristic inlined directly.
2. Add `skills/<name>/references/heuristics.md` (probe catalogue). Add `references/oracles.md` if the skill needs explicit judgment criteria.
3. Update the skill table in `AGENTS.md` and this README.
4. Optional: ship a `.github/prompts/<name>.prompt.md` for Copilot users.

The skill is **atomic** — no `references/findings.md` or `references/session.md`. Universal testing rules (ID format, severity, time-budget tiers) come from `_testing-conventions/`, loaded by the entry-point doc alongside your skill. The skill itself stays closed.

Neither `web-navigator/` nor `_testing-conventions/` requires changes.

## License

MIT.

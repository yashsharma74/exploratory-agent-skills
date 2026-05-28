# Testing Conventions

Shared conventions for any testing-style active skill loaded by Web Navigator.

This folder is **not a skill** — it has no `SKILL.md`, no entry point, no workflow. It documents the conventions that apply across all testing skills in this repository (functional, security, accessibility, performance) and any future testing-style active skill.

## What's here

| File | What it covers |
|---|---|
| `findings.md` | ID format, base severity scale, write-immediately, actionable recommendation, reproducibility |
| `session.md` | Time-budget tier structure, checkpoint cadence, coverage logging, missed-coverage reporting, scaling principles |

## Layering

These conventions sit **between** Web Navigator (universal mechanics) and each testing skill (skill-specific methodology and overrides):

```
web-navigator/         ← universal mechanics (browser, file format, write policy)
        │
        ▼
_testing-conventions/  ← universal testing conventions (this folder)
        │
        ▼
<testing-skill>/       ← skill-specific methodology + overrides
```

A non-testing active skill (e.g., a data-extraction skill) would not reference this folder.

## Loading

These files are loaded by the **entry-point documents** (`AGENTS.md` for general agents, `.github/prompts/explore.prompt.md` for Copilot) — never by testing skills or by Web Navigator. Composition lives at the entry point: it loads `web-navigator/`, `_testing-conventions/`, and the active skill together. The three modules don't reference each other.

## Extensions, not overrides

The conventions in this folder apply uniformly — no skill overrides them. Skills may **add** to them:

- **`accessibility-testing`** adds a `User Impact` classification (Blocked task / Severe friction / Minor friction) **alongside** the universal severity scale — both appear on every accessibility finding.
- **`security-testing`** layers a stricter reproducibility requirement (must include payload, context, and exploit path) **on top of** the universal reproducibility rule.

Skill extensions live inline in the skill's own `SKILL.md`.

# Testing Conventions — Sessions

Universal session conventions that apply across **every** testing skill, with no per-skill overrides. Each skill's own `SKILL.md` defines its own time-budget scaling table (what fits in each tier — scenarios, categories, checks, interactions, etc.), but the tier structure and the rules below are uniform.

---

## Time Budget Tiers

Every testing session runs against one of these time budgets, selected at Phase 1 setup:

| Time limit | Checkpoint cadence | Coverage expectation |
|---|---|---|
| **5 min** | 1 checkpoint at wrap-up | Minimum viable — one highest-risk dimension |
| **10 min** | Every 5 min | Moderate — 2–3 dimensions |
| **15 min** (default) | Every 5 min | Standard — all applicable dimensions attempted |
| **20 min** | Every 5 min | Thorough — deeper probes per dimension |
| **25–30 min** | Every 5 min | Deep — maximize coverage; explicitly test dimensions marked NT in shorter sessions |

What each tier produces (number of scenarios, categories, checks, or interactions) is **skill-specific** and documented in each skill's `SKILL.md`.

---

## Coverage Logging

At every checkpoint, log the heuristic letters that were tested and those that were not.

| Convention | Specification |
|---|---|
| Tested letters | List explicitly |
| Untested letters | Mark `NT` with a short reason |
| Shorthand format | `<HEURISTIC>: <tested letters> tested; <NT letters>=NT (<reason>)` |

Example: `SFDPOT: S,F,D,O tested; P=NT (single browser only); T=NT (no time-dependent features in scope)`

Each skill defines its own heuristic (SFDPOT, STRIDE/VADER/POISED, POUR, RAIL, etc.) and documents the letters in its own `references/heuristics.md`.

---

## Missed Coverage Reporting

When time pressure prevents full coverage, the end-of-session summary must include a `Missed Coverage` line listing what was skipped and why.

Example: `Missed Coverage: POUR U,R=NT — form labels and landmarks deferred due to 10-min budget`

Required even when full coverage was achieved — write `Missed Coverage: None` in that case.

---

## Scaling Principles

When time constraints force adjustment:

1. **Prioritize by risk first.** A shorter session with the right high-risk dimensions beats a longer session with low-risk ones.
2. **Reduce probe depth, not coverage.** If time runs short, narrow each probe rather than skipping dimensions. Log the adjustment in the audit trail with a reason.
3. **Never exceed the unit count** for the chosen tier — defer lower-priority items to a follow-up session.
4. **Silent scope changes are not acceptable.** Any time-driven adjustment must be logged in the audit trail.

---

## Continuation

On continuation, recalculate the remaining budget from cumulative elapsed time and scale accordingly using the skill's time-budget table. Finding IDs continue from `Next finding number` in `session.md` — never restart at `001`.

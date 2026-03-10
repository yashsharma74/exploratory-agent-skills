# Skill: Charters Creation

Defines 3–5 focused exploratory test charters for a feature area before any testing begins. Output is a planning document, not a test execution report.

---

## Purpose

Charters provide a structured plan that:
- Bounds the scope of each testing session
- Prioritizes highest-risk areas first
- Assigns the right testing skill to each charter
- Enables time-boxed, focused execution

Run this skill when: the user wants to plan before testing, the feature is complex, or multiple sessions will be needed.

---

## Pre-session checklist

- [ ] `TARGET_URL` confirmed and feature area identified from user's prompt
- [ ] Auth performed only enough to explore the feature surface (brief navigation only — see auth-detection.md)
- [ ] Report directory created: `exploratory-reports/[timestamp]-charters-[feature-slug]/`
- [ ] No testing executed yet — this is planning only

---

## Execution: Discover → Prioritize → Write charters

### Step 1 — Discover the feature surface (5 minutes)

Navigate the target feature. Do not test — only observe and document:

1. List all pages/screens involved in this feature.
2. List all user roles that interact with it (if visible from UI or documentation).
3. List all major actions users can take (create, read, update, delete, upload, search, etc.).
4. Identify integration points (third-party services, file uploads, payments, APIs visible in network).
5. Note any known risk areas (mentioned in user's prompt or obvious from the UI).

### Step 2 — Risk-score potential charters (3 minutes)

For each candidate charter area, assign:
- **Impact** (1–3): 1 = low consequence if broken, 3 = critical user flow or data at risk
- **Likelihood** (1–3): 1 = unlikely to have issues, 3 = high complexity or recent changes
- **Priority score** = Impact × Likelihood

Sort candidates by priority score descending.

### Step 3 — Write 3–5 charters (7 minutes)

Select the top 3–5 highest-priority candidates. For each, write a charter:

```markdown
### Charter [N]: [Descriptive Title]

| Field | Value |
|-------|-------|
| Area | [page / component / user flow] |
| Priority | [Impact × Likelihood score, e.g., 3×3=9] |
| Skill | [functional / security / accessibility / performance / exploratory] |
| Heuristic | [primary heuristic for this charter, e.g., BINMEN, STRIDE] |
| Estimated time | [15 / 30 min] |

**Goal:** [One sentence — what question does this charter answer?]

**Risks:** [What could go wrong in this area? 2–4 bullet points]

**Focus areas:**
- [specific flow, scenario, or probe to execute]
- [specific flow, scenario, or probe to execute]
- [specific flow, scenario, or probe to execute]

**Oracles:** [What does "correct" look like for this area?]

**Pages / URLs to visit:**
- [URL or path]
- [URL or path]

**Start command:**
`/explore [TARGET_URL] [AUTH] focus [skill] [brief description]`
```

---

## Charter prioritization order

When the feature area is unclear, use this default priority order:

1. **Authentication and authorization** — highest impact if broken
2. **Core value action** — the primary thing users do in this feature
3. **Data integrity flows** — create, edit, delete with persistence verification
4. **Error handling and recovery** — what happens when things go wrong
5. **Edge cases and boundaries** — unusual inputs, empty states, large data

---

## Output: Charters report

The output of this skill is a `README.md` in the report directory with:

1. **Feature surface map** — pages, roles, actions, integrations discovered
2. **Risk register** — all candidates with risk scores
3. **Recommended execution order** — ordered list of charters
4. **Individual charters** — 3–5 detailed charters (see template above)
5. **Execution roadmap** — estimated total time, suggested session schedule

---

## Report template for charters

```markdown
# Test Charters: [Feature Name]

## Session Info

| Field | Value |
|-------|-------|
| Target | [URL] |
| Feature | [feature area] |
| Date planned | [YYYY-MM-DD] |
| Planner | Claude (Explorer Agent) |

---

## Feature surface map

### Pages / screens
- [page 1]
- [page 2]

### User roles
- [role 1] — [what they can do]
- [role 2] — [what they can do]

### Key actions
- [action 1]
- [action 2]

### Integration points
- [external service or API]

---

## Risk register

| Area | Impact (1-3) | Likelihood (1-3) | Score | Notes |
|------|-------------|-----------------|-------|-------|
| [area] | [N] | [N] | [N×N] | [why risky] |

---

## Recommended execution order

1. Charter 1: [title] — [score] — [skill] — [~15 min]
2. Charter 2: [title] — [score] — [skill] — [~15 min]
...

**Estimated total:** [N × 15 minutes]

---

## Charters

[Individual charter blocks — see template above]

---

## Notes

[Any observations from the discovery phase that didn't fit into a charter but are worth noting]
```

---

## Execution rules for this skill

- **Do not execute test probes** during charter creation. Navigate to understand the surface only.
- **Do not take screenshots** unless discovering an obvious blocker that prevents charter planning.
- **Do not write findings** — save all testing for execution sessions.
- If you discover a critical bug during navigation, note it in the "Notes" section but do not open a full finding.

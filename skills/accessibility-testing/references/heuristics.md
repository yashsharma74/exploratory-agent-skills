# Accessibility Testing Heuristics

## POUR (Primary — letter-by-letter)

| Letter | Focus | Probe Example | Expected |
|---|---|---|---|
| P | Perceivable | verify alt text, contrast, zoom/reflow | content perceivable without loss |
| O | Operable | keyboard-only traversal and activation | all controls operable; no trap |
| U | Understandable | trigger form errors and review guidance | clear, actionable, predictable behavior |
| R | Robust | inspect name/role/value on custom controls | assistive tech announces correctly |

## KART (Secondary — letter-by-letter)

| Letter | Focus | Probe Example | Expected |
|---|---|---|---|
| K | Keyboard-only | complete key flow without mouse | end-to-end completion possible |
| A | Announced | read control/status with screen reader | meaningful announcements |
| R | Reachable | tab order through all interactives | no unreachable interactive element |
| T | Trapped | enter/exit modal/menu via keyboard | no focus trap |

## WCAG Calibration

- WCAG 2.2 is the latest recommended baseline and is backward-compatible with WCAG 2.1/2.0 for most practical checks.
- Default acceptance baseline: WCAG AA hot-path checks. Unless the user requests otherwise, hold to this minimum.

## Perceivable Example — Contrast (WCAG 1.4.3)

- **Case:** helper/error text.
- **Probe:** check normal text contrast in realistic theme.
- **Expected:** at least 4.5:1 for standard text.

## Robust Example — Name/Role/Value (WCAG 4.1.2)

- **Case:** custom button/combobox.
- **Probe:** inspect accessible name and role via assistive tooling.
- **Expected:** correct role, name, and state announcements.

## Heuristic Selection Order

1. **Primary:** POUR
2. **Secondary:** KART
3. **Standards lens:** WCAG AA hot-path criteria

## Coverage Rule

Record tested letters and explicit `NT` letters for the primary heuristic at each checkpoint.
Activity log shorthand: `POUR: P,O tested; U,R=NT`

## Execution Contract

Apply POUR as a repeatable method, not acronym recall.

1. Define an explicit oracle for each probe (WCAG criterion + AA pass condition) before testing.
2. Run at least one concrete probe per tested letter; log observed result immediately.
3. Mark untested letters `NT` with a short reason.
4. Convert any failure immediately into a finding with WCAG criterion, expected vs actual, and evidence link.

Probe design pattern: `Goal → Setup → Action → Expected → Observed → WCAG Criterion → Evidence`

## Coverage Contract

- Test all POUR letters when feasible; when time is constrained, prioritize by user impact.
- Highest-risk first: O (Operable — keyboard trap) and P (Perceivable — missing alt/contrast) before U and R unless scope says otherwise.
- Do not claim heuristic completion unless all tested and `NT` letters are explicitly logged.

# Performance Testing Heuristics

## RAIL (Primary — letter-by-letter)

| Letter | Focus | Probe Example | Expected |
|---|---|---|---|
| R | Response | click key CTA and observe feedback start | User-perceived response ~under 100ms or explicit progress |
| A | Animation | interact during transitions/scrolling | Smooth motion; no obvious frame jank |
| I | Idle | trigger background/deferred work | Input remains responsive during background work |
| L | Load | open core page on constrained profile | First useful interaction available within target budget |

RAIL calibration:
- Response target: visible feedback within ~100ms (or explicit progress indicator).
- Animation target: smooth motion near 60fps (frame budget ~16ms; app work target ~10ms).
- Load target: interactive content delivered within realistic device/network budgets.

## Starvation Example — Main-thread pressure

- **Case:** heavy page with multiple widgets.
- **Probe:** rapid tab switching + typing while network throttled.
- **Expected:** interaction remains responsive, no long UI freezes.

## Count/Load Example — Burst behavior

- **Case:** repeated submissions.
- **Probe:** submit same action in quick succession.
- **Expected:** deduping/rate handling; no duplicate side effects.

## HICCUPPS (Consistency lens — practical set)

| Check | Probe Example | Expected |
|---|---|---|
| Consistency | repeat same flow 3x | similar timing/error profile each run |
| Claims | compare observed performance vs UX claim | no major claim mismatch |
| Purpose | verify responsiveness of user-critical actions first | priority actions remain usable |

## Heuristic Selection Order

1. **Primary:** RAIL (user-perceived performance)
2. **Secondary:** Starvation / Count-Load
3. **Consistency lens:** HICCUPPS

## Coverage Rule

Record tested letters and explicit `NT` letters for the primary heuristic at each checkpoint.
Activity log shorthand: `RAIL: R,L tested; A,I=NT`

## Execution Contract

Apply RAIL as a repeatable method, not acronym recall.

1. Define an explicit oracle for each letter using the RAIL calibration targets before probing.
2. Run at least one concrete probe per tested letter; log observed result and measured delta immediately.
3. Mark untested letters `NT` with a short reason.
4. Convert any failure immediately into a finding with target vs observed metric and evidence link.

Probe design pattern: `Goal → Setup → Action → Target → Observed → Deviation → Evidence`

## Coverage Contract

- Test all RAIL letters when feasible; when time is constrained, prioritize user-critical actions first.
- Highest-risk first: R (Response) and L (Load) before A (Animation) and I (Idle) — unless a specific performance complaint shifts priority.
- Do not claim heuristic completion unless all tested and `NT` letters are explicitly logged.

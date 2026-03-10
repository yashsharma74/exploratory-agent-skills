# Skill: Accessibility Testing

WCAG 2.1 AA compliance testing with focus on keyboard navigation, screen reader compatibility, and inclusive design.

---

## Scope

**In scope:**
- Keyboard accessibility (all functions operable without mouse)
- Focus management (visible focus, logical order, no traps)
- Semantic HTML and ARIA usage
- Color contrast (WCAG AA minimum)
- Form accessibility (labels, error identification)
- Image alt text
- Heading structure
- Screen reader announcements (simulated via accessibility tree)
- Resize and zoom behavior

**Out of scope:**
- Functional bugs unrelated to accessibility
- Security or performance issues
- Full WCAG AAA compliance (unless requested)
- Real assistive technology testing (requires dedicated AT setup)

---

## Pre-session checklist

- [ ] `TARGET_URL` confirmed and page/feature area identified
- [ ] Auth performed (see auth-detection.md)
- [ ] Baseline screenshot and snapshot captured
- [ ] Report directory created: `exploratory-reports/[timestamp]-accessibility-[feature-slug]/`
- [ ] Primary heuristic: **POUR** (broad) or **KART** (keyboard-focused) based on prompt
- [ ] Oracles defined (see below)

---

## Execution: Two-phase approach

### Phase 1 — Automated structural sweep (5 minutes)

Use browser snapshot (accessibility tree) to identify issues without manual interaction:

1. **Heading structure**: is there an `<h1>`? Is the heading hierarchy logical (no skipped levels)?
2. **Landmark regions**: are `<main>`, `<nav>`, `<header>`, `<footer>` present?
3. **Image alt text**: identify all `<img>` tags — do non-decorative images have descriptive `alt`? Do decorative images have `alt=""`?
4. **Form labels**: every `<input>`, `<select>`, `<textarea>` should have an associated `<label>` or `aria-label` or `aria-labelledby`
5. **Button/link names**: every `<button>` and `<a>` should have visible text or `aria-label`
6. **ARIA usage**: check for common ARIA misuse: `role="button"` on non-interactive elements without keyboard support, `aria-hidden="true"` on focusable elements

Record all findings immediately.

### Phase 2 — Manual keyboard and interaction testing (8 minutes)

#### Keyboard navigation test

1. Click the address bar (to start from a known focus state).
2. Press `Tab` repeatedly. For each focusable element:
   - Is focus **visible**? (outline, highlight, underline)
   - Is the element **reachable** in logical order?
   - Does the element have a **name** (visible label or ARIA label)?
3. Continue until you have tabbed through all interactive elements on the page or 25 elements (whichever comes first).
4. Note any elements that:
   - Are not reachable via keyboard
   - Show no visible focus indicator
   - Have a generic name ("button", "click here", "icon")

#### Focus trap test

For each modal, dialog, dropdown, or popover:
1. Open it with keyboard (Tab + Enter/Space).
2. Press Tab — focus should stay within the modal.
3. Press Shift+Tab — focus should reverse within the modal.
4. Press Escape — the modal should close and focus should return to the trigger element.

#### Form accessibility test

For each form:
1. Tab through all fields — are all fields labeled?
2. Submit the form without filling required fields.
3. Verify: error message is text-based (not color-only), error is associated with the field (via `aria-describedby` or adjacent text), focus moves to the first error.
4. Fill the form with valid data, submit.
5. Verify: success confirmation is announced (not just visual).

#### Color and contrast spot check

Identify text that appears low-contrast by visual inspection. For suspect areas:
- Body text: should be ≥ 4.5:1 contrast ratio against background
- Large text (18pt+ or 14pt+ bold): ≥ 3:1
- UI components and focus indicators: ≥ 3:1

Note: precise contrast ratios require a tool (browser DevTools color picker or axe extension). Flag visually suspect areas as "needs contrast verification" if exact measurement is not available.

#### Resize test

1. Zoom browser to 200% (`Ctrl/Cmd +`).
2. Check: does text reflow without horizontal scrolling? Is content still readable? Is any content hidden or clipped?

---

## Applying POUR

For each finding, map to a POUR principle:

| Principle | If finding affects |
|-----------|-------------------|
| **P** Perceivable | Can't see/hear the content (missing alt text, no captions, low contrast) |
| **O** Operable | Can't interact with it via keyboard or enough time |
| **U** Understandable | Confusing label, unpredictable behavior, inadequate error guidance |
| **R** Robust | ARIA misuse, invalid HTML, works in one browser only |

---

## Applying KART

For keyboard-specific findings:

| Letter | Failure |
|--------|---------|
| **K** | Element not reachable via Tab at all |
| **A** | Element reachable but screen reader announces nothing useful |
| **R** | Tab order is illogical (jumps around the page) |
| **T** | Focus escapes a modal, or doesn't return after modal closes |

---

## Oracles

- All interactive elements operable via keyboard alone
- Visible focus indicator on every focused element
- All images have appropriate alt text
- All form fields have programmatic labels
- All error messages are text-based and associated with their fields
- No focus traps that prevent Tab from leaving a component
- Heading hierarchy is logical and present
- ARIA roles and properties are used correctly
- Text at 200% zoom is still readable and functional

---

## Finding IDs

Use prefix `A-` (e.g., A-001). Include:
- **WCAG criterion** violated (e.g., WCAG 2.1 AA — 1.1.1 Non-text Content)
- **POUR principle** affected
- **Element/component** and location
- **Reproduction steps** including keyboard sequence used

---

## Severity guide

| Severity | Examples |
|----------|---------|
| **Critical** | Entire page not keyboard accessible, focus permanently trapped |
| **High** | WCAG A violation (alt text missing, form field unlabeled, keyboard trap) |
| **Medium** | WCAG AA violation (contrast failure, missing heading structure) |
| **Low** | Best-practice violation (suboptimal but not blocking), informational |
| **Info** | WCAG AAA consideration, enhancement recommendation |

---

## Screen reader simulation note

True screen reader testing requires a real AT (NVDA, JAWS, VoiceOver). This skill simulates AT behavior via:
- Browser accessibility tree (snapshot) — reveals name, role, state of elements
- Focus order testing — reveals navigation experience
- ARIA attribute inspection — reveals what AT would announce

Findings from this skill should be considered **indicative** of real AT issues, not confirmed AT failures. Recommend AT testing for critical A-severity findings.

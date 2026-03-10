# Skill: Exploratory Testing (General + Router)

Handles broad/unclear scope with time-boxed multi-dimension exploration. Also routes to specialized skills when a clear focus is detected mid-session.

---

## Scope

**In scope:**
- General exploration of any feature or page
- Happy-path verification
- Obvious functional, security, and accessibility checks
- Discovering what areas deserve deeper investigation

**Out of scope:**
- Deep WCAG audit (route to accessibility-testing)
- Targeted attack surface testing (route to security-testing)
- Detailed performance profiling (route to performance-testing)
- Formal charter planning (route to charters-creation)

---

## Pre-session checklist

- [ ] `TARGET_URL` confirmed
- [ ] Auth performed (see auth-detection.md)
- [ ] Baseline screenshot captured
- [ ] Report directory created
- [ ] Primary heuristic selected (default: SCOUTED for session framing, then FEW HICCUPPS per area)
- [ ] Oracles defined: "The application should [load correctly / function as labeled / protect user data / be keyboard-operable]"

---

## Routing rule (apply before executing)

If user's intent maps clearly to a specialized skill, load that skill instead:

| Intent signals in prompt | Route to |
|--------------------------|---------|
| "security", "xss", "injection", "auth bypass", "idor" | security-testing |
| "accessibility", "a11y", "wcag", "keyboard", "screen reader" | accessibility-testing |
| "performance", "slow", "load time", "console errors" | performance-testing |
| "functional", "flow", "form validation", "bug in" | functional-testing |
| "plan", "charters", "what should I test" | charters-creation |

If no clear signal → execute this skill's exploration loop below.

---

## Execution: Quick exploration pattern (15 minutes)

Divide the session into 5 segments. Adjust time per segment based on what you find.

### Segment 1 — Setup and baseline (2 min)

1. Navigate to `TARGET_URL` (post-auth if applicable).
2. Take baseline screenshot.
3. Snapshot the page: identify primary navigation, main content areas, interactive elements.
4. Note in Activity Log: page structure, any immediate visual anomalies.
5. Define 3 oracles for this session (what "correct" looks like for this app).

### Segment 2 — Functional spot-check (5 min)

Apply **SFDPOT** — one probe per letter:

- **S (Structure)**: Is navigation complete? Are all expected sections present?
- **F (Function)**: Click the primary CTA or feature. Does it work?
- **D (Data)**: Enter a boundary value in a visible input field. Handle as expected?
- **P (Platform)**: Resize to mobile viewport. Layout holds?
- **O (Operations)**: Click something twice rapidly. Any duplicate submission or error?
- **T (Time)**: Is any time-sensitive UI visible (session timer, scheduled items)? Behaves correctly?

Write a finding for each failure. Mark untested letters as `NT`.

### Segment 3 — Security spot-check (3 min)

Apply **STRIDE** — focused on the top 2–3 most likely threats for this type of app:

- Try accessing a URL with a modified ID parameter (`?id=1` → `?id=2`).
- Enter `<script>alert(1)</script>` in the most prominent input field.
- Check if sensitive data (tokens, emails, internal IDs) appears in the URL bar.
- Look at network requests: any 401/403? Any sensitive data in plaintext?

Write a finding for each confirmed or suspected issue. Mark untested STRIDE letters as `NT`.

### Segment 4 — Accessibility spot-check (3 min)

Apply **KART**:

- **K**: Tab through the page. Can all interactive elements be reached?
- **A**: Hover over key icons/buttons — do they have visible tooltips or labels?
- **R**: Is the focus order logical (left→right, top→bottom)?
- **T**: Open a modal/dialog if present. Does focus stay inside? Return on close?

Apply **POUR** quick check:
- Are all images non-decorative? Do they have alt text?
- Is text contrast visually sufficient?
- Are form fields labeled?

Write a finding for each WCAG AA violation. Mark NT where untested.

### Segment 5 — Performance spot-check (2 min)

Apply **RAIL**:

- **L**: Open DevTools / check network panel. Note: any requests > 3s? Any 4xx/5xx?
- **R**: Click the most important button. Was there immediate visual feedback?
- Check console: any errors logged on page load or interaction?

Write a finding for each performance or error issue.

---

## Mid-session routing rule

If during exploration you find a significant issue in one area, consider:

- If 3+ security issues found → note "recommend focused security-testing session" in Session Summary.
- If 3+ a11y issues found → note "recommend focused accessibility-testing session".
- Do not abandon the current session — complete the full 15 minutes; route recommendation goes in Session Summary.

---

## Oracles for this skill

- Page loads without console errors
- Primary user actions complete without errors
- No obvious XSS reflection visible in the UI
- All interactive elements are keyboard-reachable
- No 4xx/5xx errors in network requests on page load
- Navigation behaves consistently across pages
- Data entered is handled without crashes or data loss

---

## Finding IDs

Use prefix `E-` (e.g., E-001, E-002) for findings from this skill.

---

## Session summary requirements

In addition to standard report-templates.md summary:
- List 2–3 recommended follow-up sessions (with suggested skills and focus areas)
- Rate overall quality signal: **Green** (no critical/high), **Amber** (1–2 high), **Red** (critical or 3+ high)

# Shared: Testing Heuristics Reference

All heuristic definitions live here. Skills reference these by name — they do not redefine them.

**Token efficiency — load only what your skill needs:**

| Skill | Read these sections |
|-------|-------------------|
| exploratory-testing | Heuristic execution contract, SFDPOT, STRIDE, KART, POUR, RAIL, SCOUTED, FEW HICCUPPS |
| functional-testing | Heuristic execution contract, SFDPOT, BINMEN, Count, EP+BVA |
| security-testing | Heuristic execution contract, STRIDE, VADER, OWASP WSTG, POISED, CIA |
| accessibility-testing | Heuristic execution contract, POUR, KART, WCAG AA hot-path |
| performance-testing | Heuristic execution contract, RAIL, Starvation, HICCUPPS |
| charters-creation | Heuristic execution contract only (full heuristics loaded per charter's assigned skill) |

---

## Heuristic execution contract (all skills)

1. Select **one primary heuristic** per session (or one per skill segment in exploratory sessions).
2. Define **oracles** (what "correct" looks like) before probing.
3. Execute **at least one probe per heuristic letter/dimension**.
4. Mark untested dimensions as `NT` with a brief reason.
5. Convert heuristic failures immediately to findings using report-templates.md format.

---

## Functional testing heuristics

### SFDPOT — Broad functional coverage

| Letter | Dimension | What to probe |
|--------|-----------|---------------|
| **S** | Structure | Is the UI layout correct? Navigation present? Page sections render? |
| **F** | Function | Do features do what they claim? Does the primary action work? |
| **D** | Data | Does the feature handle expected and unexpected data correctly? |
| **P** | Platform | Does it work across browsers, viewports, screen sizes? |
| **O** | Operations | What happens under concurrent use, rapid clicks, slow network? |
| **T** | Time | Date/time handling, session expiry, timeouts, scheduling |

### BINMEN — Input and boundary testing

| Letter | Dimension | What to probe |
|--------|-----------|---------------|
| **B** | Boundary | At and just beyond min/max limits |
| **I** | Invalid | Wrong type, wrong format, out-of-range values |
| **N** | NULL | Empty fields, null values, missing required data |
| **M** | Method | Different ways to trigger the same action (click, keyboard, drag) |
| **E** | Empty | Zero state, empty lists, empty search results |
| **N** | Negative | Actions that should be blocked (unauthorized, out-of-order, etc.) |

### Count — Cardinality testing

| Count | Test |
|-------|------|
| 0 | Zero items — empty state renders correctly |
| 1 | Single item — no plural text, no pagination |
| Many | 2, 3, 10, 100+ — pagination, overflow, performance |
| Max | At or beyond stated limit — error handled gracefully |

### EP+BVA — Equivalence Partitioning + Boundary Value Analysis

- Divide inputs into equivalence classes (valid / invalid / edge).
- Test one value from each class.
- Test values at boundaries: exactly at, one below, one above.

---

## Security testing heuristics

### STRIDE — Threat modeling

| Letter | Threat | Probe |
|--------|--------|-------|
| **S** | Spoofing | Can I pretend to be another user? Forge identity? |
| **T** | Tampering | Can I modify data I shouldn't? Bypass validation? |
| **R** | Repudiation | Are actions logged? Can I deny taking an action? |
| **I** | Info Disclosure | Is sensitive data exposed in responses, URLs, error messages? |
| **D** | Denial of Service | Can I exhaust resources with malformed or repeated input? |
| **E** | Elevation of Privilege | Can a low-privilege user access high-privilege features? |

### VADER — Web attack surface

| Letter | Dimension | Probe |
|--------|-----------|-------|
| **V** | Verbs | Are HTTP verbs restricted correctly? Can PUT/DELETE be abused? |
| **A** | Authentication | Is auth enforced on all endpoints? Broken auth flows? |
| **D** | Data | Is sensitive data in transit encrypted? Exposed in logs/errors? |
| **E** | Errors | Do error messages reveal stack traces, paths, versions? |
| **R** | Responsiveness | Rate limiting present? Does repeated input cause server errors? |

### OWASP WSTG — Key categories

| Category | What to test |
|----------|-------------|
| **IDOR** | Access object IDs directly (change `?id=123` to `?id=124`) |
| **XSS** | Reflected: `<script>alert(1)</script>` in inputs/URL params; Stored: payloads saved then rendered |
| **CSRF** | Are state-changing requests protected with CSRF tokens? |
| **Auth bypass** | Direct URL access without login, JWT manipulation, cookie tampering |
| **Injection** | SQL: `' OR 1=1--`; Command injection: `; ls /`; Template injection: `{{7*7}}` |
| **Open redirect** | `?redirect=https://evil.com` |
| **Sensitive data** | Tokens, credentials, PII in URLs, responses, localStorage, network logs |
| **Security headers** | Check: CSP, X-Frame-Options, HSTS, X-Content-Type-Options |
| **CORS** | Overly permissive CORS (`Access-Control-Allow-Origin: *` on authenticated endpoints) |

### POISED — Probe design checklist

| Letter | Check |
|--------|-------|
| **P** | Parameters: all query/body params fuzzed? |
| **O** | Output: all outputs sanitized/encoded? |
| **I** | Interoperability: what happens on unexpected Accept headers, encodings? |
| **S** | Security: is the feature protected end-to-end (not just UI)? |
| **E** | Errors: are error paths handled securely (no info leakage)? |
| **D** | Data: is sensitive data handled according to least-privilege? |

### CIA — Impact framing for severity

| Dimension | Critical if | High if | Medium if |
|-----------|------------|---------|-----------|
| **Confidentiality** | Any user can read another user's data | Own historical data exposed | Non-sensitive data exposed |
| **Integrity** | Any user can modify another user's data | Can corrupt own data | Can cause incorrect display |
| **Availability** | Service brought down by single request | Feature unavailable for a user | Degraded but functional |

---

## Accessibility testing heuristics

### POUR — WCAG foundational principles

| Letter | Principle | Key checks |
|--------|-----------|-----------|
| **P** | Perceivable | Alt text on images, captions on video, color not sole differentiator, text resize |
| **O** | Operable | All functions keyboard-accessible, no keyboard trap, skip links, sufficient time |
| **U** | Understandable | Clear labels, consistent navigation, error identification, instructions |
| **R** | Robust | Valid HTML, ARIA used correctly, works with assistive technology |

### KART — Focus and keyboard patterns

| Letter | Check |
|--------|-------|
| **K** | Keyboard: every interactive element reachable by Tab/Shift+Tab |
| **A** | Announced: screen reader announces element name, role, state correctly |
| **R** | Reachable: focus order is logical and follows visual order |
| **T** | Trapped: focus does not escape modals/dialogs; focus returns correctly on close |

### WCAG AA hot-path checks

| Rule | Check |
|------|-------|
| **1.1.1** | All non-text content has text alternative |
| **1.3.1** | Semantic structure (headings, lists, tables used correctly) |
| **1.4.3** | Text contrast ≥ 4.5:1 (3:1 for large text) |
| **1.4.4** | Text resizes to 200% without loss of content |
| **2.1.1** | All functionality operable via keyboard |
| **2.4.3** | Focus order is meaningful |
| **2.4.6** | Headings and labels are descriptive |
| **3.2.1** | No context change on focus alone |
| **3.3.1** | Errors are identified and described in text |
| **4.1.2** | Name, role, value programmatically determinable for all UI components |

---

## Performance testing heuristics

### RAIL — User-centric performance model

| Phase | Target | What to measure |
|-------|--------|----------------|
| **R** Response | < 100ms for tap/click feedback | Time from user action to visual response |
| **A** Animation | 60fps (16ms/frame) | Scroll, transitions, drag — frame drops? |
| **I** Idle | 50ms max blocking tasks | Long tasks blocking main thread |
| **L** Load | < 1s time-to-interactive (mobile 3G: < 5s) | First contentful paint, LCP, TTI |

### Starvation — Main-thread pressure

| Pattern | Test |
|---------|------|
| Rapid click | Click the same button 10x in quick succession |
| Scroll burst | Fast scroll a long list/page |
| Input flood | Type 200 characters rapidly in a search field |
| Concurrent | Open 3+ tabs of the same app, perform actions |

### HICCUPPS — Consistency oracles

| Letter | Consistency type | Check |
|--------|-----------------|-------|
| **H** | History | Slower than last time? Regression? |
| **I** | Image | Looks different than screenshots/mockups? |
| **C** | Claims | Slower than documented SLA? |
| **C** | Comparable | Slower than competitor/baseline? |
| **U** | User | Perceptibly slow to a real user? |
| **P** | Purpose | Too slow to be useful for the feature's goal? |
| **P** | Product | Inconsistent with other parts of the same product? |
| **S** | Standards | Violates web perf best practices (LCP > 2.5s, CLS > 0.1)? |

---

## Exploratory testing meta-heuristics

### SCOUTED — Session charter framing

| Letter | Question |
|--------|---------|
| **S** | Scope: what is included and excluded? |
| **C** | Coverage: which areas / user types? |
| **O** | Oracles: what does "correct" look like? |
| **U** | Unknowns: what do we not know yet? |
| **T** | Time: how long is this chunk? |
| **E** | Evidence: what will we capture? |
| **D** | Dependencies: auth, data, environment needed? |

### FEW HICCUPPS — General test oracles (James Bach / Michael Bolton)

The system under test should be consistent with:
- **F**amiliar products (comparable apps)
- **E**xplained purpose (stated goals)
- **W**ishes (user needs/expectations)
- **H**istory (previous behavior)
- **I**mage (branding, visual claims)
- **C**omparable products
- **C**laims (documentation, specs)
- **U**ser expectations
- **P**roduct (other parts of the same system)
- **P**urpose (the feature's job to be done)
- **S**tandards (laws, RFCs, WCAG, OWASP)

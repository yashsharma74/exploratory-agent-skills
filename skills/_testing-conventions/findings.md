# Testing Conventions — Findings

Universal finding conventions that apply across **every** testing skill, with no per-skill overrides. Each skill's own `SKILL.md` may add **additional required fields** for that domain (e.g., WCAG Criterion for accessibility), but it does not override or restate the rules below.

---

## ID Format

| Rule | Specification |
|---|---|
| Format | `NNN` — three-digit zero-padded sequential number, no prefix |
| Range | Starts at `001`, increments by 1 |
| Reuse | No reuse within a session |
| Stability | Stable across continuations — next number tracked in `session.md` |
| Scope identifier | Comes from the session folder (`exploratory-reports/<timestamp>-<skill>-<feature>/`), not from the ID itself |

Finding filenames: `001.md`, `002.md`, `003.md`. The session metadata identifies which skill produced them.

---

## Severity Scale

Every finding uses this five-level scale:

| Severity | Criteria | Examples |
|---|---|---|
| **Critical** | Data loss, security breach, complete feature failure, regulatory violation, or billing corruption affecting real users | Auth bypass; PII exposure; checkout completely broken; regulatory non-compliance |
| **High** | Core feature broken for a significant user segment; severe UX failure; data integrity at risk; business-critical path degraded | Form silently submits empty data; primary CTA fails on mobile; duplicate charge on double-submit |
| **Medium** | Partial feature failure; confusing or misleading UX; edge case with real-world occurrence; validation gap not causing data loss | Error message describes the wrong field; validation fires on the wrong trigger |
| **Low** | Minor UX inconsistency; cosmetic issue with no functional impact; off-by-one in non-critical display | Plural/singular label mismatch; tooltip text slightly outdated |
| **Info** | Observation worth tracking but not a defect; missing documentation; ambiguous acceptance criteria | Help text link returns 404; no spec for empty state behavior |

**Approved values only:** `Critical`, `High`, `Medium`, `Low`, `Info`. Severity reflects user/business impact, not technical complexity.

No skill overrides this scale. A skill may add an **additional** classification field (e.g., accessibility's `User Impact: Blocked task / Severe friction / Minor friction`) alongside severity, but every finding must still carry one of the five severity values.

### Decision tree

Walk these questions top to bottom; the first **yes** determines the severity.

1. **Critical** — Would a real user experience data loss, money loss, security breach, or regulatory exposure if this shipped today?
   - Auth bypass → Critical
   - PII visible to wrong user → Critical
   - Payment double-charged → Critical
   - Feature 100% broken on the dominant supported browser → Critical
2. **High** — Does a meaningful user segment lose access to a core feature or experience severe UX failure that the user cannot work around?
   - Login fails for one supported browser → High
   - Submit silently creates malformed records → High
   - Mobile users cannot complete checkout (but desktop works) → High
3. **Medium** — Is the feature partially broken or confusingly worded, but the user can work around it?
   - Validation error blames the wrong field → Medium
   - Edge case (max length) accepts one char over → Medium
   - State transition allowed that shouldn't be (but easy to detect/undo) → Medium
4. **Low** — Is this a cosmetic or off-by-one issue with no functional impact?
   - Pluralization wrong ("1 items") → Low
   - Stale tooltip text → Low
   - Hover state missing on one browser → Low
5. **Info** — Is this an observation worth tracking but not a defect?
   - Documentation gap → Info
   - Inconsistency worth aligning on but not strictly wrong → Info
   - Help link returns 404 (depending on prominence — may be Low instead) → Info

### Worked examples — same scenario, different severities

A login form is the scenario. Different observed behaviors:

| Observed behavior | Severity | Reason |
|---|---|---|
| Empty submit auto-creates a session under a fictional user account | Critical | Auth bypass — data integrity + security breach |
| Empty submit shows "Network error" instead of validation message | Medium | Misleading UX but user can re-attempt with valid input |
| Empty submit shows validation error but the error appears 3s after submit | Low | Cosmetic delay; not blocking |
| Empty submit shows error but the error text has a typo ("usrname is required") | Low | Cosmetic |
| Empty submit shows error in red on a red background (contrast 2:1) | Medium | Confusing UX; user may not see the error. (Note: also a `WCAG 1.4.3` finding for accessibility.) |
| Empty submit fails silently, no error shown anywhere | High | Core feature broken; user is stuck without recourse |

### How to NOT decide severity

- **Don't use technical complexity.** A one-line fix can still be Critical if user impact is severe.
- **Don't use difficulty of finding.** A hard-to-find Critical is still Critical.
- **Don't average with frequency.** Frequency is implicit in "affecting real users" — but rare-but-severe (e.g., race condition leading to wrong-user data exposure) is still High/Critical.
- **Don't downgrade because "it's only a demo".** Severity reflects the impact *if the behavior shipped to production*.

---

## Write Each Finding Immediately

A finding file is written to disk the moment the failure is observed. Do not batch findings or write them all at session close.

---

## Recommendation Must Be Actionable

Every finding's `## Recommendation` section must describe the specific behavior change needed.

| Acceptable | Not acceptable |
|---|---|
| "Add server-side required-field validation for the `name` field" | "Fix the bug" |
| "Encode `<script>` tags in error messages before rendering" | "Sanitize input" |
| "Return 403 when the requesting user does not own the resource" | "Check authorization" |

---

## Report Only Reproducible Behaviors

Do not write a finding for an unverified suspicion. Reproduce the failure at least once with a known sequence of steps before writing the finding file.

Some skills layer a stricter reproducibility requirement on top — for example, security findings must include payload, context, and exploit path. Skills document such extensions in their own `SKILL.md`.

---

## Auto-Detection vs Verified Findings

Automated probes (regex matches on snapshots, console scrapes, count comparisons) **detect candidates**, they do not prove findings. Treat detection signals and verified findings as two distinct layers:

| Signal strength | What to write | Example |
|---|---|---|
| **Weak / heuristic** — naive grep matched, count drifted, suspicious pattern | `log-audit.sh DATA "candidate <description> — investigate"` | "candidate XSS — `<script>` appears in snapshot tree (investigate whether it's executed or just textbox value)" |
| **Verified** — reproduced with explicit steps, oracle named, behavior matches the rule's FAIL condition | `fail-check.sh` (which writes `CHECK FAIL` + finding) | After running `playwright-cli eval` to confirm `alert()` actually fired: `fail-check.sh ... Critical "Reflected XSS via search input"` |

The wrong pattern (do not do this):

```bash
if grep -q "<script>" "$snapshot"; then
  fail-check.sh "$DIR" "security-XSS-01" Critical "Reflected XSS"   # ← FALSE POSITIVE LIKELY
fi
```

The right pattern:

```bash
if grep -q "<script>" "$snapshot"; then
  log-audit.sh "$DIR" DATA "candidate XSS reflection — $snapshot line N"
  # Now verify:
  ALERT_FIRED=$(playwright-cli eval "() => document.querySelector('[role=alertdialog]') ? 'yes' : 'no'" | ...)
  if [ "$ALERT_FIRED" = "yes" ]; then
    fail-check.sh "$DIR" "security-XSS-01" Critical "Reflected XSS — alert() fired"
  else
    log-audit.sh "$DIR" DATA "candidate XSS — alert() did not fire; likely safe (textbox value reflection)"
  fi
fi
```

**Why this matters.** Snapshots are accessibility-tree text representations, not rendered HTML. A `<script>` substring in the snapshot may simply be the `value="<script>…"` attribute of an input — HTML-escaped by the browser, not executed. The expert tester must close the gap between *signal* and *finding* with a real verification step.

### Status field for unverified detections

If you have already written a `CHECK FAIL` + finding before verifying (it happens — auto-pipelines sometimes ship), and verification reveals the finding is unfounded:

1. Set the finding's `status` field to `needs-retest`.
2. Add a `## Verification` section explaining what you checked and why it's a false positive.
3. Append a corrective `SESSION` entry to `audit.log`:
   ```
   log-audit.sh "$DIR" SESSION "<finding-id> — needs-retest after expert verification: <reason>"
   ```
4. **Do not** delete the finding file or decrement the severity counter. Severity reflects "impact if real"; status reflects verification state. The validator enforces this — attempts to mute the counter will fail validation.

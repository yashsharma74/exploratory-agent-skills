# Checking Protocol

How rules from the active skill are applied during navigation and how pass/fail is determined.

---

## Rule Source

The active skill (selected in Phase 1 — Setup) lists its own additional files in its `SKILL.md` Step 1 ("Files"). Web Navigator loads those files in Phase 3 and applies any rules they declare at every relevant step.

A rule file is any markdown file (typically under `references/`) with frontmatter describing the rule and a body describing what to check. Typical rule fields:

| Field | Meaning |
|---|---|
| `title` | Short name of the rule |
| `impact` | CRITICAL / HIGH / MEDIUM / LOW |
| `impactDescription` | Why this matters |
| Criteria | What state the rule checks |
| Correct / Incorrect | Examples of passing and failing behavior |

---

## Protocol

At each navigation step, for each rule loaded from the active skill:

1. **Match** — Identify which rules apply to this step based on the rule's `title`, criteria, and the current page state.

2. **Evaluate** — For each matching rule:
   - Check if the **N/A** condition applies — if so, skip the rule and log as N/A.
   - Check the **PASS** condition — if fully satisfied, the rule passes.
   - Check the **FAIL** conditions — if any is met, the rule fails.
   - Compare the current state against the rule's `Correct` and `Incorrect` examples for guidance.
   - If the result is ambiguous → FAIL (err on the side of reporting).

3. **Record** — Write immediately to disk based on the evaluation:
   - **PASS** → append to `audit.log` now → update `session.md` counters.
   - **FAIL** → append to `audit.log` now → capture snapshot → write finding file (see [`findings.md`](findings.md)) → update `session.md` counters.
   - **N/A** → append to `audit.log` now.

The strict write order on FAIL is documented in [`session.md` — Real-Time Write Policy](session.md#real-time-write-policy).

---

## When No Rules Apply

If no rule in the active skill matches the current step, log the step in `audit.log` but produce no CHECK entry. Web Navigator does not generate rules of its own — it only applies what the active skill provides.

# Findings

One file per failed check, written by `../scripts/write-finding.sh`. Web Navigator owns the file format, location, and write policy. The active skill defines the severity model and any skill-specific required fields.

---

## Writing a finding

Call `write-finding.sh`. Do not hand-write finding files — the script enforces frontmatter, increments the counter, and logs the event:

```bash
RULE="functional-VAL-02" \
LOCATION="Sign Up > Email field" \
STEPS=$'1. Open /signup\n2. Submit with email = "not-an-email"\n3. Observe' \
EXPECTED="Validation error displayed, form not submitted" \
ACTUAL="Form submitted with malformed email; account created" \
EVIDENCE="[02-001-bad-email.png](../evidence/02-001-bad-email.png)" \
RECOMMENDATION="Add server-side RFC-5322 validation for the email field" \
scripts/write-finding.sh "$SESSION_DIR" High "Email field accepts malformed addresses"
```

The script returns the new finding ID on stdout (e.g., `001`).

For skill-specific extra frontmatter (WCAG criterion, WSTG reference, CIA impact, component attribution, User Impact, Type), pass them via the `EXTRA_FIELDS` env var as literal frontmatter lines:

```bash
EXTRA_FIELDS=$'wcag: "WCAG 2.1.1 Keyboard"\nuser_impact: "Blocked task"\ntype: "Keyboard"' \
LOCATION="..." \
... \
scripts/write-finding.sh "$SESSION_DIR" High "Submit button unreachable by keyboard"
```

---

## File location

Each finding is a markdown file in the session's `findings/` folder:

```
exploratory-reports/[session-id]/
└── findings/
    ├── 001.md
    ├── 002.md
    └── 003.md
```

The session folder name carries the skill identifier; finding files use plain sequential numbers (3-digit zero-padded). The numbering is owned by `session.md`'s `Next finding number` field and bumped atomically by `next-id.sh` / `write-finding.sh`.

---

## Frontmatter schema

| Field | Required | Source |
|---|---|---|
| `id` | Yes | Auto-set by `write-finding.sh` |
| `rule` | Yes | Passed via `RULE` env var (the rule, criterion, or check that triggered this) |
| `severity` | Yes | First CLI arg to `write-finding.sh` — must be `Critical` / `High` / `Medium` / `Low` / `Info` |
| `status` | Yes | Auto-set to `open` by the script |
| `timestamp` | Yes | Auto-set by the script (ISO 8601 UTC) |
| Skill-specific extras | Per-skill | Passed via `EXTRA_FIELDS` env var |

---

## Body sections

| Section | Required | Source |
|---|---|---|
| `# Title` | Yes | 3rd CLI arg to `write-finding.sh` |
| `## Location` | Yes | `LOCATION` env var |
| `## Steps to Reproduce` | Yes | `STEPS` env var (newline-separated numbered list) |
| `## Expected` | Yes | `EXPECTED` env var |
| `## Actual` | Yes | `ACTUAL` env var |
| `## Evidence` | Required | `EVIDENCE` env var — relative link to screenshot/snapshot |
| `## Recommendation` | Yes | `RECOMMENDATION` env var |

The script writes `—` for any unsupplied field. Re-edit the file afterward if needed.

Skill-specific body sections (e.g., `## WCAG Criterion`, `## WSTG Reference`, `## CIA Impact`, `## User Impact`, `## Component`, `## Observed Timing`) are added by appending to the file after `write-finding.sh` returns. Each skill's `SKILL.md` lists what to add.

---

## Evidence order on FAIL

The strict order (enforced by following the scripts in sequence):

1. `log-audit.sh CHECK … FAIL` — record the failure in the audit log first.
2. `playwright-cli screenshot --filename=…/evidence/NN-…png` — capture proof.
3. `log-audit.sh EVIDENCE …` — record the capture.
4. `write-finding.sh` — write the finding (which logs SESSION: finding recorded).

The audit log alone tells the full story even if step 4 fails to complete.

---

## Passed checks

Passing checks do **not** generate finding files. They are recorded only in:

1. `log-audit.sh CHECK "<rule> — PASS — <description>"` — appends to `audit.log`.
2. `end-session.sh` recomputes the `Passed` counter in `session.md` at session close.

A minimum of one pass screenshot per session is still required if the evidence level is `text+screenshots` or higher — see [`evidence.md`](evidence.md).

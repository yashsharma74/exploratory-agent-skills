---
name: security-testing
version: "1.0.0"
description: Security-focused exploratory testing for XSS, injection, auth/authz, CSRF, and data exposure. Use when the user asks about security vulnerabilities, wants to probe authentication or authorization, test for injection or XSS, or validate that sensitive data is not exposed.
---

# Security Exploratory Testing

Use this skill when:
- Testing authentication, authorization, session handling, or data exposure
- Probing for XSS, injection, CSRF, or IDOR vulnerabilities
- Auditing a specific attack surface on staging or dev

Do NOT use this skill for:
- Functional-only defects (use `functional-testing`)
- Accessibility or performance-only checks
- Testing against production environments (hard blocked by default)

---

## Workflow

### Step 1: Choose Attack Category

Choose exactly one category for this session (at 25–30 min, a second related category may be added):

- XSS / Injection
- AuthN / Session handling
- AuthZ / IDOR
- CSRF
- Data Exposure
- Misconfiguration

### Step 2: Map the Attack Surface

Before any probes, map the attack surface for the chosen category:

- Inputs, parameters, and headers accepting user-controlled data
- Auth boundaries and trust transitions
- Endpoints that expose or modify sensitive resources

Do not run invasive probes without a clear scope boundary confirmed by the user.

### Step 3: Execute and Persist Per Probe

Probe only within the chosen category and mapped surface. Persist each result to disk before the next probe:

1. Inject test payloads into identified inputs (sanitization and encoding checks).
2. Test AuthN/session controls: logout, timeout, token handling.
3. Test AuthZ: access cross-user resources by manipulating IDs or tokens.
4. Inspect storage, network, console, and URL for sensitive data leakage.
5. Verify each behavior at least once before writing a finding — do not report unverified suspicions.

### Step 4: Write Findings

Each confirmed finding produces a file. Use the universal ID format (sequential `NNN`) and severity scale from the conventions layer.

**Stricter reproducibility (overrides the universal rule):** Security findings must include:

- Exact steps reproducible by the team
- The **payload** used
- The **context** in which the failure occurred (user role, page state, auth tokens)
- The **exploit path** — what an attacker can do
- The **impact** — what data/system is affected

Example:

```
Steps to Reproduce:
1. Log in as user A
2. Navigate to /records/123 (user B's record)
3. Observe: record is visible and editable without authorization

Payload: GET /records/123 (changed ID from 456 to 123)
Context: Authenticated as user A
Exploit path: Any authenticated user can access any other user's record by ID
Impact: Unauthorized data access — Confidentiality breach (IDOR — WSTG-ATHZ-01)
```

**Required additional fields:**

- **WSTG Reference** — every finding maps to an OWASP WSTG test area, format `WSTG-<AREA>-<NN>` (e.g., `WSTG-ATHZ-01`, `WSTG-INPV-01`). Use a stable WSTG version mapping. If no direct WSTG mapping exists, note the closest category.
- **CIA Impact** (mandatory for High/Critical; optional otherwise) — one sentence per affected dimension:
  - **Confidentiality** — does it expose restricted data?
  - **Integrity** — can the attacker alter protected state?
  - **Availability** — can behavior degrade or deny service?

**Finding types:** `XSS` | `Injection` | `AuthN` | `AuthZ` | `CSRF` | `DataExposure` | `Misconfiguration`.

**Severity heuristic:** higher severity if exploitation is low-effort + repeatable + impacts confidentiality/integrity broadly.

### Step 5: Checkpoint and Summary

At every 5-minute checkpoint, log primary heuristic coverage (VADER, POISED, or STRIDE — see `references/heuristics.md`):

```
STRIDE: S,T,I,E tested; R,D=NT
```

Complete the session summary with findings by severity, missed coverage, and continuation prompt.

---

## Time Budget Scaling — Categories

| Time limit | Categories | Probe depth | Coverage expectation |
|---|---|---|---|
| **5 min** | 1 | Surface map + 2–3 targeted probes | One heuristic dimension (e.g., VADER: V only) |
| **10 min** | 1 | Surface map + 4–6 probes covering primary vectors | 2–3 heuristic dimensions |
| **15 min** (default) | 1 | Full probe bundle: all mapped vectors + verification | All applicable heuristic dimensions for the category |
| **20 min** | 1 | Full probes + cross-boundary and chained attack paths | Full heuristic coverage + attack chaining |
| **25–30 min** | 1–2 related | Full probes + inter-category interaction testing | Maximize heuristic coverage; second category only if first is exhausted |

One attack category per session is the default — only at 25–30 min can a second related category be added.

---

## Oracles

- Unauthorized actors cannot access or mutate protected resources.
- Inputs are validated and encoded server-side and cannot alter control flow unexpectedly.
- Sensitive data is not exposed in URL, client storage, logs, or responses.
- Session and state-changing actions enforce expected protections (auth, CSRF, timeout).

---

## Strictness Principles

- Persist after every probe — write each result before the next probe begins. Buffering across probes is not acceptable.
- Only report reproducible behaviors — unverified suspicions must not appear as findings.
- Every finding must include exact steps, payload, context, and exploit path — a description alone is not acceptable.
- Every finding must map to an OWASP WSTG test area — type-only labels are not acceptable.
- High and Critical findings must include a CIA impact statement — severity alone is not acceptable.
- One attack category per session (second only at 25–30 min if the first is exhausted).
- Map the attack surface before any probes — probing without a surface map is not acceptable.
- Do not run invasive probes without the user confirming the scope boundary.

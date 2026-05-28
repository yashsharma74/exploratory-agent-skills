# Security Testing Heuristics

## VADER (Primary option — letter-by-letter)

| Letter | Focus | Probe Example | Expected |
|---|---|---|---|
| V | Verbs | try unsupported HTTP verbs on endpoint | Invalid verbs blocked safely |
| A | Auth | access endpoint with missing/expired auth | Unauthorized access denied |
| D | Data | inspect payload/response for sensitive leakage | Data minimized and protected |
| E | Errors | force failure and inspect error details | No stack traces/internal leakage |
| R | Responsiveness | stress key endpoint with bursts | Stable behavior + controlled rate handling |

## POISED (Primary option — for input/output flows)

| Letter | Focus | Probe Example | Expected |
|---|---|---|---|
| P | Parameters | manipulate IDs/filter params | Server-side validation holds |
| O | Output | inject payload and inspect rendered output | Proper encoding/sanitization |
| I | Interop | vary client context (browser/session/API) | Security controls stay consistent |
| S | Security | check CSRF/session cookie flags | Protective controls present |
| E | Errors | malformed request handling | Safe generic errors |
| D | Data | check storage/log/network residues | No sensitive persistence leakage |

## STRIDE (Threat lens — letter-by-letter)

| Letter | Threat | Probe Example | Expected |
|---|---|---|---|
| S | Spoofing | use another user identifier/token context | Identity checks prevent impersonation |
| T | Tampering | alter request body/header/resource ID | Server validates and rejects tampering |
| R | Repudiation | perform sensitive action then inspect audit trail | Action is attributable and logged |
| I | Info Disclosure | inspect URL/storage/response for sensitive fields | No unauthorized sensitive data exposure |
| D | Denial of Service | burst repeated requests/action spam | Rate limits/throttling prevent degradation |
| E | Elevation of Privilege | non-admin invokes admin-only operation | Access denied; no privilege escalation |

## CIA (Impact lens)

- **Confidentiality:** does it expose restricted data?
- **Integrity:** can attacker alter protected state?
- **Availability:** can behavior degrade/deny service?

Security severity hint: higher severity if exploitation is low-effort + repeatable + impacts confidentiality/integrity broadly.

## OWASP WSTG Example — IDOR (AuthZ)

- **Case:** access another user's object by ID.
- **Probe:** change object ID in URL/API request.
- **Expected:** denial or object scoping to current user.

WSTG usage note: prefer mapping security findings to a WSTG test area/ID for reproducibility and triage continuity.

## Heuristic Selection Order

1. **Primary:** VADER or POISED (based on flow type)
2. **Threat lens:** STRIDE
3. **Impact lens:** CIA

## Coverage Rule

Record tested letters and explicit `NT` letters for the primary heuristic at each checkpoint.
Activity log shorthand: `STRIDE: S,T,I,E tested; R,D=NT`

## Execution Contract

Apply VADER or POISED as a repeatable method, not acronym recall.

1. Define an explicit oracle for each threat before probing (what secure behavior looks like — e.g., access denied, no data leaked).
2. Run at least one concrete probe per tested letter; log observed result immediately.
3. Mark untested letters `NT` with a short reason.
4. Convert any failure immediately into a finding with expected vs actual, WSTG reference, and evidence link.

Probe design pattern: `Goal → Setup → Action → Expected → Observed → Threat (STRIDE) → Evidence`

## Coverage Contract

- Test all letters when feasible; when time is constrained, weight by exposure: `internet-facing` > `privileged action` > `sensitive data`.
- Prioritize by `impact × likelihood` — auth and data exposure letters (A, D in VADER; P, S in POISED) before lower-risk letters.
- Do not claim heuristic completion unless all tested and `NT` letters are explicitly logged.

## Canonical References

- STRIDE: Microsoft threat-modeling guidance (SDL/TMT threat categories).
- OWASP WSTG: versioned web security testing categories/checks — prefer stable version mapping in findings for triage continuity.

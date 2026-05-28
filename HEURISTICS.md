# Heuristics Glossary

Each testing skill anchors to one or more named heuristics. Heuristics are coverage acronyms — each letter is a probe dimension. At each checkpoint, log which letters were **tested** and which are **NT** (not tested, with a reason).

The heuristics span industry-standard frameworks (STRIDE, RAIL, POUR/WCAG) and rapid-software-testing mnemonics (SFDPOT, VADER, POISED, KART). Both styles are valid; the names are conventions, not magic.

---

## Functional (skill: `functional-testing`)

### SFDPOT — coverage dimensions
| Letter | Dimension | Example probe |
|---|---|---|
| **S** | Sequence integrity | Skip a required step; verify the app blocks |
| **F** | Primary feature function | Execute the main action; verify outcome and side effects |
| **D** | Data input handling | Boundary values, empty, malformed, type mismatch |
| **P** | Platform compatibility | Re-run in a different browser/viewport/input method |
| **O** | Operational interruption | Browser back, refresh, deep-link, two-tab race |
| **T** | Time-dependent behavior | Session expiry, time-limited tokens, timezone display |
| *(+E)* | External integration | Simulate 500/503 from an API, expire a token |

Origin: Rapid Software Testing (James Bach / Michael Bolton).

---

## Security (skill: `security-testing`)

### VADER — endpoint-style probes
| Letter | Threat |
|---|---|
| **V** | Verbs (unsupported HTTP methods) |
| **A** | Auth (missing / expired) |
| **D** | Data (sensitive leakage in payload/response) |
| **E** | Errors (stack traces, internal info disclosure) |
| **R** | Responsiveness (rate-limiting, bursts) |

### POISED — input/output flow probes
| Letter | Threat |
|---|---|
| **P** | Parameters (ID/filter manipulation) |
| **O** | Output (XSS, encoding) |
| **I** | Interop (different clients/sessions) |
| **S** | Security controls (CSRF tokens, cookie flags) |
| **E** | Errors (malformed-request handling) |
| **D** | Data (storage/log residues) |

### STRIDE — threat lens (Microsoft SDL)
| Letter | Threat |
|---|---|
| **S** | Spoofing |
| **T** | Tampering |
| **R** | Repudiation |
| **I** | Information disclosure |
| **D** | Denial of service |
| **E** | Elevation of privilege |

### CIA — impact lens
- **Confidentiality** — does it expose restricted data?
- **Integrity** — can the attacker alter protected state?
- **Availability** — can behavior degrade or deny service?

Origin: STRIDE from Microsoft SDL; CIA from classical infosec; VADER/POISED from rapid security testing.

### OWASP WSTG
Every security finding maps to an OWASP Web Security Testing Guide ID (e.g. `WSTG-ATHZ-01` for IDOR, `WSTG-INPV-01` for reflected XSS). The WSTG is the industry-standard catalogue: <https://owasp.org/www-project-web-security-testing-guide/>

---

## Accessibility (skill: `accessibility-testing`)

### POUR — WCAG principles
| Letter | Principle |
|---|---|
| **P** | Perceivable (alt text, contrast, zoom) |
| **O** | Operable (keyboard, no focus trap, sufficient time) |
| **U** | Understandable (clear instructions, predictable behavior, error recovery) |
| **R** | Robust (correct ARIA name/role/value for assistive tech) |

### KART — secondary keyboard/AT probes
| Letter | Focus |
|---|---|
| **K** | Keyboard-only (complete flow without a mouse) |
| **A** | Announced (screen reader reads what's needed) |
| **R** | Reachable (every interactive element via Tab) |
| **T** | Trapped (no permanent focus traps) |

Origin: POUR from the W3C Web Content Accessibility Guidelines (WCAG 2.x AA baseline); KART is a rapid-software-testing supplement.

---

## Performance (skill: `performance-testing`)

### RAIL — user-perceived performance (Google)
| Letter | Focus | Target |
|---|---|---|
| **R** | Response | ~100ms feedback on user actions |
| **A** | Animation | 60fps, frame budget ~16ms (app work ≤10ms) |
| **I** | Idle | Background work stays out of the input path |
| **L** | Load | Interactive within the device/network budget |

### Starvation — main-thread pressure
Rapid tab-switching + typing while network is throttled; verify input stays responsive.

### HICCUPPS — consistency lens
| Check | What it tests |
|---|---|
| **History** | Same flow yields similar timing across runs |
| **Image** | Observed performance matches UX claims |
| **Comparable products** | Comparable competitor sites set a baseline |
| **Claims** | Documented SLAs/promises met |
| **User expectations** | Critical actions feel responsive |
| **Product itself** | One area doesn't dramatically out-/under-perform another |
| **Purpose** | Most-used actions get the most performance budget |
| **Standards** | Web Vitals / RAIL thresholds |

Origin: RAIL from Google; HICCUPPS from Michael Bolton.

---

## Coverage logging — universal format

At every 5-minute checkpoint, log tested + NT letters in this shorthand:

```
<HEURISTIC>: <tested letters> tested; <NT letters>=NT (<reason>)
```

Examples:

```
SFDPOT: S,F,D,O tested; P=NT (single browser only); T=NT (no time-dependent features in scope)
STRIDE: S,T,I,E tested; R,D=NT (no audit trail or rate limit in scope)
POUR:   P,O tested;     U,R=NT (forms not in scope this session)
RAIL:   R,L tested;     A,I=NT (no animations to probe)
```

This format is enforced by `log-audit.sh SESSION "checkpoint — <shorthand>"` — write the shorthand as the message body. The validator does not currently check heuristic coverage, but the format is the contract.

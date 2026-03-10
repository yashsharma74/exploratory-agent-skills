# Skill: Security Testing

Focused, bounded security testing targeting OWASP Top 10, auth/authz flaws, and injection vectors.

---

## Scope

**In scope:**
- Cross-site scripting (XSS) — reflected, stored, DOM-based
- Injection (SQL, command, template, path traversal)
- Authentication and session management flaws
- Authorization / IDOR (Insecure Direct Object References)
- Sensitive data exposure
- Security misconfiguration (headers, CORS, error messages)
- CSRF on state-changing actions

**Out of scope:**
- Network-level attacks (DDoS, packet manipulation)
- Brute-force automation at scale
- Server-side infrastructure attacks
- Exploitation beyond proof-of-concept (this framework tests, not exploits)

**IMPORTANT — Responsible testing rule:**
Only test against systems you own or have explicit written permission to test. Never execute destructive payloads (e.g., payloads that delete data, exfiltrate data, or crash the server). Use proof-of-concept payloads only (e.g., `alert(1)` for XSS, not full exfiltration scripts).

---

## Pre-session checklist

- [ ] `TARGET_URL` confirmed
- [ ] Authorization to test confirmed (own system / explicit permission)
- [ ] Auth performed (see auth-detection.md) — if testing auth bypass, also test from unauthenticated state
- [ ] Report directory created: `exploratory-reports/[timestamp]-security-[feature-slug]/`
- [ ] Attack category selected (see below)
- [ ] Primary heuristic selected: STRIDE (threat modeling) or VADER (attack surface)
- [ ] Oracles defined (see below)

---

## Attack category selection

Pick **one** category per 15-minute session. Do not spread across all categories.

| # | Category | Choose when |
|---|----------|-------------|
| 1 | XSS | App has user input that is rendered back to the browser |
| 2 | Injection (SQL/command/template) | App has search, filters, or dynamic queries |
| 3 | Auth/session | Testing login, logout, session tokens, password reset |
| 4 | Authorization/IDOR | App has resources with IDs (users, orders, files, posts) |
| 5 | Sensitive data exposure | App handles PII, payment data, credentials |
| 6 | Security headers + CORS | General hardening check |
| 7 | CSRF | App has state-changing forms without token protection |

---

## Execution: Attack surface map → focused probes

### Step 1 — Map attack surface (2 minutes)

Navigate the feature. Identify all:
- Input fields (text, number, file, hidden)
- URL parameters (`?id=`, `?search=`, `?redirect=`)
- API endpoints (visible in network tab)
- Actions that change state (POST/PUT/DELETE requests)
- Client-side storage (localStorage, sessionStorage, cookies)

Document in Activity Log.

### Step 2 — Execute focused probes (10 minutes)

Based on selected attack category:

#### Category 1 — XSS

Proof-of-concept payloads (use these only — not exfiltration payloads):
```
<script>alert(document.domain)</script>
<img src=x onerror=alert(1)>
"><svg onload=alert(1)>
javascript:alert(1)
{{7*7}}          ← template injection probe
${7*7}           ← server-side template probe
```

Test in: search boxes, name fields, comment boxes, URL parameters, redirect parameters.

**Oracle**: Payload should be sanitized/encoded in the output. If `alert()` fires or raw tags render → XSS confirmed.

#### Category 2 — Injection

SQL injection probes:
```
'
' OR '1'='1
' OR 1=1--
1 AND 1=2
; DROP TABLE test--   ← note: we observe the response, never execute destructively
```

Template injection probes:
```
{{7*7}}
${7*7}
<%= 7*7 %>
```

Path traversal probes:
```
../../../etc/passwd
..%2F..%2F..%2Fetc%2Fpasswd
```

**Oracle**: Input should be sanitized. Error messages should not contain SQL syntax, file paths, or server details.

#### Category 3 — Auth and session management

Tests:
- **Auth bypass**: access protected URLs directly without logging in (e.g., `/admin`, `/dashboard`, `/api/users`)
- **Session fixation**: note the session token before and after login — it should change
- **Token in URL**: check if auth tokens appear in URL params (leaked in referrer/logs)
- **Logout**: verify session is invalidated after logout (token no longer works)
- **Password reset**: test reset link expiry, one-time use, no enumeration (same response for valid/invalid email)
- **Remember me**: verify the persistent token is secure (httpOnly, Secure, SameSite cookie flags)

**Oracle**: Protected resources require valid auth. Session tokens rotate on login. Logout invalidates tokens.

#### Category 4 — Authorization / IDOR

Tests:
- Find a resource ID in the URL or API response (e.g., `/users/123`, `/orders/456`)
- Increment/decrement the ID — can you access another user's resource?
- Try a resource from user A while logged in as user B
- Attempt admin actions from a regular user account
- Try API endpoints directly with manipulated IDs

**Oracle**: User A cannot access or modify User B's resources. Admin endpoints return 403 for regular users.

#### Category 5 — Sensitive data exposure

Tests:
- Check API responses for fields that shouldn't be returned (passwords, tokens, full card numbers, SSNs)
- Check network requests: is auth happening over HTTPS? (look for HTTP on a secure app)
- Check localStorage and sessionStorage for sensitive values
- Check URL bar: are sensitive values in query parameters?
- Trigger error states: do error messages expose stack traces, file paths, DB schema?
- Check HTML source: are API keys, credentials, or internal URLs in JS files?

**Oracle**: Sensitive data not present in client-accessible locations. Errors give generic messages.

#### Category 6 — Security headers and CORS

Check response headers for:
```
Content-Security-Policy       ← should be present and restrictive
X-Frame-Options               ← should be DENY or SAMEORIGIN
X-Content-Type-Options        ← should be nosniff
Strict-Transport-Security     ← should be present (HSTS)
Referrer-Policy               ← should restrict referrer info
Permissions-Policy            ← should restrict browser features
```

Check CORS:
- Look at XHR/fetch responses: is `Access-Control-Allow-Origin: *` on authenticated endpoints?
- Can the app be embedded in an iframe on a foreign domain?

**Oracle**: Security headers present and correctly configured. CORS policy is restrictive on authenticated endpoints.

#### Category 7 — CSRF

Tests:
- Identify a state-changing form (change password, update profile, delete item)
- Check if a CSRF token is included in the request
- Check if the token is validated server-side (would require observing responses to manipulated requests)
- Check if SameSite cookie attribute is set

**Oracle**: All state-changing requests include and validate anti-CSRF tokens.

---

### Step 3 — Document findings (3 minutes)

For each confirmed issue:
- Take a screenshot showing the evidence
- Write Finding with: steps, expected, actual, payload used (sanitized), recommendation
- Assign STRIDE dimension that applies

---

## Oracles

- Unauthorized access denied (401/403, not 200)
- Input returned to browser is encoded/sanitized
- Sensitive data absent from client-accessible responses
- Auth tokens rotate on login; invalidated on logout
- Error messages are generic (no implementation details)
- HTTPS enforced; cookies have Secure, HttpOnly, SameSite
- Security headers present and non-trivially configured

---

## Finding IDs

Use prefix `S-` (e.g., S-001). Include:
- **Payload used** (for XSS/injection findings): sanitized representation
- **Evidence**: screenshot + network request/response excerpt

---

## Severity guide

| Severity | Examples |
|----------|---------|
| **Critical** | Auth bypass to admin, stored XSS on all users, SQL injection with data extraction |
| **High** | Reflected XSS, IDOR to access other users' data, session token in URL |
| **Medium** | Missing CSRF token (low-value action), verbose error messages, missing security headers |
| **Low** | Autocomplete enabled on password field, non-SameSite cookies, clickjacking with limited impact |
| **Info** | Missing optional security header, minor info disclosure in error message |

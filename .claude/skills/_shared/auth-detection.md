# Shared: Authentication Detection and Handling

All skills use this file to authenticate before testing begins. Auth is performed once per session.

---

## Auth type map

| `AUTH_TYPE` (from command) | Strategy |
|---------------------------|----------|
| `PUBLIC` | Navigate directly; if redirected to login, re-detect |
| `FORM` | Use form-login strategy |
| `SSO` | Use SSO/OAuth strategy |
| `BASIC` | Use HTTP Basic auth strategy |
| `API_KEY` | Inject API key header/param strategy |
| `BEARER` | Inject Bearer token strategy |

---

## Strategy 1 — PUBLIC (no auth)

1. Navigate to `TARGET_URL`.
2. Take a baseline snapshot.
3. If the page is a login form → **re-detect**: switch to FORM strategy and prompt user for credentials.
4. If HTTP 401/403 → inform user: "This site requires authentication. Please re-run with credentials."
5. Otherwise → session is established. Proceed to skill.

---

## Strategy 2 — FORM (username + password login)

**Credentials format:** `login: <email_or_username> / <password>`

**Steps:**

1. Navigate to `TARGET_URL`.
2. If already on a dashboard/app page (cookies from prior session) → session valid, skip login.
3. If redirected to a login page, or if `TARGET_URL` is itself a login page:
   a. Locate the username/email field (look for `type="email"`, `type="text"`, `name="username"`, `name="email"`, `placeholder` containing "email" or "username").
   b. Locate the password field (`type="password"`).
   c. Fill username field with provided credential.
   d. Fill password field with provided password.
   e. Click the submit button (look for `type="submit"`, text "Sign in", "Log in", "Continue").
4. Wait for navigation to complete.
5. **Verify login success**: check for absence of login form, presence of user menu/avatar/account nav, or URL change away from `/login`.
6. If login fails (error message visible, still on login page):
   - Output: "Login failed. Check credentials and try again."
   - Do not proceed with testing.
7. Handle **"Remember me"** checkbox: check it if present (avoids re-auth in continuation).
8. Handle **post-login redirect** (e.g., verify email prompts, terms acceptance):
   - If blocking prompt → describe it to user and pause: "Post-login prompt found: [description]. How should I proceed?"

---

## Strategy 3 — SSO / OAuth

**Credentials format:** `sso via <provider> | <email> / <password>`
**Providers:** google, microsoft, github, okta, auth0, ping, azure, custom (any)

**Steps:**

1. Navigate to `TARGET_URL`.
2. Find the SSO login button. Search for:
   - Text: "Sign in with [Provider]", "Continue with [Provider]", "Log in with [Provider]"
   - Icon/logo of the provider
   - Aria-label containing provider name
3. Click the SSO button.
4. Wait for redirect to the identity provider (IdP).
5. **On the IdP page**, detect the login form:
   - Google: fill email → click Next → fill password → click Next
   - Microsoft/Azure: fill email → click Next → fill password → click Sign in
   - GitHub: fill username → fill password → click Sign in
   - Okta: fill email → fill password → click Sign In
   - Generic/custom: fill first text field (email/username), fill password field, submit
6. Wait for redirect back to the application.
7. Handle **consent/permissions screens** (OAuth consent): click "Allow", "Accept", or "Authorize".
8. Handle **MFA prompts** (see MFA section below).
9. Verify successful return to the application (URL should match `TARGET_URL` domain).
10. If redirect loop or stuck on IdP → output: "SSO redirect issue. The IdP may require additional setup or the credentials are incorrect."

---

## Strategy 4 — HTTP Basic Auth

**Credentials format:** `basic auth: <username> / <password>`

**Steps:**

1. Use the credentials to construct the authenticated URL: `https://username:password@TARGET_HOST/path`
   - URL-encode special characters in username and password.
2. Navigate to the constructed URL.
   - Alternative: if the browser shows a native credential dialog, use `browser_handle_dialog` to fill username and password.
3. Verify page loads successfully (not 401).
4. Store the authenticated URL for all subsequent navigations in this session.
5. If 401 persists → output: "HTTP Basic auth failed. Verify username and password."

---

## Strategy 5 — API Key

**Credentials format:** `api key: <key_value>`

**Steps:**

1. Navigate to `TARGET_URL`.
2. If the app uses API key in URL query param (common pattern): append `?api_key=<key>` or `?token=<key>` to requests.
3. If the app uses API key in a header: use browser evaluate to set default headers, or note that direct header injection is limited in browser context.
4. If the app has a UI login with "API key" field → fill it in.
5. Verify authenticated state (dashboard accessible, no 401).
6. Note: browser-based API key auth is limited. If the app is purely API-driven without a UI, note this in the report and test what is accessible via the browser.

---

## Strategy 6 — Bearer Token

**Credentials format:** `bearer token: <token>`

**Steps:**

1. Navigate to `TARGET_URL`.
2. Use browser evaluate to inject the Authorization header:
   ```javascript
   // This sets the token for XHR/fetch calls from the page
   // Note: cannot override headers for top-level navigation
   ```
3. If the app has a UI field for token entry → fill it.
4. If the app reads a token from localStorage/sessionStorage → inject via evaluate:
   ```javascript
   localStorage.setItem('auth_token', '<token>');
   sessionStorage.setItem('access_token', '<token>');
   ```
5. Reload the page after token injection.
6. Verify authenticated state.

---

## MFA / 2FA handling

**If MFA prompt appears during any login flow:**

### TOTP (authenticator app / time-based code)

If user provided a TOTP secret (format: `mfa totp secret: <BASE32_SECRET>`):
1. Generate current TOTP code using the secret (standard RFC 6238, 30-second window).
2. Fill the MFA code field.
3. Submit.

If user did NOT provide a TOTP secret:
- Pause and output: "MFA code required. Please provide the 6-digit code from your authenticator app."
- Wait for user response, then fill and submit.

### Email / SMS code

- Output: "An MFA code has been sent to your email/phone. Please provide it."
- Wait for user response, then fill and submit.

### Backup code

- If user provided backup codes, use the first unused one.

### "Trust this device" checkbox

- Check it if present to avoid repeated MFA in continuation sessions.

---

## Auth failure escalation

If any auth strategy fails after reasonable attempts (max 2 retries):

1. Take a screenshot of the failure state.
2. Write to report under a "Auth Failure" finding with severity: Blocker.
3. Output: "Authentication failed. Session cannot continue. Check credentials and re-run."
4. Stop the session.

---

## Session verification checkpoint

After any successful login, perform this verification before beginning testing:

- [ ] Current URL is within `TARGET_URL` domain (not stuck on IdP)
- [ ] No login/error page visible
- [ ] At least one navigation element visible (menu, header, dashboard)
- [ ] Console has no auth-related errors (401, 403, token expired)

If verification fails on any point, note it in the Activity Log and investigate before proceeding.

---

## Credentials hygiene in reports

- **Never** write raw passwords, tokens, or API keys in any report file.
- Use `[REDACTED]` in place of credential values.
- Username/email MAY be written in reports for traceability (e.g., "Logged in as admin@example.com").
- Session cookies and tokens visible in network traffic should be noted as `[TOKEN]` in findings.

# Credentials

How sessions acquire and use authentication credentials. Web Navigator does not ship default credentials — the user (or the invoking agent) provides them.

---

## Credential Sources

| Source | How |
|---|---|
| `prompt` | User provides email / password / token / API key directly in the invocation prompt |
| `.env` | Read from the workspace `.env` file. Recognized keys: `USER_EMAIL`, `USER_PASSWORD`, `API_KEY`, `BEARER_TOKEN`, `BASIC_AUTH_USER`, `BASIC_AUTH_PASS` |
| `interactive` | Ask the user when the session needs them — for MFA codes that cannot be pre-supplied, or when the user prefers to type credentials live |
| `invitation` | User provides or generates an invitation / magic link |

If multiple sources are available, prefer the one the user named in the prompt. Otherwise: `prompt` > `.env` > `interactive`.

---

## Supported Auth Patterns

| Pattern | Detection signal in prompt | How Web Navigator handles it |
|---|---|---|
| **None (public)** | No auth keyword | Skip the login flow; proceed directly to `goto`. |
| **Form login** | `login:`, `credentials:` | Locate the login form, fill the email + password fields, submit. |
| **SSO / OAuth** | `sso via X`, `oauth X`, `sign in with X` | Click the matching provider button, follow the redirect, fill provider credentials, return to the app. Pause for MFA if encountered. |
| **HTTP Basic** | `basic auth:`, `http basic:` | Encode in the URL (`https://user:pass@host`) or pre-configure the browser context with `httpCredentials`. |
| **API key / Bearer** | `api key:`, `bearer token:` | Set the appropriate header before the first `goto` and on relevant API requests. |
| **Magic link** | `link:`, `invitation:` | Open the supplied link directly. |
| **MFA / 2FA** | `mfa`, `totp`, `2fa` | If a TOTP secret is supplied (`mfa totp secret: …`), compute and submit the code. Otherwise pause and ask the user for the code when prompted. |

---

## Handling Credentials in Output

- **Never** copy or echo plaintext passwords into session files, audit logs, findings, or screenshots.
- In `audit.log`, use the user's email and the literal `<password redacted>` placeholder.
- When taking screenshots of login screens, ensure password fields are cleared or masked before the screenshot, or skip the screenshot for that frame.
- API keys and bearer tokens follow the same rule — log only the first 4 and last 4 characters: `sk-ab••••••cd`.

---

## Audit Log Entries

After credentials are resolved:

```
[HH:MM:SS] [info] SESSION: credentials — source=<prompt|.env|interactive|invitation>, user=<email or username>
```

After login completes:

```
[HH:MM:SS] [info] AUTH: login complete — user=<email>, method=<form|sso|basic|api_key|bearer|magic_link>
```

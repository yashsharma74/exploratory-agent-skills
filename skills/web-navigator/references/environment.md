# Environment

The user (or invoking agent) supplies the target URL; Web Navigator enforces the production guardrail via `../scripts/check-host.sh`. The script is the rule — call it, don't reimplement the logic.

---

## Production Guardrail

Before every `goto` or navigation command (initial URL **and** redirect targets):

```bash
scripts/check-host.sh "<url>" [.blocked-hosts]
```

Exit codes:
- **0** → allowed; proceed
- **1** → blocked; stop with the printed reason
- **2** → ambiguous; ask the user to confirm and only proceed on explicit `--allow-production` acknowledgement (which must be logged via `log-audit.sh SESSION "production override accepted — <user text>"`)

The script's decision logic:

1. If a project-level blocklist file is supplied and the host is on it → blocked (exit 1).
2. `localhost`, `127.0.0.1`, `0.0.0.0`, `*.local`, `*.localhost` → allowed.
3. IANA-reserved example domains (`example.com`, `example.org`, `example.net`) and well-known public testing playgrounds (`the-internet.herokuapp.com`, `juice-shop.herokuapp.com`, `saucedemo.com`, `demo.playwright.dev`, `playwright.dev`) → allowed.
4. Hostnames containing `staging`, `stage`, `dev`, `development`, `test`, `qa`, `preview`, `sandbox`, `demo`, `review`, `ephemeral` → allowed.
5. Anything else → ambiguous (exit 2).

### Project-specific blocklist

Recommended format — one hostname per line, exact match:

```
app.example.com
api.example.com
example.com
```

Pass the path as the 2nd argument to `check-host.sh`, or set `$BLOCKED_HOSTS_FILE`.

---

## Environment Tiers

| Tier | Typical pattern | Default policy |
|---|---|---|
| Staging | `https://staging.<host>` / `https://<host>-staging.<tld>` | Allowed |
| Development | `https://dev.<host>` / `https://<host>-dev.<tld>` | Allowed |
| Local | `http://localhost:*` / `http://127.0.0.1:*` | Allowed |
| Production | The live host | Ambiguous by default; project blocklist makes it hard-blocked |

---

## Environment Lock

Once selected, the environment is fixed for the session. Do not switch mid-session. If the environment can't be reached (VPN, network), log the failure via `log-audit.sh SESSION "environment unreachable — <reason>"` and stop.

---

## Default Session Inputs

Web Navigator should silently apply these defaults — only ask the user when a value would obviously fail:

| Input | Default |
|---|---|
| Environment | Staging |
| Credential source | `prompt` if supplied, else `interactive` |
| Time limit | 15 minutes |
| Evidence level | `text + screenshots` |
| Browser mode | headless |
| Viewport | desktop (1280×720) |

Ask the user only when:
- The target URL's environment can't be classified by `check-host.sh` (exit 2).
- Credentials are required by the flow but not supplied and not available via `.env`.
- The user explicitly asks to override a default.

Avoid 8-question setup interrogations; the defaults work for most sessions.

---

## Audit Log Entry

After environment is resolved:

```bash
scripts/log-audit.sh "$SESSION_DIR" SESSION "environment — <tier> @ <url>"
```

# Sample Prompts — Explorer Agent

## Public / no-auth websites

```
/explore https://news.ycombinator.com
```

```
/explore https://wikipedia.org  explore search and navigation
```

```
/explore https://github.com/torvalds/linux  focus accessibility
```

```
/explore https://www.bbc.com/news  focus performance
```

```
/explore https://juice-shop.herokuapp.com  focus security
```

---

## Form-based authentication

```
/explore https://app.example.com  login: user@example.com / mypassword
```

```
/explore https://staging.myapp.io  credentials: admin@myapp.io / Passw0rd!  focus security
```

```
/explore https://demo.sentry.io  login: demo@example.com / demo  explore error tracking dashboard
```

```
/explore https://trello.com  login: me@email.com / tpass  explore board creation
```

```
/explore https://app.example.com  login: admin@example.com / pass  explore user management  focus functional
```

---

## SSO / OAuth authentication

```
/explore https://app.example.com  sso via google | testuser@gmail.com / googlepass
```

```
/explore https://gitlab.com  sign in with github | myuser / mytoken  explore CI/CD pipelines
```

```
/explore https://app.company.com  sso via microsoft | user@company.com / corppassword
```

```
/explore https://app.example.com  sso via okta | employee@company.com / oktapass  focus security
```

```
/explore https://app.example.com  oauth github | ghuser / ghtoken  explore settings and integrations
```

---

## HTTP Basic authentication

```
/explore https://protected.example.com  basic auth: admin / secret123
```

```
/explore https://httpbin.org/basic-auth/user/pass  basic auth: user / pass
```

```
/explore https://staging.example.com  http basic: deploy / password  focus performance
```

---

## MFA / 2FA flows

```
/explore https://app.example.com  login: user@example.com / pass  mfa totp secret: JBSWY3DPEHPK3PXP
```

```
/explore https://app.example.com  login: admin@example.com / pass  — I will provide MFA code when prompted
```

---

## API-key gated applications

```
/explore https://api.example.com  api key: sk-abc123  explore developer portal
```

```
/explore https://app.example.com  bearer token: eyJhbGciOiJIUzI1NiJ9...  focus security
```

---

## Focused testing sessions

### Security testing

```
/explore https://juice-shop.herokuapp.com  focus security
```

```
/explore https://app.example.com  login: admin@example.com / pass  focus security xss injection
```

```
/explore https://app.example.com  login: user@ex.com / pass  focus security  idor privilege escalation
```

### Accessibility testing

```
/explore https://gov.uk  focus accessibility wcag 2.1 aa
```

```
/explore https://app.example.com  login: user@ex.com / pass  focus accessibility keyboard navigation
```

```
/explore https://checkout.example.com  focus accessibility  test with screen reader simulation
```

### Performance testing

```
/explore https://amazon.com  focus performance
```

```
/explore https://app.example.com  login: user@ex.com / pass  focus performance  check dashboard load time
```

### Functional testing

```
/explore https://app.example.com  login: user@ex.com / pass  focus functional  explore checkout flow
```

```
/explore https://app.example.com  login: admin@ex.com / pass  focus functional  explore admin panel
```

---

## Charter planning (before testing)

```
/explore https://app.example.com  login: admin@ex.com / pass  plan charters for user management module
```

```
/explore https://app.example.com  login: user@ex.com / pass  plan charters — focus on payment flows
```

---

## Multi-session continuation

```
/explore continue
```

```
/explore continue exploratory-reports/2025-01-15T103000Z-security-checkout/README.md
```

---

## Advanced combinations

```
/explore https://app.example.com  sso via google | user@gmail.com / pass  focus security  test authorization boundaries between user roles
```

```
/explore https://app.example.com  login: admin@ex.com / pass  explore file upload feature  — test boundary: 0 files, 1 file, many files, large file, malicious filename
```

```
/explore https://app.example.com  login: user@ex.com / pass  focus accessibility  specifically test modal dialogs and focus trapping
```

---

## Prompt anatomy

```
/explore <TARGET_URL>  [AUTH]  [FOCUS]  [NOTES]
```

| Part | Examples |
|------|---------|
| `TARGET_URL` | `https://app.example.com` |
| `AUTH` | `login: user@x.com / pass`, `sso via google \| user@g.com / p`, `basic auth: user / pass`, `api key: sk-abc`, _(omit for public sites)_ |
| `FOCUS` | `focus security`, `focus accessibility`, `focus performance`, `focus functional`, `plan charters` |
| `NOTES` | Free text — feature to explore, specific flows, known issues |

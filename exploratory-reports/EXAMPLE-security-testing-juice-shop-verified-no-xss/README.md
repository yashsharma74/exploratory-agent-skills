# Canonical Example #3 — Security Skill + Verification Prevents False Positive

A 5-minute `security-testing` session against `https://juice-shop.herokuapp.com` (OWASP intentionally-vulnerable demo). Demonstrates:

1. **Security skill workflow.** Picked one attack category (XSS/Injection), defined attack surface, ran a targeted probe.
2. **Right-pattern verification.** The XSS probe injected `<iframe src="javascript:window.__XSS_FIRED__=Date.now()"></iframe>` and then *verified* via `playwright-cli eval` whether `window.__XSS_FIRED__` was actually set.
3. **Verification protected against false positive.** The URL contained the payload (URL-encoded) but `__XSS_FIRED__` remained `not-set` and no iframe was injected — modern Juice Shop sanitizes the search query. The probe correctly logged a `DATA` observation (not a finding) and a `CHECK PASS`.

This is the *right way* to do auto-detection security probes — contrast with EXAMPLE #2 where naive grep produced a false positive.

- [`report.md`](report.md) — human-readable report
- [`session.md`](session.md), [`audit.log`](audit.log) — raw artifacts

# Canonical Example #2 — Production Override + False-Positive Handling

A 10-minute `functional-testing` session against `https://www.testgorilla.com` (public marketing site). Demonstrates:

1. **Production guardrail override.** The site classifies as ambiguous (could be production); `ALLOW_PRODUCTION="<justification>"` env var was used with `goto.sh`, and every override is logged to the audit trail with the justification.
2. **Auto-detection false positive.** A naive grep-based XSS probe auto-wrote a Critical finding. Investigation (querying `window.alertsOpen` via `playwright-cli eval`) revealed the signal was actually the user input being echoed in the textbox value — HTML-escaped, not executed.
3. **Status field for unverified findings.** Finding `001` is marked `status: needs-retest` with a `## Verification` section explaining the false positive.
4. **Counter integrity.** The validator caught an attempt to "hide" the false positive by decrementing the Critical counter (severity reflects "impact if real"; status reflects verification state).

See [`report.md`](report.md) for the full human-readable breakdown.

- [`report.md`](report.md) — human-readable report
- [`session.md`](session.md), [`audit.log`](audit.log) — raw artifacts
- [`findings/001.md`](findings/001.md) — the needs-retest finding with `## Verification`

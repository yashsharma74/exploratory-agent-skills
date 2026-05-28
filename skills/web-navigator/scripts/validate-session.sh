#!/usr/bin/env bash
# Validate a session folder for compliance. Exit 0 = pass, 1 = violations.
# Usage:   validate-session.sh <session-dir>

set -uo pipefail

SESSION_DIR="${1:?session dir required}"
ERRORS=0

err() { echo "FAIL: $*"; ERRORS=$((ERRORS+1)); }
ok()  { echo "ok:   $*"; }

# 1. Required files
SESSION_MD="${SESSION_DIR}/session.md"
AUDIT="${SESSION_DIR}/audit.log"
[ -f "$SESSION_MD" ] || { err "session.md missing"; exit 1; }
[ -f "$AUDIT" ]      || { err "audit.log missing"; exit 1; }
ok "session.md and audit.log exist"

# 2. session.md required fields
for field in "Session ID" "Active Skill" "Target URL" "Environment" "Started" "Status" "Next finding number"; do
  grep -qE "^\| ${field} \|" "$SESSION_MD" || err "session.md missing field: ${field}"
done

# 3. audit.log: every line must match the expected format
BAD=$(grep -cvE '^\[[0-9]{2}:[0-9]{2}:[0-9]{2}\] \[(info|debug|warn|error)\] (NAV|ACT|CHECK|EVIDENCE|DATA|SESSION|SNAPSHOT|AUTH): ' "$AUDIT" || true)
BAD=${BAD:-0}
if [ "$BAD" -gt 0 ]; then
  err "audit.log has $BAD malformed line(s)"
else
  ok "audit.log entries are well-formed"
fi

# 4. Each finding file: frontmatter + approved severity
FINDINGS_DIR="${SESSION_DIR}/findings"
if [ -d "$FINDINGS_DIR" ]; then
  COUNT=0
  for f in "$FINDINGS_DIR"/*.md; do
    [ -f "$f" ] || continue
    COUNT=$((COUNT+1))
    NAME=$(basename "$f")
    for field in id severity status timestamp; do
      grep -qE "^${field}: " "$f" || err "finding ${NAME}: missing frontmatter field '${field}'"
    done
    SEV=$(grep -E '^severity: ' "$f" | head -1 | sed 's/^severity: *//')
    case "$SEV" in
      Critical|High|Medium|Low|Info) ;;
      *) err "finding ${NAME}: invalid severity '${SEV}'" ;;
    esac
    # ID in frontmatter must match filename
    ID=$(grep -E '^id: ' "$f" | head -1 | sed 's/^id: *//')
    EXPECTED_ID="${NAME%.md}"
    [ "$ID" = "$EXPECTED_ID" ] || err "finding ${NAME}: frontmatter id '${ID}' doesn't match filename"
  done
  ok "checked ${COUNT} finding file(s)"
fi

# 5. Evidence files must be referenced
EVID_DIR="${SESSION_DIR}/evidence"
if [ -d "$EVID_DIR" ]; then
  EVID_COUNT=0
  for f in "$EVID_DIR"/*; do
    [ -f "$f" ] || continue
    EVID_COUNT=$((EVID_COUNT+1))
    NAME=$(basename "$f")
    REFERENCED=0
    grep -qF "$NAME" "$AUDIT" && REFERENCED=1
    [ "$REFERENCED" = "0" ] && [ -d "$FINDINGS_DIR" ] && grep -rqF "$NAME" "$FINDINGS_DIR" 2>/dev/null && REFERENCED=1
    [ "$REFERENCED" = "1" ] || err "evidence file orphaned: ${NAME}"
  done
  ok "checked ${EVID_COUNT} evidence file(s)"
fi

# 6. Status: must be completed or paused (not active)
STATUS=$(grep -E '^\| Status \|' "$SESSION_MD" | sed -E 's/.*\| *([A-Za-z]+) *\|.*/\1/')
case "$STATUS" in
  completed|paused) ok "Status: ${STATUS}" ;;
  active) err "Status is 'active' — session not finalized (run end-session.sh)" ;;
  *)      err "Unknown status: '${STATUS}'" ;;
esac

# 7. CHECK FAIL count vs finding file count
FAIL_COUNT=$(grep -cE '^\[.*\] \[info\] CHECK: .* — FAIL — ' "$AUDIT" || true)
FAIL_COUNT=${FAIL_COUNT:-0}
FINDING_COUNT=0
[ -d "$FINDINGS_DIR" ] && FINDING_COUNT=$(find "$FINDINGS_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')

if [ "$FAIL_COUNT" -gt 0 ] && [ "$FINDING_COUNT" -eq 0 ]; then
  err "audit.log has ${FAIL_COUNT} CHECK FAIL entr(y/ies) but no finding files exist — every FAIL must produce a finding"
elif [ "$FAIL_COUNT" -ne "$FINDING_COUNT" ]; then
  echo "warn: ${FAIL_COUNT} CHECK FAIL entries vs ${FINDING_COUNT} finding file(s) — verify each failure produced a finding (or document a rollup)"
else
  ok "CHECK FAIL count (${FAIL_COUNT}) matches finding file count"
fi

# 8. Findings (X) counters in session.md must equal actual count in findings/ by severity
if [ -d "$FINDINGS_DIR" ] && [ "$FINDING_COUNT" -gt 0 ]; then
  for sev in Critical High Medium Low Info; do
    ACTUAL=$(grep -l "^severity: ${sev}$" "$FINDINGS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
    REPORTED=$(grep -E "^\| Findings \(${sev}\) \|" "$SESSION_MD" | sed -E 's/.*\| *([0-9]+) *\|.*/\1/')
    REPORTED=${REPORTED:-0}
    if [ "$ACTUAL" != "$REPORTED" ]; then
      err "session.md says Findings (${sev}) = ${REPORTED} but findings/ has ${ACTUAL}"
    fi
  done
  ok "severity counters match finding files"
fi

echo ""
if [ "$ERRORS" -gt 0 ]; then
  echo "VALIDATION FAILED — ${ERRORS} error(s)"
  exit 1
fi
echo "VALIDATION PASSED"

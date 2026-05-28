#!/usr/bin/env bash
# Finalize a session: recompute counters from audit.log, set Status to completed.
# Usage:   end-session.sh <session-dir>
# Prints:  one-line summary.

set -euo pipefail

SESSION_DIR="${1:?session dir required}"
SESSION_MD="${SESSION_DIR}/session.md"
AUDIT="${SESSION_DIR}/audit.log"

[ -f "$SESSION_MD" ] || { echo "ERROR: session.md missing" >&2; exit 1; }
[ -f "$AUDIT" ]      || { echo "ERROR: audit.log missing" >&2; exit 1; }

# Recompute counts (grep returns 0 lines for an empty file, which is fine)
PASSED=$(grep -cE '^\[.*\] \[info\] CHECK: .* — PASS — '  "$AUDIT" || true)
FAILED=$(grep -cE '^\[.*\] \[info\] CHECK: .* — FAIL — '  "$AUDIT" || true)
STEPS=$( grep -cE '^\[.*\] \[info\] NAV: '                 "$AUDIT" || true)
EVID=$(  grep -cE '^\[.*\] \[info\] EVIDENCE: '            "$AUDIT" || true)

PASSED=${PASSED:-0}; FAILED=${FAILED:-0}; STEPS=${STEPS:-0}; EVID=${EVID:-0}

# Apply to session.md
TMP="${SESSION_MD}.tmp.$$"
awk -v passed="$PASSED" -v failed="$FAILED" -v steps="$STEPS" -v evid="$EVID" '
  /^\| Steps executed \|/ { if (match($0, /[0-9]+/)) sub(/[0-9]+/, steps) }
  /^\| Passed \|/         { if (match($0, /[0-9]+/)) sub(/[0-9]+/, passed) }
  /^\| Failed \|/         { if (match($0, /[0-9]+/)) sub(/[0-9]+/, failed) }
  /^\| Evidence files \|/ { if (match($0, /[0-9]+/)) sub(/[0-9]+/, evid) }
  /^\| Status \|/         { sub(/active|paused/, "completed") }
  { print }
' "$SESSION_MD" > "$TMP"
mv "$TMP" "$SESSION_MD"

NOW=$(date -u +"%H:%M:%S")
echo "[${NOW}] [info] SESSION: completed — ${PASSED} passed, ${FAILED} failed, ${STEPS} steps" >> "$AUDIT"

echo "Session ${SESSION_DIR} finalized — steps=${STEPS} passed=${PASSED} failed=${FAILED} evidence=${EVID}"

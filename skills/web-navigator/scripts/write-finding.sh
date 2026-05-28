#!/usr/bin/env bash
# Write a finding file from required CLI args and optional env vars.
# Increments the severity counter in session.md.
# Usage:   write-finding.sh <session-dir> <severity> <title>
# Env:     RULE, LOCATION, STEPS, EXPECTED, ACTUAL, EVIDENCE, RECOMMENDATION, EXTRA_FIELDS
#          EXTRA_FIELDS is appended to frontmatter literally (one line per field).
# Prints:  the new finding ID on stdout (e.g. "001").

set -euo pipefail

SESSION_DIR="${1:?session dir required}"
SEVERITY="${2:?severity required (Critical|High|Medium|Low|Info)}"
TITLE="${3:?title required}"

case "$SEVERITY" in
  Critical|High|Medium|Low|Info) ;;
  *) echo "ERROR: invalid severity '$SEVERITY' (must be Critical|High|Medium|Low|Info)" >&2; exit 1 ;;
esac

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
ID=$("${SCRIPT_DIR}/next-id.sh" "$SESSION_DIR")
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
FINDING_PATH="${SESSION_DIR}/findings/${ID}.md"

{
  echo "---"
  echo "id: ${ID}"
  echo "rule: ${RULE:-—}"
  echo "severity: ${SEVERITY}"
  echo "status: open"
  echo "timestamp: ${TS}"
  if [ -n "${EXTRA_FIELDS:-}" ]; then
    printf '%s\n' "$EXTRA_FIELDS"
  fi
  echo "---"
  echo ""
  echo "# ${TITLE}"
  echo ""
  echo "## Location"
  echo ""
  echo "${LOCATION:-—}"
  echo ""
  echo "## Steps to Reproduce"
  echo ""
  echo "${STEPS:-1. ...}"
  echo ""
  echo "## Expected"
  echo ""
  echo "${EXPECTED:-—}"
  echo ""
  echo "## Actual"
  echo ""
  echo "${ACTUAL:-—}"
  echo ""
  echo "## Evidence"
  echo ""
  echo "${EVIDENCE:-—}"
  echo ""
  echo "## Recommendation"
  echo ""
  echo "${RECOMMENDATION:-—}"
} > "$FINDING_PATH"

# Bump severity counter in session.md
SESSION_MD="${SESSION_DIR}/session.md"
TMP="${SESSION_MD}.tmp.$$"
awk -v sev="| Findings (${SEVERITY}) |" '
  index($0, sev) == 1 {
    if (match($0, /[0-9]+/)) {
      n = substr($0, RSTART, RLENGTH) + 1
      sub(/[0-9]+/, n)
    }
  }
  { print }
' "$SESSION_MD" > "$TMP"
mv "$TMP" "$SESSION_MD"

# Append CHECK and finding-recorded entries to audit.log (caller usually does CHECK separately)
NOW=$(date -u +"%H:%M:%S")
echo "[${NOW}] [info] SESSION: finding recorded — ${ID} (${SEVERITY}) — ${TITLE}" >> "${SESSION_DIR}/audit.log"

echo "$ID"

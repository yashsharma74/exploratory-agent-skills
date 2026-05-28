#!/usr/bin/env bash
# Set a `| Field | ... |` row in session.md to a new value.
# Usage:   set-field.sh <session-dir> "<Field Name>" "<value>"
# Example: set-field.sh "$DIR" "Target URL" "https://example.com"

set -euo pipefail

SESSION_DIR="${1:?session dir required}"
FIELD="${2:?field name required}"
VALUE="${3:?value required}"

SESSION_MD="${SESSION_DIR}/session.md"
[ -f "$SESSION_MD" ] || { echo "ERROR: $SESSION_MD missing" >&2; exit 1; }

# Sanitize value: collapse whitespace, no pipe chars
CLEAN=$(printf '%s' "$VALUE" | tr '\n\r|' '   ' | sed -E 's/  +/ /g; s/ $//; s/^ //')

TMP="${SESSION_MD}.tmp.$$"
awk -v field="$FIELD" -v val="$CLEAN" '
  $0 ~ ("^\\| " field " \\|") {
    print "| " field " | " val " |"
    next
  }
  { print }
' "$SESSION_MD" > "$TMP"
mv "$TMP" "$SESSION_MD"

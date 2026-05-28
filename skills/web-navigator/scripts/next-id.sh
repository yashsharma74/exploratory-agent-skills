#!/usr/bin/env bash
# Return the current next-finding number (3-digit zero-padded) and bump session.md's counter.
# Usage:   next-id.sh <session-dir>
# Prints:  the ID to use NOW (e.g. "001"). After this call, session.md has the bumped value.

set -euo pipefail

SESSION_DIR="${1:?session dir required}"
SESSION_MD="${SESSION_DIR}/session.md"

if [ ! -f "$SESSION_MD" ]; then
  echo "ERROR: session.md not found at $SESSION_MD" >&2
  exit 1
fi

CURRENT=$(grep -E '^\| Next finding number \|' "$SESSION_MD" | sed -E 's/.*\| *([0-9]+) *\|.*/\1/' | tr -d '[:space:]')
if [ -z "$CURRENT" ]; then
  echo "ERROR: could not parse next finding number from $SESSION_MD" >&2
  exit 1
fi

# Strip leading zeros for arithmetic, then re-pad
NEXT_NUM=$((10#$CURRENT + 1))
NEXT=$(printf '%03d' "$NEXT_NUM")

# Update session.md atomically
TMP="${SESSION_MD}.tmp.$$"
awk -v cur="$CURRENT" -v nxt="$NEXT" '
  /^\| Next finding number \|/ { sub(cur, nxt) }
  { print }
' "$SESSION_MD" > "$TMP"
mv "$TMP" "$SESSION_MD"

echo "$CURRENT"

#!/usr/bin/env bash
# Take a screenshot and log the EVIDENCE entry atomically.
# Usage:   screenshot.sh <session-dir> <description> [ref]
# Env:     FINDING_ID  (optional — if set, included in filename for failure evidence)
#          FULL_PAGE   (optional — set to any value for --full-page)
# Prints:  the relative filename (e.g. "02-001-empty-submit-no-error.png")

set -euo pipefail

SESSION_DIR="${1:?session dir required}"
DESCRIPTION="${2:?description required}"
REF="${3:-}"

EVIDENCE_DIR="${SESSION_DIR}/evidence"
mkdir -p "$EVIDENCE_DIR"

# Sanitize description: lowercase, alphanumeric+hyphen only
SLUG=$(printf '%s' "$DESCRIPTION" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')

# Next sequence number: count existing evidence files + 1, zero-padded to 2 digits
COUNT=$(find "$EVIDENCE_DIR" -maxdepth 1 -type f 2>/dev/null | wc -l | tr -d '[:space:]')
NN=$(printf '%02d' $((COUNT + 1)))

# Build filename
if [ -n "${FINDING_ID:-}" ]; then
  FILE="${NN}-${FINDING_ID}-${SLUG}.png"
else
  FILE="${NN}-${SLUG}.png"
fi

FULL_PATH="${EVIDENCE_DIR}/${FILE}"

# Capture
ARGS=()
[ -n "${FULL_PAGE:-}" ] && ARGS+=("--full-page")
if [ -n "$REF" ]; then
  playwright-cli screenshot "$REF" --filename="$FULL_PATH" "${ARGS[@]}" >/dev/null 2>&1
else
  playwright-cli screenshot --filename="$FULL_PATH" "${ARGS[@]}" >/dev/null 2>&1
fi

# Log
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
"${SCRIPT_DIR}/log-audit.sh" "$SESSION_DIR" EVIDENCE "screenshot → ${FILE}"

echo "$FILE"

#!/usr/bin/env bash
# Find an element ref (e.g. "e21") from a playwright-cli snapshot YAML.
# Usage:   find-ref.sh <snapshot.yaml> <role> <accessible-name>
# Example: find-ref.sh snapshots/01-login.yaml button "Login"
# Prints:  the ref ID (e.g. "e21") or exits 1 if not found.

set -euo pipefail

SNAPSHOT="${1:?snapshot file required}"
ROLE="${2:?role required (textbox|button|link|combobox|checkbox|radio|heading|...)}"
NAME="${3:?accessible name required}"

[ -f "$SNAPSHOT" ] || { echo "ERROR: snapshot not found: $SNAPSHOT" >&2; exit 1; }

# Escape regex metachars in name
ESCAPED_NAME=$(printf '%s' "$NAME" | sed -E 's/[][\\.*^$(){}?+|/]/\\&/g')

# Match: optional leading whitespace+dash, role, anything, name (case-insensitive substring), anything, [ref=eN]
# Case-insensitive so callers don't need to guess exact capitalization of accessible names.
REF=$(grep -iE "^[[:space:]]*-?[[:space:]]*${ROLE}[[:space:]].*${ESCAPED_NAME}.*\[ref=e[0-9]+\]" "$SNAPSHOT" \
      | grep -oE 'ref=e[0-9]+' | head -1 | sed 's/ref=//')

if [ -z "$REF" ]; then
  echo "ERROR: no ${ROLE} matching '${NAME}' found in $SNAPSHOT" >&2
  exit 1
fi

echo "$REF"

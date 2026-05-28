#!/usr/bin/env bash
# Append a typed entry to a session's audit.log.
# Usage:   log-audit.sh <session-dir> <type> <message> [level]
# Type:    NAV | ACT | CHECK | EVIDENCE | DATA | SESSION | SNAPSHOT | AUTH
# Level:   info (default) | debug | warn | error
# Example: log-audit.sh exploratory-reports/2026-... NAV "goto /login → page loaded (200)"

set -euo pipefail

SESSION_DIR="${1:?session dir required}"
TYPE="${2:?type required (NAV|ACT|CHECK|EVIDENCE|DATA|SESSION|SNAPSHOT|AUTH)}"
MESSAGE="${3:?message required}"
LEVEL="${4:-info}"

case "$TYPE" in
  NAV|ACT|CHECK|EVIDENCE|DATA|SESSION|SNAPSHOT|AUTH) ;;
  *) echo "ERROR: invalid type '$TYPE'" >&2; exit 1 ;;
esac

case "$LEVEL" in
  info|debug|warn|error) ;;
  *) echo "ERROR: invalid level '$LEVEL'" >&2; exit 1 ;;
esac

AUDIT="${SESSION_DIR}/audit.log"
if [ ! -f "$AUDIT" ]; then
  echo "ERROR: audit.log not found at $AUDIT" >&2
  exit 1
fi

NOW=$(date -u +"%H:%M:%S")
# Collapse embedded newlines/CRs to spaces so each entry is exactly one line
CLEAN=$(printf '%s' "$MESSAGE" | tr '\n\r' '  ' | sed -E 's/  +/ /g; s/ $//')
printf '[%s] [%s] %s: %s\n' "$NOW" "$LEVEL" "$TYPE" "$CLEAN" >> "$AUDIT"

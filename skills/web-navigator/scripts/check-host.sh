#!/usr/bin/env bash
# Production guardrail. Exit 0 = allowed, 1 = blocked, 2 = ambiguous (confirm with user).
# Usage:   check-host.sh <url> [blocked-hosts-file]
# Example: check-host.sh https://staging.example.com
#          check-host.sh https://app.example.com .blocked-hosts

set -euo pipefail

URL="${1:?url required}"
BLOCKED_FILE="${2:-${BLOCKED_HOSTS_FILE:-}}"

HOST=$(printf '%s' "$URL" | sed -E 's|^https?://||; s|/.*$||; s|:.*$||' | tr '[:upper:]' '[:lower:]')

if [ -z "$HOST" ]; then
  echo "ERROR: could not extract hostname from URL: $URL" >&2
  exit 1
fi

# Project-specific blocklist takes precedence
if [ -n "$BLOCKED_FILE" ] && [ -f "$BLOCKED_FILE" ]; then
  if grep -qFx "$HOST" "$BLOCKED_FILE"; then
    echo "BLOCKED: $HOST (matches $BLOCKED_FILE)" >&2
    exit 1
  fi
fi

# Always-allowed locals
case "$HOST" in
  localhost|127.0.0.1|0.0.0.0|*.local|*.localhost)
    echo "ALLOWED: $HOST (local)"; exit 0 ;;
esac

# Always-allowed test/practice sites (well-known, designed for testing)
case "$HOST" in
  example.com|www.example.com|example.org|www.example.org|example.net|www.example.net)
    echo "ALLOWED: $HOST (IANA reserved example domain)"; exit 0 ;;
  the-internet.herokuapp.com|juice-shop.herokuapp.com|www.saucedemo.com|saucedemo.com|demo.playwright.dev|playwright.dev)
    echo "ALLOWED: $HOST (public testing/demo site)"; exit 0 ;;
esac

# Non-production indicator in hostname
if printf '%s' "$HOST" | grep -qE '(^|\.|-)(staging|stage|dev|development|test|qa|preview|sandbox|demo|review|ephemeral)(\.|-|$)'; then
  echo "ALLOWED: $HOST (non-production indicator in hostname)"
  exit 0
fi

echo "AMBIGUOUS: $HOST — could be production. Confirm with user before proceeding." >&2
exit 2

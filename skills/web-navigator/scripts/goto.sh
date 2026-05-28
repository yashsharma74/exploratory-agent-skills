#!/usr/bin/env bash
# Navigate to a URL with guardrail check + NAV log + auto-snapshot.
# Usage:   goto.sh <session-dir> <url> [blocked-hosts-file]
# Prints:  the snapshot filename (relative) on stdout (last line)
# Exits:   0 ok, 1 guardrail blocked, 2 ambiguous host (caller must confirm)

set -eu

SESSION_DIR="${1:?session dir required}"
URL="${2:?url required}"
BLOCKED_FILE="${3:-${BLOCKED_HOSTS_FILE:-}}"

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# 1. Guardrail
set +e
"${SCRIPT_DIR}/check-host.sh" "$URL" "$BLOCKED_FILE" >/dev/null 2>&1
GUARD=$?
set -e
case "$GUARD" in
  0) ;;
  1)
    "${SCRIPT_DIR}/log-audit.sh" "$SESSION_DIR" SESSION "blocked host on goto — $URL" error
    echo "ERROR: $URL blocked by guardrail" >&2
    exit 1
    ;;
  2)
    if [ -n "${ALLOW_PRODUCTION:-}" ]; then
      "${SCRIPT_DIR}/log-audit.sh" "$SESSION_DIR" SESSION "production override accepted — $URL — justification: ${ALLOW_PRODUCTION}" warn
    else
      "${SCRIPT_DIR}/log-audit.sh" "$SESSION_DIR" SESSION "ambiguous host on goto — $URL (awaiting user confirmation)" warn
      echo "WARN: $URL classification is ambiguous — set ALLOW_PRODUCTION='<justification>' to override, or use a clearly non-prod host" >&2
      exit 2
    fi
    ;;
esac

# 2. Navigate (capture output, extract fields with awk for robustness)
RESULT=$(playwright-cli goto "$URL" 2>&1 || true)

PAGE_URL=$(printf '%s\n' "$RESULT" | awk '/Page URL:/ {sub(/.*Page URL: */, ""); print; exit}')
PAGE_TITLE=$(printf '%s\n' "$RESULT" | awk '/Page Title:/ {sub(/.*Page Title: */, ""); print; exit}')
CONSOLE_INFO=$(printf '%s\n' "$RESULT" | awk '/Console:/ {sub(/.*Console: */, ""); print; exit}')

# Log NAV
NAV_MSG="goto $URL → ${PAGE_URL:-(unknown)}"
[ -n "$PAGE_TITLE" ]   && NAV_MSG="$NAV_MSG (\"$PAGE_TITLE\")"
[ -n "$CONSOLE_INFO" ] && NAV_MSG="$NAV_MSG; console: $CONSOLE_INFO"
"${SCRIPT_DIR}/log-audit.sh" "$SESSION_DIR" NAV "$NAV_MSG"

# 3. Auto-snapshot (refs invalidate after goto — this prevents the #1 agent bug)
SNAP_DIR="${SESSION_DIR}/snapshots"
mkdir -p "$SNAP_DIR"

SLUG=$(printf '%s' "$URL" | sed -E 's|^https?://||; s|^[^/]*||; s|^/||' | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')
[ -z "$SLUG" ] && SLUG="root"
COUNT=$(find "$SNAP_DIR" -maxdepth 1 -name "*.yaml" 2>/dev/null | wc -l | tr -d '[:space:]')
NN=$(printf '%02d' $((COUNT + 1)))
SNAP_FILE="${NN}-${SLUG}.yaml"
playwright-cli snapshot --filename="${SNAP_DIR}/${SNAP_FILE}" >/dev/null 2>&1 || true
"${SCRIPT_DIR}/log-audit.sh" "$SESSION_DIR" SNAPSHOT "saved → ${SNAP_FILE}"

echo "${SNAP_FILE}"

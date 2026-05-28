#!/usr/bin/env bash
# Log a CHECK FAIL and write the finding atomically.
# Usage:   fail-check.sh <session-dir> <rule-id> <severity> <title>
# Env:     LOCATION, STEPS, EXPECTED, ACTUAL, EVIDENCE, RECOMMENDATION, EXTRA_FIELDS
#          (same as write-finding.sh — pass body fields here)
# Prints:  the new finding ID on stdout

set -euo pipefail

SESSION_DIR="${1:?session dir required}"
RULE="${2:?rule id required}"
SEVERITY="${3:?severity required}"
TITLE="${4:?title required}"

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# 1. Audit first — establishes the record even if finding write fails
"${SCRIPT_DIR}/log-audit.sh" "$SESSION_DIR" CHECK "${RULE} — FAIL — ${TITLE}"

# 2. Write finding (which also logs SESSION: finding recorded)
RULE="$RULE" "${SCRIPT_DIR}/write-finding.sh" "$SESSION_DIR" "$SEVERITY" "$TITLE"

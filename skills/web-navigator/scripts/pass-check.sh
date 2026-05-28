#!/usr/bin/env bash
# Log a CHECK PASS. Trivial wrapper that pairs symmetrically with fail-check.sh.
# Usage:   pass-check.sh <session-dir> <rule-id> <description>

set -euo pipefail

SESSION_DIR="${1:?session dir required}"
RULE="${2:?rule id required}"
DESCRIPTION="${3:?description required}"

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
"${SCRIPT_DIR}/log-audit.sh" "$SESSION_DIR" CHECK "${RULE} — PASS — ${DESCRIPTION}"

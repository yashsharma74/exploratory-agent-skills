#!/usr/bin/env bash
# Initialize a new session folder + session.md header + empty audit.log.
# Usage:   init-session.sh <skill> <feature> [reports-dir]
# Prints:  session directory path on stdout (last line).
# Example: init-session.sh functional-testing checkout-flow
#          → exploratory-reports/2026-05-27T161000Z-functional-testing-checkout-flow

set -euo pipefail

SKILL="${1:?skill name required (e.g. functional-testing)}"
FEATURE="${2:?feature slug required (lowercase, hyphenated)}"
REPORTS_DIR="${3:-${EXPLORATORY_REPORTS_DIR:-exploratory-reports}}"

TS=$(date -u +"%Y-%m-%dT%H%M%SZ")
SESSION_ID="${TS}-${SKILL}-${FEATURE}"
SESSION_DIR="${REPORTS_DIR}/${SESSION_ID}"

mkdir -p "${SESSION_DIR}/findings" "${SESSION_DIR}/evidence" "${SESSION_DIR}/snapshots"

cat > "${SESSION_DIR}/session.md" <<EOF
# Session: ${FEATURE} — ${SKILL}

## Info

| Field | Value |
|---|---|
| Session ID | ${SESSION_ID} |
| Active Skill | ${SKILL} |
| Target URL | — |
| Environment | — |
| Credentials | — |
| Evidence Level | — |
| Viewport | — |
| Navigation Source | — |
| Time Limit | — |
| Started | ${TS} |
| Status | active |

## Original User Prompt

—

## Refined Prompt

n/a

## Fixtures

| Fixture | Type | Setup Method | Status |
|---|---|---|---|

## Counters

| Metric | Value |
|---|---|
| Steps executed | 0 |
| Rules applied | 0 |
| Passed | 0 |
| Failed | 0 |
| Findings (Critical) | 0 |
| Findings (High) | 0 |
| Findings (Medium) | 0 |
| Findings (Low) | 0 |
| Findings (Info) | 0 |
| Evidence files | 0 |

## Continuation

| Field | Value |
|---|---|
| Last step | — |
| Last finding ID | — |
| Next finding number | 001 |
| Elapsed time | 00:00:00 |
| Resume instruction | Continue session ${SESSION_ID} |
EOF

touch "${SESSION_DIR}/audit.log"
NOW=$(date -u +"%H:%M:%S")
echo "[${NOW}] [info] SESSION: initialized — skill=${SKILL}, feature=${FEATURE}" >> "${SESSION_DIR}/audit.log"

echo "${SESSION_DIR}"

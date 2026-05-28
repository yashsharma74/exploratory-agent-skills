#!/usr/bin/env bash
# Print the standard end-of-session summary block from a finalized session.
# Usage:   summarize-session.sh <session-dir>
# Output:  a markdown block suitable for chat or report inclusion.
# Note:    This formats what's already on disk — it doesn't compute new analysis.

set -eu

SESSION_DIR="${1:?session dir required}"
SESSION_MD="${SESSION_DIR}/session.md"
AUDIT="${SESSION_DIR}/audit.log"

[ -f "$SESSION_MD" ] || { echo "ERROR: $SESSION_MD missing" >&2; exit 1; }
[ -f "$AUDIT" ]      || { echo "ERROR: $AUDIT missing" >&2; exit 1; }

# Extract a field value from session.md (returns empty if missing).
# Uses fixed-string match so regex metacharacters in the field name (e.g. parens
# in "Findings (Low)") are treated literally.
get_field() {
  grep -F "| $1 |" "$SESSION_MD" 2>/dev/null | head -1 | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/,"",$3); print $3}'
}

count_audit() {
  grep -cE "$1" "$AUDIT" 2>/dev/null || true
}

SID=$(get_field "Session ID")
SKILL=$(get_field "Active Skill")
URL=$(get_field "Target URL")
STATUS=$(get_field "Status")
STARTED=$(get_field "Started")
LIMIT=$(get_field "Time Limit")

PASSED=$(count_audit '^\[.*\] \[info\] CHECK: .* — PASS — '); PASSED=${PASSED:-0}
FAILED=$(count_audit '^\[.*\] \[info\] CHECK: .* — FAIL — '); FAILED=${FAILED:-0}
STEPS=$(count_audit '^\[.*\] \[info\] NAV: ');               STEPS=${STEPS:-0}
EVID=$(count_audit '^\[.*\] \[info\] EVIDENCE: ');           EVID=${EVID:-0}

CRIT=$(get_field "Findings (Critical)"); CRIT=${CRIT:-0}
HIGH=$(get_field "Findings (High)");     HIGH=${HIGH:-0}
MED=$(get_field "Findings (Medium)");    MED=${MED:-0}
LOW=$(get_field "Findings (Low)");       LOW=${LOW:-0}
INFO=$(get_field "Findings (Info)");     INFO=${INFO:-0}

FIRST_TS=$(head -1 "$AUDIT" 2>/dev/null | awk -F'[][]' 'NR==1{print $2}')
LAST_TS=$(tail -1 "$AUDIT" 2>/dev/null | awk -F'[][]' 'NR==1{print $2}')

# Top priority findings: list first per Critical, then High. Include status.
top_findings=""
FINDINGS_DIR="${SESSION_DIR}/findings"
if [ -d "$FINDINGS_DIR" ]; then
  for sev in Critical High; do
    for f in "$FINDINGS_DIR"/*.md; do
      [ -f "$f" ] || continue
      if grep -qE "^severity: ${sev}$" "$f" 2>/dev/null; then
        FID=$(awk '/^id:/ {print $2; exit}' "$f")
        FSTATUS=$(awk '/^status:/ {print $2; exit}' "$f")
        FTITLE=$(awk '/^# / {sub(/^# */, ""); print; exit}' "$f")
        top_findings="${top_findings}- ${FID} (${sev}, ${FSTATUS}): ${FTITLE}"$'\n'
        break
      fi
    done
  done
fi
[ -z "$top_findings" ] && top_findings="- (none)"$'\n'

cat <<EOF
### Session Summary — ${SID}

| Metric | Value |
|---|---|
| Skill | ${SKILL} |
| Target | ${URL} |
| Status | ${STATUS} |
| Time limit | ${LIMIT} |
| Started | ${STARTED} |
| First entry | ${FIRST_TS:-—} |
| Last entry | ${LAST_TS:-—} |
| Steps (NAV) | ${STEPS} |
| Checks passed | ${PASSED} |
| Checks failed | ${FAILED} |
| Evidence files | ${EVID} |
| Findings (Critical / High / Medium / Low / Info) | ${CRIT} / ${HIGH} / ${MED} / ${LOW} / ${INFO} |

**Top priority findings:**
${top_findings}
**Session folder:** \`${SESSION_DIR}/\`

To continue: \`Continue session ${SID}\`
EOF

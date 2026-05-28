#!/usr/bin/env bash
# Generate a human-readable report.md from a finalized session.
# Usage:   generate-report.sh <session-dir>
# Output:  writes <session-dir>/report.md
# Prints:  the report path on stdout

set -eu

SESSION_DIR="${1:?session dir required}"
SESSION_MD="${SESSION_DIR}/session.md"
AUDIT="${SESSION_DIR}/audit.log"
FINDINGS_DIR="${SESSION_DIR}/findings"
EVIDENCE_DIR="${SESSION_DIR}/evidence"
REPORT="${SESSION_DIR}/report.md"

[ -f "$SESSION_MD" ] || { echo "ERROR: session.md missing" >&2; exit 1; }
[ -f "$AUDIT" ]      || { echo "ERROR: audit.log missing" >&2; exit 1; }

# Helpers
get_field() {
  grep -F "| $1 |" "$SESSION_MD" 2>/dev/null | head -1 | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/,"",$3); print $3}'
}

count_audit() {
  local n
  n=$(grep -cE "$1" "$AUDIT" 2>/dev/null) || n=0
  echo "${n:-0}"
}

# Severity badge for headings
sev_badge() {
  case "$1" in
    Critical) printf '🔴 Critical' ;;
    High)     printf '🟠 High' ;;
    Medium)   printf '🟡 Medium' ;;
    Low)      printf '🟢 Low' ;;
    Info)     printf '🔵 Info' ;;
    *)        printf '%s' "$1" ;;
  esac
}

# Status badge
status_badge() {
  case "$1" in
    open)         printf '🟥 open' ;;
    mitigated)    printf '🟩 mitigated' ;;
    needs-retest) printf '🟨 needs-retest' ;;
    *)            printf '%s' "$1" ;;
  esac
}

# Metadata
SID=$(get_field "Session ID")
SKILL=$(get_field "Active Skill")
URL=$(get_field "Target URL")
ENV=$(get_field "Environment")
CREDS=$(get_field "Credentials")
EVID_LEVEL=$(get_field "Evidence Level")
VIEWPORT=$(get_field "Viewport")
TIME_LIMIT=$(get_field "Time Limit")
STARTED=$(get_field "Started")
STATUS=$(get_field "Status")
CRIT=$(get_field "Findings (Critical)"); CRIT=${CRIT:-0}
HIGH=$(get_field "Findings (High)");     HIGH=${HIGH:-0}
MED=$(get_field "Findings (Medium)");    MED=${MED:-0}
LOW=$(get_field "Findings (Low)");       LOW=${LOW:-0}
INFO=$(get_field "Findings (Info)");     INFO=${INFO:-0}

PASSED=$(count_audit '^\[.*\] \[info\] CHECK: .* — PASS — ')
FAILED=$(count_audit '^\[.*\] \[info\] CHECK: .* — FAIL — ')
STEPS=$(count_audit '^\[.*\] \[info\] NAV: ')
EVID_COUNT=$(count_audit '^\[.*\] \[info\] EVIDENCE: ')
PASSED=${PASSED:-0}; FAILED=${FAILED:-0}; STEPS=${STEPS:-0}; EVID_COUNT=${EVID_COUNT:-0}

# Mission, scope-guard, scenarios from audit log
MISSION=$(grep -E 'SESSION: mission — ' "$AUDIT" 2>/dev/null | head -1 | sed -E 's/.*mission — //')
SCOPE=$(grep -E 'SESSION: scope-guard — ' "$AUDIT" 2>/dev/null | head -1 | sed -E 's/.*scope-guard — //')
SCENARIOS=$(grep -E 'SESSION: scenarios — ' "$AUDIT" 2>/dev/null | head -1 | sed -E 's/.*scenarios — //')

# Total findings count
TOTAL_FINDINGS=$((CRIT + HIGH + MED + LOW + INFO))

# First/last timestamps
FIRST_TS=$(head -1 "$AUDIT" 2>/dev/null | awk -F'[][]' '{print $2; exit}')
LAST_TS=$(tail -1 "$AUDIT" 2>/dev/null | awk -F'[][]' '{print $2; exit}')

#-------------------------------------------------------------------------------
# Write the report
#-------------------------------------------------------------------------------

{
  echo "# Exploratory Testing Report"
  echo ""
  echo "**Session:** \`${SID}\`"
  echo ""
  echo "---"
  echo ""

  # Mission box
  echo "## Mission"
  echo ""
  if [ -n "$MISSION" ]; then
    echo "> ${MISSION}"
  else
    echo "> (no mission recorded)"
  fi
  echo ""
  if [ -n "$SCOPE" ]; then
    echo "**Scope guard:** ${SCOPE}"
    echo ""
  fi
  if [ -n "$SCENARIOS" ]; then
    echo "**Scenarios planned:** ${SCENARIOS}"
    echo ""
  fi

  # Session info
  echo "## Session Info"
  echo ""
  echo "| Field | Value |"
  echo "|---|---|"
  echo "| Active Skill | \`${SKILL}\` |"
  echo "| Target | ${URL} |"
  echo "| Environment | ${ENV} |"
  echo "| Credentials | ${CREDS} |"
  echo "| Evidence Level | ${EVID_LEVEL} |"
  echo "| Viewport | ${VIEWPORT} |"
  echo "| Time Limit | ${TIME_LIMIT} |"
  echo "| Started | ${STARTED} |"
  echo "| Status | **${STATUS}** |"
  echo ""

  # Outcome
  echo "## Outcome"
  echo ""
  echo "- **Navigation steps:** ${STEPS}"
  echo "- **Checks passed:** ${PASSED}"
  echo "- **Checks failed:** ${FAILED}"
  echo "- **Evidence captured:** ${EVID_COUNT} file(s)"
  echo "- **First entry:** ${FIRST_TS:-—}"
  echo "- **Last entry:** ${LAST_TS:-—}"
  echo ""
  echo "### Findings by severity"
  echo ""
  echo "| 🔴 Critical | 🟠 High | 🟡 Medium | 🟢 Low | 🔵 Info | **Total** |"
  echo "|---|---|---|---|---|---|"
  echo "| ${CRIT} | ${HIGH} | ${MED} | ${LOW} | ${INFO} | **${TOTAL_FINDINGS}** |"
  echo ""

  # Findings detail
  if [ -d "$FINDINGS_DIR" ] && [ -n "$(ls -A "$FINDINGS_DIR" 2>/dev/null)" ]; then
    echo "## Findings"
    echo ""
    for sev in Critical High Medium Low Info; do
      first=true
      for f in "$FINDINGS_DIR"/*.md; do
        [ -f "$f" ] || continue
        grep -qE "^severity: ${sev}$" "$f" 2>/dev/null || continue
        if $first; then
          echo "### $(sev_badge "$sev")"
          echo ""
          first=false
        fi
        FID=$(awk '/^id:/ {print $2; exit}' "$f")
        FSTATUS=$(awk '/^status:/ {print $2; exit}' "$f")
        FRULE=$(awk '/^rule:/ {sub(/^rule: */, ""); print; exit}' "$f")
        FTS=$(awk '/^timestamp:/ {print $2; exit}' "$f")
        FTITLE=$(awk '/^# / {sub(/^# */, ""); print; exit}' "$f")

        echo "#### \`${FID}\` — ${FTITLE}"
        echo ""
        echo "$(status_badge "$FSTATUS") · **Rule:** \`${FRULE}\` · **Discovered:** \`${FTS}\`"
        echo ""
        # Print body sections (skip frontmatter and the # Title line)
        awk '
          BEGIN { in_body = 0 }
          /^---$/ { fm = !fm; next }
          fm { next }
          /^# / && !in_body { in_body = 1; next }
          in_body { print }
        ' "$f"
        echo ""
        echo "---"
        echo ""
      done
    done
  else
    echo "## Findings"
    echo ""
    echo "_No findings recorded._"
    echo ""
  fi

  # Activity timeline (compressed — only key events)
  echo "## Activity Timeline"
  echo ""
  echo "Key events from \`audit.log\` (full log retained in the session folder):"
  echo ""
  awk '
    /SESSION: mission/        { sub(/^/, "- 🎯 "); print; next }
    /SESSION: initialized/    { sub(/^/, "- ▶️  "); print; next }
    /SESSION: scope-guard/    { sub(/^/, "- 🛡️  "); print; next }
    /SESSION: scenarios/      { sub(/^/, "- 📋 "); print; next }
    /SESSION: completed/      { sub(/^/, "- 🏁 "); print; next }
    /SESSION: paused/         { sub(/^/, "- ⏸️  "); print; next }
    /SESSION: resumed/        { sub(/^/, "- ▶️  "); print; next }
    /SESSION: production override/ { sub(/^/, "- ⚠️  "); print; next }
    /SESSION: finding/        { sub(/^/, "- 📝 "); print; next }
    /SESSION: blocked host/   { sub(/^/, "- 🚫 "); print; next }
    /NAV: /                   { sub(/^/, "- 🧭 "); print; next }
    /CHECK: .* PASS /         { sub(/^/, "- ✅ "); print; next }
    /CHECK: .* FAIL /         { sub(/^/, "- ❌ "); print; next }
    /CHECK: .* N\/A /         { sub(/^/, "- ⚪ "); print; next }
    /AUTH: /                  { sub(/^/, "- 🔐 "); print; next }
  ' "$AUDIT"
  echo ""

  # Reproducibility
  echo "## Reproducing the Findings"
  echo ""
  echo "**Environment setup:**"
  echo ""
  echo "1. Open a browser with viewport ${VIEWPORT}."
  echo "2. Navigate to \`${URL}\`."
  if [ -n "$CREDS" ] && [ "$CREDS" != "—" ] && [ "$CREDS" != "none (public site)" ]; then
    echo "3. Authenticate with credentials: \`${CREDS}\`."
  fi
  echo ""
  if [ "$TOTAL_FINDINGS" -gt 0 ]; then
    echo "**For each finding above:**"
    echo ""
    echo "1. Follow the \`## Steps to Reproduce\` section."
    echo "2. Observe the page behavior."
    echo "3. Compare against the \`## Expected\` and \`## Actual\` sections."
    echo "4. Confirm the issue persists, or re-run with the snapshot/screenshot evidence as reference."
    echo ""
    echo "**Evidence files** are linked from each finding above and live in:"
    echo ""
    echo "- \`${SESSION_DIR#./}/evidence/\` — screenshots (\`.png\`) and videos (\`.webm\`)"
    echo "- \`${SESSION_DIR#./}/snapshots/\` — accessibility-tree snapshots (\`.yaml\`)"
    echo ""
  fi

  # Re-run instructions
  echo "## Re-Running This Session"
  echo ""
  echo "Use Web Navigator's continuation protocol from any agent context:"
  echo ""
  echo "    Continue session ${SID}"
  echo ""
  echo "Or start a fresh session against the same target with this skill:"
  echo ""
  echo "    Run ${SKILL} against ${URL}"
  echo ""

  # Footer
  echo "---"
  echo ""
  echo "_This report was generated deterministically from the session's audit log and finding files. The session folder \`${SESSION_DIR#./}/\` contains the full record (\`session.md\`, \`audit.log\`, \`findings/\`, \`evidence/\`, \`snapshots/\`)._"
} > "$REPORT"

echo "$REPORT"

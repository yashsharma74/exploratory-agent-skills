#!/usr/bin/env bash
# Browser tool environment check.
# Run this script — do not read it. Only the output consumes context.

set -euo pipefail

# 1. playwright-cli global
if command -v playwright-cli &>/dev/null; then
  VERSION=$(playwright-cli --version 2>&1)
  echo "playwright-cli: $VERSION (global)"
  exit 0
fi

# 2. npx fallback
if command -v npx &>/dev/null && npx --yes playwright-cli --version &>/dev/null 2>&1; then
  VERSION=$(npx playwright-cli --version 2>&1)
  echo "playwright-cli: $VERSION (npx)"
  echo "USE_NPX=true"
  exit 0
fi

# 3. Nothing found
echo "ERROR: playwright-cli not found globally or via npx."
exit 1

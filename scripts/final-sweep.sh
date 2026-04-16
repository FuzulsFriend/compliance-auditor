#!/usr/bin/env bash
# final-sweep.sh - Phase 8 verification. Run this from the repo root
# AFTER the consolidated fixer finishes. Exits non-zero on any failure.
#
# Usage: ./final-sweep.sh <privacy_page_path> <terms_page_path> <privacy_md> <terms_md>
#
# Example:
#   ./final-sweep.sh \
#     app/app/\(public\)/privacy/page.tsx \
#     app/app/\(public\)/terms/page.tsx \
#     specs/legal/PRIVACY-POLICY.md \
#     specs/legal/TERMS-OF-SERVICE.md

set -u

FAIL=0
PRIV_TSX="${1:-app/app/(public)/privacy/page.tsx}"
TERMS_TSX="${2:-app/app/(public)/terms/page.tsx}"
PRIV_MD="${3:-specs/legal/PRIVACY-POLICY.md}"
TERMS_MD="${4:-specs/legal/TERMS-OF-SERVICE.md}"
FILES=("$PRIV_TSX" "$TERMS_TSX" "$PRIV_MD" "$TERMS_MD")

echo "== compliance-auditor final sweep =="
echo

# 1. Em dash check (project rule: use hyphens, not em dashes)
EM_DASH_TOTAL=0
for f in "${FILES[@]}"; do
  if [ -f "$f" ]; then
    n=$(grep -c $'\xe2\x80\x94' "$f" 2>/dev/null || echo 0)
    EM_DASH_TOTAL=$((EM_DASH_TOTAL + n))
    [ "$n" -gt 0 ] && echo "  FAIL - $f has $n em dashes"
  fi
done
if [ "$EM_DASH_TOTAL" -eq 0 ]; then
  echo "  PASS - zero em dashes across all shipped legal files"
else
  echo "  FAIL - total em dashes: $EM_DASH_TOTAL"
  FAIL=1
fi
echo

# 2. Fake / invented email addresses (customize the allowlist from intake)
echo "-- fake-email / invented-domain sweep --"
FAKE_PATTERNS=(
  "privacy@"
  "legal@"
  "noreply@"
  "no-reply@"
  "donotreply@"
  "admin@"
)
for pat in "${FAKE_PATTERNS[@]}"; do
  total=0
  for f in "${FILES[@]}"; do
    if [ -f "$f" ]; then
      n=$(grep -c "$pat" "$f" 2>/dev/null || echo 0)
      total=$((total + n))
    fi
  done
  if [ "$total" -gt 0 ]; then
    echo "  WARN - '$pat' appears $total times - confirm each is a real mailbox on the allowlist"
  fi
done
echo "  DONE - check the WARN lines against the project's real-mailbox memory file"
echo

# 3. Last-Updated date consistency
echo "-- Last-Updated date consistency --"
DATES_FOUND=()
for f in "${FILES[@]}"; do
  if [ -f "$f" ]; then
    d=$(grep -oE "Last Updated:? [A-Z][a-z]+ [0-9]+,? [0-9]{4}" "$f" | head -1)
    if [ -n "$d" ]; then
      DATES_FOUND+=("$f:: $d")
    fi
  fi
done
UNIQUE_DATES=$(printf '%s\n' "${DATES_FOUND[@]}" | awk -F':: ' '{print $2}' | sort -u | wc -l)
if [ "$UNIQUE_DATES" -le 1 ]; then
  echo "  PASS - Last Updated is consistent across files"
else
  echo "  FAIL - Last Updated date disagrees across files:"
  printf '    %s\n' "${DATES_FOUND[@]}"
  FAIL=1
fi
echo

# 4. Placeholder markers (things that should have been replaced)
echo "-- placeholder markers still present --"
PLACEHOLDER_TOTAL=0
for f in "${FILES[@]}"; do
  if [ -f "$f" ]; then
    n=$(grep -cE "\[.*(to be inserted|TO BE INSERTED|placeholder|PLACEHOLDER|TBD).*\]" "$f" 2>/dev/null || echo 0)
    if [ "$n" -gt 0 ]; then
      PLACEHOLDER_TOTAL=$((PLACEHOLDER_TOTAL + n))
      echo "  WARN - $f has $n placeholder markers"
      grep -nE "\[.*(to be inserted|TO BE INSERTED|placeholder|PLACEHOLDER|TBD).*\]" "$f" | head -5 | sed 's/^/    /'
    fi
  fi
done
if [ "$PLACEHOLDER_TOTAL" -gt 0 ]; then
  echo "  NOTICE - $PLACEHOLDER_TOTAL placeholders still present (these are OK if intentional, e.g., EU Art. 27 rep pending; bad if the skill forgot to fill them)"
fi
echo

# 5. Google Limited Use verbatim check (only if this product uses Google OAuth)
echo "-- Google Limited Use verbatim check --"
if grep -qi "google" "$PRIV_TSX" "$PRIV_MD" 2>/dev/null; then
  REQUIRED=(
    "To provide or improve your appropriate access or user-facing features"
    "For security purposes"
    "To comply with applicable laws"
    "merger, acquisition, or sale of assets"
  )
  MISSING=0
  for req in "${REQUIRED[@]}"; do
    if ! grep -q "$req" "$PRIV_TSX" "$PRIV_MD" 2>/dev/null; then
      echo "  FAIL - Limited Use phrase not found verbatim: \"$req\""
      MISSING=$((MISSING + 1))
    fi
  done
  if [ "$MISSING" -eq 0 ]; then
    echo "  PASS - all four Limited Use exceptions present verbatim"
  else
    echo "  FAIL - $MISSING of 4 Limited Use exceptions missing or paraphrased"
    FAIL=1
  fi
else
  echo "  SKIP - product does not appear to use Google OAuth"
fi
echo

# 6. TypeScript check (if this is a TS project)
echo "-- TypeScript check --"
if [ -f "tsconfig.json" ] || [ -f "app/tsconfig.json" ]; then
  if command -v npx >/dev/null 2>&1; then
    TS_PROJECT="app"
    [ -f "tsconfig.json" ] && TS_PROJECT="."
    if npx tsc --noEmit -p "$TS_PROJECT" > /tmp/tsc-out.log 2>&1; then
      echo "  PASS - tsc clean"
    else
      echo "  FAIL - tsc errors:"
      head -20 /tmp/tsc-out.log | sed 's/^/    /'
      FAIL=1
    fi
  else
    echo "  SKIP - npx not available"
  fi
else
  echo "  SKIP - no tsconfig.json found"
fi
echo

# Summary
echo "== summary =="
if [ "$FAIL" -eq 0 ]; then
  echo "PASS - ready to commit"
  exit 0
else
  echo "FAIL - fix the issues above before committing"
  exit 1
fi

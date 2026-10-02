#!/usr/bin/env bash
set -euo pipefail

site_root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
content_root="$site_root/content"
static_root="$site_root/static"

errors=0

while IFS= read -r -d '' file; do
  pdf="$(grep -oP '(?<=^pdf: ")[^"]*' "$file" || true)"
  if [[ -n "$pdf" && ! -f "$static_root$pdf" ]]; then
    echo "ERROR: $file references missing pdf $pdf" >&2
    errors=$((errors + 1))
  fi
  page="${file#"$content_root/"}"
  page="$site_root/public/${page,,}"
  page="${page%.md}.html"
  if grep -q '^material: "lecture"' "$file"; then
    if ! grep -q 'giscus' "$page" 2>/dev/null; then
      echo "ERROR: $file has no lecture page with giscus at $page" >&2
      errors=$((errors + 1))
    fi
  elif [[ -e "$page" ]]; then
    echo "ERROR: $file must not render a page at $page" >&2
    errors=$((errors + 1))
  fi
done < <(find "$content_root" -name 'index.md' -print0)

if [[ "$errors" -gt 0 ]]; then
  echo "$errors problem(s) found" >&2
  exit 1
fi

echo "check.sh: OK"

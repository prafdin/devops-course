#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dest_root="$repo_root/site/static"

for year in 2025 2026; do
  while IFS= read -r -d '' pdf; do
    rel="${pdf#"$repo_root"/}"
    dest="$dest_root/$rel"
    mkdir -p "$(dirname "$dest")"
    cp "$pdf" "$dest"
  done < <(find "$repo_root/$year" -name '*.pdf' -print0)
done

echo "Collected PDFs into $dest_root"

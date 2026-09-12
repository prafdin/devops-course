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
  done < <(find "$repo_root/$year" -name '*.pdf' -not -path '*/package/*' -not -path '*/svg-inkscape/*' -print0)
done

svg="$repo_root/2026/extra/docker-commands.svg"
if [[ -f "$svg" ]]; then
  mkdir -p "$dest_root/2026/extra"
  cp "$svg" "$dest_root/2026/extra/docker-commands.svg"
fi

echo "Collected PDFs into $dest_root"

#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
content_root="$repo_root/site/content"

records=(
"2025|01-what-is-devops|lecture|what-is-devops|"
"2025|02-proxy|lecture|proxy|"
"2025|03-git|lecture|git|"
"2025|04-cicd|lecture|cicd|"
"2025|05-configuration-management|lecture|configuration-management|"
"2025|06-docker|lecture|docker|"
"2025|06-docker-additional|lecture|docker|"
"2025|07-docker-compose|lecture|docker-compose|"
"2025|08-packer|lecture|packer|"
"2025|09-cloud|lecture|cloud|"
"2025|10-IaC|lecture|iac|"
"2025|11-DevSecOps|lecture|devsecops|"
"2025|assignments/01-git-webhooks|assignment|git|"
"2025|assignments/02-github-actions|assignment|cicd|"
"2025|assignments/03-docker|assignment|docker|"
"2025|assignments/04-docker-compose|assignment|docker-compose|"
"2025|others/01-course-questions|extra||"
"2026|01-what-is-devops|lecture|what-is-devops|"
"2026|02-webserver-proxy|lecture|proxy|"
"2026|03-ssh-tunnelling-frp|lecture|ssh-tunnelling|https://disk.yandex.ru/i/Rra5ItteQ2hzdA"
"2026|04-nat|lecture|nat|https://disk.yandex.ru/i/x3U2zlcnubIfxA"
"2026|05-git|lecture|git|https://disk.yandex.ru/i/wVwnqWD8rkZDPQ"
"2026|06-cicd|lecture|cicd|https://disk.yandex.ru/i/_VeOJiuX4Rtplw"
"2026|07-docker-intro|lecture|docker|https://disk.yandex.ru/i/eOyzlNKjqpFEaw"
"2026|08-docker-commands|lecture|docker|https://disk.yandex.ru/i/7rYGFjFiuGVKQQ"
"2026|09-docker-compose-intro|lecture|docker-compose|https://disk.yandex.ru/i/kZkayYfyVAbCjQ"
"2026|10-docker-compose-for-website|lecture|docker-compose|https://disk.yandex.ru/i/IgCZzthz7H-rUQ"
"2026|11-configuration-management|lecture|configuration-management|https://disk.yandex.ru/i/Qbc0igxh_Ku9GQ"
"2026|12-packer|lecture|packer|https://disk.yandex.ru/i/MfJx6x-OalDtSw"
"2026|13-cloud|lecture|cloud|https://disk.yandex.ru/i/bmvYQxwHwkCs0A"
"2026|14-iac|lecture|iac|https://disk.yandex.ru/i/VjlFaubjFEDdOw"
"2026|assignments/00-howto|extra||"
"2026|assignments/01-git-webhooks|assignment|git|"
"2026|assignments/02-github-actions|assignment|cicd|"
"2026|assignments/03-docker|assignment|docker|"
"2026|assignments/04-docker-compose|assignment|docker-compose|"
"2026|extra/exam|extra||"
"2026|extra/exam-questions|extra||"
)

title_from_dirname() {
  local base="$1"
  local stripped
  stripped="$(echo "$base" | sed -E 's/^[0-9]+-//')"
  echo "$stripped" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1'
}

count=0
for record in "${records[@]}"; do
  IFS='|' read -r year relpath kind topic video <<< "$record"
  base="$(basename "$relpath")"

  if [[ "$kind" == "lecture" ]]; then
    tex="$repo_root/$year/$relpath/$base.tex"
    title="$(grep -oP '(?<=\\title\{)[^}]*' "$tex" | head -1)"
  else
    title="$(title_from_dirname "$base")"
  fi
  title="${title//\"/\\\"}"

  numprefix="$(echo "$base" | grep -oE '^[0-9]+' || true)"
  if [[ -n "$numprefix" ]]; then
    weight=$((10#$numprefix))
  else
    weight=0
  fi

  outdir="$content_root/$year/$relpath"
  mkdir -p "$outdir"
  {
    echo "---"
    echo "title: \"$title\""
    echo "year: $year"
    echo "material: \"$kind\""
    if [[ -n "$topic" ]]; then
      echo "topics: [\"$topic\"]"
    fi
    echo "pdf: \"/$year/$relpath/$base.pdf\""
    if [[ -n "$video" ]]; then
      echo "video: \"$video\""
    fi
    echo "weight: $weight"
    echo "---"
  } > "$outdir/index.md"
  count=$((count + 1))
done

for year in 2025 2026; do
  outdir="$content_root/$year"
  mkdir -p "$outdir"
  {
    echo "---"
    echo "title: \"$year\""
    echo "type: \"year\""
    echo "year: $year"
    echo "---"
  } > "$outdir/_index.md"
  count=$((count + 1))
done

echo "Generated $count content files"

#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
content_root="$repo_root/site/content"

records=(
"2025|01-what-is-devops|lecture|"
"2025|02-proxy|lecture|"
"2025|03-git|lecture|"
"2025|04-cicd|lecture|"
"2025|05-configuration-management|lecture|"
"2025|06-docker|lecture|"
"2025|06-docker-additional|lecture|"
"2025|07-docker-compose|lecture|"
"2025|08-packer|lecture|"
"2025|09-cloud|lecture|"
"2025|10-IaC|lecture|"
"2025|11-DevSecOps|lecture|"
"2025|assignments/01-git-webhooks|assignment|"
"2025|assignments/02-github-actions|assignment|"
"2025|assignments/03-docker|assignment|"
"2025|assignments/04-docker-compose|assignment|"
"2025|others/01-course-questions|extra|"
"2026|01-what-is-devops|lecture|"
"2026|02-webserver-proxy|lecture|"
"2026|03-ssh-tunnelling-frp|lecture|https://disk.yandex.ru/i/Rra5ItteQ2hzdA"
"2026|04-nat|lecture|https://disk.yandex.ru/i/x3U2zlcnubIfxA"
"2026|05-git|lecture|https://disk.yandex.ru/i/wVwnqWD8rkZDPQ"
"2026|06-cicd|lecture|https://disk.yandex.ru/i/_VeOJiuX4Rtplw"
"2026|07-docker-intro|lecture|https://disk.yandex.ru/i/eOyzlNKjqpFEaw"
"2026|08-docker-commands|lecture|https://disk.yandex.ru/i/7rYGFjFiuGVKQQ"
"2026|09-docker-compose-intro|lecture|https://disk.yandex.ru/i/kZkayYfyVAbCjQ"
"2026|10-docker-compose-for-website|lecture|https://disk.yandex.ru/i/IgCZzthz7H-rUQ"
"2026|11-configuration-management|lecture|https://disk.yandex.ru/i/Qbc0igxh_Ku9GQ"
"2026|12-packer|lecture|https://disk.yandex.ru/i/MfJx6x-OalDtSw"
"2026|13-cloud|lecture|https://disk.yandex.ru/i/bmvYQxwHwkCs0A"
"2026|14-iac|lecture|https://disk.yandex.ru/i/VjlFaubjFEDdOw"
"2026|assignments/00-howto|extra|"
"2026|assignments/01-git-webhooks|assignment|"
"2026|assignments/02-github-actions|assignment|"
"2026|assignments/03-docker|assignment|"
"2026|assignments/04-docker-compose|assignment|"
"2026|extra/exam|extra|"
)

title_from_dirname() {
  local base="$1"
  local stripped
  stripped="$(echo "$base" | sed -E 's/^[0-9]+-//')"
  echo "$stripped" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1'
}

count=0
for record in "${records[@]}"; do
  IFS='|' read -r year relpath kind video <<< "$record"
  base="$(basename "$relpath")"

  if [[ "$kind" == "lecture" ]]; then
    tex="$repo_root/$year/$relpath/$base.tex"
    title="$(grep -oP '(?<=\\title\{)[^}]*' "$tex" | head -1)"
  else
    case "$year|$relpath" in
      "2025|others/01-course-questions") title="Вопросы по курсу" ;;
      "2026|assignments/00-howto") title="Инструкция по сдаче лабораторных работ" ;;
      "2026|extra/exam") title="Вопросы к экзамену" ;;
      *) title="$(title_from_dirname "$base")" ;;
    esac
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
    if [[ "$year" == "2026" ]]; then
      echo "links:"
      echo "  - title: \"Ведомость и варианты: ОИС. DevOps 2026\""
      echo "    url: \"https://docs.google.com/spreadsheets/d/1Yn1ndqJN1kfMd_l4s7Owe69pmjhxSurJq5D-Abu8_c4/edit?usp=sharing\""
      echo "  - title: \"Запись для 6311 и 6312\""
      echo "    url: \"https://docs.google.com/spreadsheets/d/1gvJdCa0G3qM1yffGW0V1X46efWsCyGss_FIsigWkqZM/edit?usp=sharing\""
      echo "  - title: \"Запись для 6313\""
      echo "    url: \"https://docs.google.com/spreadsheets/d/12wzJg138y3UQszR306eBbdYeiUjwvcs1OmxCX4Hyhs4/edit?usp=sharing\""
    fi
    echo "---"
  } > "$outdir/_index.md"
  count=$((count + 1))
done

echo "Generated $count content files"

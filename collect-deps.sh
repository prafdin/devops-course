#!/bin/bash
# collect_project_deps.sh

shopt -s globstar

# все fls файлы
FLS_FILES=(**/*.fls)

grep '^INPUT ' "${FLS_FILES[@]}" | \
    sed 's/^INPUT //' | \
    # убираем системные файлы
    grep -v '^/usr/' | \
    grep -v '^/home/prafdin/.texlive2024' | \
    # убираем промежуточные файлы
    grep -vE '\.(aux|nav|out|toc|log|fls|fdb_latexmk)$' | \
    grep -v '^$' | \
    sort -u > deps.txt

echo "Список зависимостей проекта готов: deps.txt"

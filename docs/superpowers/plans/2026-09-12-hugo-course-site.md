# Hugo Course Site Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the bash-heredoc-generated GitHub Pages site with a Hugo site that keeps PDFs (built by the existing LaTeX pipeline) as the content source but adds a `topics` taxonomy so the same topic's 2025 and 2026 versions appear together.

**Architecture:** A new `site/` Hugo project. Two shell scripts turn the existing repo layout into Hugo input: `scaffold-content.sh` writes one headless content bundle (`index.md`) per lecture/assignment/extra directory with a curated `topics`/`kind`/`video` front-matter mapping, and `collect-pdfs.sh` copies the already-built PDFs into `site/static/` at matching paths. A validation script (`check.sh`) catches broken PDF references and unknown topic slugs before deploy. Three Hugo templates render the result: a home page listing all topics, a term page per topic showing every year's material grouped together (the actual deliverable), and a year page for material that isn't topic-specific (exam questions, lab how-to).

**Tech Stack:** Hugo (Go, static binary, pinned to v0.140.2), Bash, existing LaTeX/latexmk pipeline (untouched), GitHub Actions, GitHub Pages.

**Spec:** `docs/superpowers/specs/2026-09-12-hugo-course-site-design.md`

## Global Constraints

- Content source stays PDF — no LaTeX→HTML conversion (spec decision).
- No JS framework, no Node toolchain — plain Hugo + hand-written CSS.
- `site/content/`, `site/static/2025/`, `site/static/2026/`, `site/public/` are generated, not committed (matches existing convention of not committing `*.pdf`, `*.aux`, `package/`).
- Hugo version pinned to `0.140.2` everywhere it's installed (local dev steps and CI) — no `latest`.
- Every task that shells out to Hugo directly (not via `make`/CI, which assume `hugo` on `PATH`) uses the explicit path `"$HOME/.local/bin/hugo"` installed in Task 1, since each task may run in a fresh shell that hasn't re-sourced a profile.

---

## Task 1: Hugo skeleton, base layout, home page

**Files:**
- Create: `site/hugo.toml`
- Create: `site/layouts/_default/baseof.html`
- Create: `site/layouts/partials/head.html`
- Create: `site/layouts/partials/header.html`
- Create: `site/layouts/partials/footer.html`
- Create: `site/layouts/index.html`
- Create: `site/static/css/style.css`
- Modify: `.gitignore` (add `site/public/`)

**Interfaces:**
- Produces: a working `hugo build` in `site/` that renders `site/public/index.html`. Later tasks (2-5) add content and more templates; this task's `baseof.html`/partials are consumed by every other template via `{{ block "main" . }}`.

- [ ] **Step 1: Install Hugo locally (pinned version) for testing this plan**

```bash
mkdir -p "$HOME/.local/bin"
curl -sL https://github.com/gohugoio/hugo/releases/download/v0.140.2/hugo_0.140.2_linux-amd64.tar.gz \
  | tar -xz -C "$HOME/.local/bin" hugo
chmod +x "$HOME/.local/bin/hugo"
"$HOME/.local/bin/hugo" version
```

Expected: prints `hugo v0.140.2 ...`.

- [ ] **Step 2: Create `site/hugo.toml`**

```toml
baseURL = "https://prafdin.github.io/devops-course/"
languageCode = "ru"
title = "Курс DevOps"

[taxonomies]
  topic = "topics"

disableKinds = ["taxonomy"]
```

- [ ] **Step 3: Create the base template and partials**

`site/layouts/_default/baseof.html`:

```html
<!doctype html>
<html lang="ru">
<head>
{{ partial "head.html" . }}
</head>
<body>
{{ partial "header.html" . }}
<main>
{{ block "main" . }}{{ end }}
</main>
{{ partial "footer.html" . }}
</body>
</html>
```

`site/layouts/partials/head.html`:

```html
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{{ if .IsHome }}{{ site.Title }}{{ else }}{{ .Title }} — {{ site.Title }}{{ end }}</title>
<link rel="stylesheet" href="{{ "css/style.css" | relURL }}">
```

`site/layouts/partials/header.html`:

```html
<header class="site-header">
  <a class="site-title" href="{{ "/" | relURL }}">{{ site.Title }}</a>
</header>
```

`site/layouts/partials/footer.html`:

```html
<footer class="site-footer">
  <a href="https://github.com/prafdin/devops-course">Исходники на GitHub</a>
</footer>
```

- [ ] **Step 4: Create the home page template**

`site/layouts/index.html`:

```html
{{ define "main" }}
<h1>{{ site.Title }}</h1>
<p>Темы курса:</p>
<ul class="topic-list">
{{ range $term, $weightedPages := .Site.Taxonomies.topics }}
  {{ $label := index $.Site.Data.topics $term }}
  <li>
    <a href="/topics/{{ $term | urlize }}/">{{ if $label }}{{ $label }}{{ else }}{{ $term }}{{ end }}</a>
    <span class="count">({{ len $weightedPages }})</span>
  </li>
{{ end }}
</ul>
<p>Материалы по годам целиком:
{{ range (sort .Site.Sections "Title") }}<a href="{{ .RelPermalink }}">{{ .Title }}</a> {{ end }}
</p>
{{ end }}
```

- [ ] **Step 5: Create the CSS**

`site/static/css/style.css`:

```css
:root { color-scheme: light dark; }
body {
  font-family: system-ui, sans-serif;
  max-width: 42rem;
  margin: 0 auto;
  padding: 1rem;
  line-height: 1.5;
}
h1, h2, h3 { line-height: 1.2; }
ul { padding-left: 1.2rem; }
li { margin: 0.4rem 0; }
.site-header { margin-bottom: 1.5rem; }
.site-title { font-weight: bold; text-decoration: none; font-size: 1.2rem; }
.count { color: gray; font-size: 0.9em; }
.site-footer { margin-top: 2rem; font-size: 0.9em; }
```

- [ ] **Step 6: Add `site/public/` to `.gitignore`**

Append to `.gitignore`:

```
site/public/
```

- [ ] **Step 7: Build and verify**

```bash
cd site && "$HOME/.local/bin/hugo" --minify && cd ..
grep -o '<title>Курс DevOps</title>' site/public/index.html
```

Expected: the `grep` prints the matched tag (no error, no empty output).

- [ ] **Step 8: Commit**

```bash
git add site/hugo.toml site/layouts site/static/css .gitignore
git commit -m "Add Hugo skeleton with home page and base layout

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01VQNBzTSuyfSt8AB7JhbQSn"
```

---

## Task 2: Content scaffolding script

**Files:**
- Create: `site/scaffold-content.sh`
- Modify: `.gitignore` (add `site/content/`)

**Interfaces:**
- Produces: `site/content/<year>/<relpath>/index.md` for every lecture/assignment/extra, and `site/content/<year>/_index.md` for each year. Front matter fields used by later tasks: `title` (string), `year` (int), `kind` (`"lecture"`/`"assignment"`/`"extra"`), `topics` (list, omitted for `kind: extra`), `pdf` (site-root-relative path string), `video` (optional string), `weight` (int). Year pages carry `type: "year"`.
- Consumes: nothing from earlier tasks — reads directly from `2025/`, `2026/` LaTeX sources on disk (already-built `.tex` files for lecture titles).

- [ ] **Step 1: Write `site/scaffold-content.sh`**

```bash
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
    echo "kind: \"$kind\""
    if [[ -n "$topic" ]]; then
      echo "topics: [\"$topic\"]"
    fi
    echo "pdf: \"/$year/$relpath/$base.pdf\""
    if [[ -n "$video" ]]; then
      echo "video: \"$video\""
    fi
    echo "weight: $weight"
    echo "_build:"
    echo "  render: false"
    echo "  list: always"
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
```

- [ ] **Step 2: Make it executable and run it**

```bash
chmod +x site/scaffold-content.sh
./site/scaffold-content.sh
```

Expected: prints `Generated 40 content files` (38 items: 17 for 2025 + 21 for 2026, plus 2 year indexes).

- [ ] **Step 3: Verify specific generated files**

```bash
cat site/content/2026/07-docker-intro/index.md
grep -q 'title: "Docker"' site/content/2026/07-docker-intro/index.md
grep -q 'topics: \["docker"\]' site/content/2026/07-docker-intro/index.md
grep -q 'video: "https://disk.yandex.ru/i/eOyzlNKjqpFEaw"' site/content/2026/07-docker-intro/index.md
grep -q 'weight: 7' site/content/2026/07-docker-intro/index.md

grep -q 'title: "Docker: сеть, volumes, bind mounts"' site/content/2025/06-docker-additional/index.md

grep -q 'title: "Git Webhooks"' site/content/2026/assignments/01-git-webhooks/index.md
grep -q 'topics: \["git"\]' site/content/2026/assignments/01-git-webhooks/index.md

grep -q 'kind: "extra"' site/content/2026/extra/exam/index.md
grep -q '^topics:' site/content/2026/extra/exam/index.md && echo "FAIL: extra must not have topics" || echo "OK: extra has no topics"

grep -q 'type: "year"' site/content/2025/_index.md
```

Expected: all `grep -q` calls succeed silently (no output, no non-zero exit under `set -e` if you wrap the block that way); the final line prints `OK: extra has no topics`.

- [ ] **Step 4: Add `site/content/` to `.gitignore`**

Append to `.gitignore`:

```
site/content/
```

- [ ] **Step 5: Commit**

```bash
git add site/scaffold-content.sh .gitignore
git commit -m "Add content scaffolding script mapping lectures/assignments to topics

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01VQNBzTSuyfSt8AB7JhbQSn"
```

---

## Task 3: PDF collection script

**Files:**
- Create: `site/collect-pdfs.sh`
- Modify: `.gitignore` (add `site/static/2025/`, `site/static/2026/`)

**Interfaces:**
- Consumes: `pdf:` paths written by Task 2's scaffold script (format `/<year>/<relpath>/<base>.pdf`), which this script must satisfy by copying the real PDF to `site/static/<year>/<relpath>/<base>.pdf`.
- Produces: populated `site/static/2025/` and `site/static/2026/` mirroring the source tree's existing `*.pdf` files.

- [ ] **Step 1: Write `site/collect-pdfs.sh`**

```bash
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
```

- [ ] **Step 2: Make it executable and run it**

```bash
chmod +x site/collect-pdfs.sh
./site/collect-pdfs.sh
```

Expected: prints `Collected PDFs into .../site/static` (PDFs must already exist on disk from a prior `make` run of the LaTeX pipeline — this repo already has them built).

- [ ] **Step 3: Verify against the paths Task 2 generates**

```bash
test -f site/static/2026/07-docker-intro/07-docker-intro.pdf && echo OK
test -f site/static/2025/06-docker-additional/06-docker-additional.pdf && echo OK
test -f site/static/2026/extra/exam/exam.pdf && echo OK
```

Expected: three `OK` lines.

- [ ] **Step 4: Add generated PDF dirs to `.gitignore`**

Append to `.gitignore`:

```
site/static/2025/
site/static/2026/
```

- [ ] **Step 5: Commit**

```bash
git add site/collect-pdfs.sh .gitignore
git commit -m "Add script to copy built PDFs into the Hugo static dir

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01VQNBzTSuyfSt8AB7JhbQSn"
```

---

## Task 4: Topic whitelist and validation script

**Files:**
- Create: `site/data/topics.yaml`
- Create: `site/check.sh`

**Interfaces:**
- Consumes: `site/content/**/index.md` front matter (`pdf:`, `topics:`) from Task 2, `site/static/` from Task 3.
- Produces: `site/data/topics.yaml` (slug → human label map), consumed by Task 1's home template and Task 5's term template via `.Site.Data.topics`. `site/check.sh <site_root>` exits non-zero on any broken `pdf:` reference or unknown `topics:` slug.

- [ ] **Step 1: Write `site/data/topics.yaml`**

```yaml
what-is-devops: "Что такое DevOps"
proxy: "Веб-сервер и прокси"
ssh-tunnelling: "SSH и туннелирование"
nat: "NAT"
git: "Git"
cicd: "CI/CD"
docker: "Docker"
docker-compose: "Docker Compose"
configuration-management: "Управление конфигурацией"
packer: "Packer"
cloud: "Облачные вычисления"
iac: "Infrastructure as Code"
devsecops: "DevSecOps"
```

- [ ] **Step 2: Write `site/check.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

site_root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
content_root="$site_root/content"
static_root="$site_root/static"
topics_file="$site_root/data/topics.yaml"

known_topics="$(grep -oE '^[a-z0-9-]+:' "$topics_file" | sed 's/:$//')"

errors=0

while IFS= read -r -d '' file; do
  pdf="$(grep -oP '(?<=^pdf: ")[^"]*' "$file" || true)"
  if [[ -n "$pdf" && ! -f "$static_root$pdf" ]]; then
    echo "ERROR: $file references missing pdf $pdf" >&2
    errors=$((errors + 1))
  fi

  topics_line="$(grep -oP '(?<=^topics: \[)[^]]*' "$file" || true)"
  if [[ -n "$topics_line" ]]; then
    IFS=',' read -ra terms <<< "$topics_line"
    for term in "${terms[@]}"; do
      term="$(echo "$term" | tr -d ' "')"
      if ! grep -qx "$term" <<< "$known_topics"; then
        echo "ERROR: $file uses unknown topic '$term'" >&2
        errors=$((errors + 1))
      fi
    done
  fi
done < <(find "$content_root" -name 'index.md' -print0)

if [[ "$errors" -gt 0 ]]; then
  echo "$errors problem(s) found" >&2
  exit 1
fi

echo "check.sh: OK"
```

- [ ] **Step 3: Make it executable**

```bash
chmod +x site/check.sh
```

- [ ] **Step 4: Build a fixture and verify the failure path**

```bash
fixture="$(mktemp -d)/check-fixture-broken"
mkdir -p "$fixture/content/broken" "$fixture/static" "$fixture/data"
cat > "$fixture/data/topics.yaml" <<'EOF'
docker: "Docker"
EOF
cat > "$fixture/content/broken/index.md" <<'EOF'
---
title: "Broken"
pdf: "/missing.pdf"
topics: ["nope"]
---
EOF

set +e
./site/check.sh "$fixture"
status=$?
set -e
[[ "$status" -ne 0 ]] && echo "OK: broken fixture correctly failed"
```

Expected: two `ERROR:` lines (missing pdf, unknown topic), then `2 problem(s) found`, then `OK: broken fixture correctly failed`.

- [ ] **Step 5: Verify the success path with a valid fixture**

```bash
fixture="$(mktemp -d)/check-fixture-valid"
mkdir -p "$fixture/content/valid" "$fixture/static" "$fixture/data"
cat > "$fixture/data/topics.yaml" <<'EOF'
docker: "Docker"
EOF
touch "$fixture/static/valid.pdf"
cat > "$fixture/content/valid/index.md" <<'EOF'
---
title: "Valid"
pdf: "/valid.pdf"
topics: ["docker"]
---
EOF

./site/check.sh "$fixture"
```

Expected: `check.sh: OK`, exit code 0.

- [ ] **Step 6: Run against the real generated site (Tasks 2+3 output)**

```bash
./site/check.sh site
```

Expected: `check.sh: OK` (all 38 generated pages reference PDFs that Task 3 copied, and all `topics` values are in the Task 4 whitelist by construction).

- [ ] **Step 7: Commit**

```bash
git add site/data/topics.yaml site/check.sh
git commit -m "Add topic whitelist and content validation script

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01VQNBzTSuyfSt8AB7JhbQSn"
```

---

## Task 5: Topic and year page templates (cross-year navigation)

**Files:**
- Create: `site/layouts/_default/term.html`
- Create: `site/layouts/year/list.html`

**Interfaces:**
- Consumes: `site/content/**/index.md` front matter fields defined in Task 2 (`kind`, `year`, `pdf`, `video`, `weight`, `title`), `site/data/topics.yaml` from Task 4, `site/static/` from Task 3.
- Produces: `site/public/topics/<slug>/index.html` (one per topic) and `site/public/<year>/index.html` (one per year) when built.

- [ ] **Step 1: Write the term page template**

`site/layouts/_default/term.html`:

```html
{{ define "main" }}
{{ $label := index site.Data.topics .Data.Term }}
<h1>{{ if $label }}{{ $label }}{{ else }}{{ .Data.Term }}{{ end }}</h1>
{{ $byYear := .Pages.GroupBy "Params.year" }}
{{ range $byYear.Reverse }}
  <h2>{{ .Key }}</h2>
  {{ $lectures := where .Pages "Params.kind" "lecture" }}
  {{ $assignments := where .Pages "Params.kind" "assignment" }}
  {{ if $lectures }}
  <h3>Лекции</h3>
  <ul>
    {{ range $lectures.ByWeight }}
    <li>
      <a href="{{ .Params.pdf }}">{{ .Title }}</a>
      {{ with .Params.video }}— <a href="{{ . }}">видео</a>{{ end }}
    </li>
    {{ end }}
  </ul>
  {{ end }}
  {{ if $assignments }}
  <h3>Задания</h3>
  <ul>
    {{ range $assignments.ByWeight }}
    <li><a href="{{ .Params.pdf }}">{{ .Title }}</a></li>
    {{ end }}
  </ul>
  {{ end }}
{{ end }}
{{ end }}
```

- [ ] **Step 2: Write the year page template**

`site/layouts/year/list.html`:

```html
{{ define "main" }}
<h1>{{ .Title }}</h1>
<p><a href="{{ "/" | relURL }}">На главную (по темам)</a></p>
{{ $extra := where .Site.RegularPages "Params.kind" "extra" }}
{{ $extra = where $extra "Params.year" .Params.year }}
{{ if $extra }}
<h2>Дополнительные материалы</h2>
<ul>
{{ range $extra.ByWeight }}
  <li><a href="{{ .Params.pdf }}">{{ .Title }}</a></li>
{{ end }}
</ul>
{{ end }}
{{ end }}
```

- [ ] **Step 3: Build and verify the cross-year deliverable**

```bash
cd site && "$HOME/.local/bin/hugo" --minify && cd ..
grep -q '<h2>2026</h2>' site/public/topics/docker/index.html && echo "OK: 2026 present"
grep -q '<h2>2025</h2>' site/public/topics/docker/index.html && echo "OK: 2025 present"
grep -c '<h3>Лекции</h3>' site/public/topics/docker/index.html
```

Expected: `OK: 2026 present`, `OK: 2025 present`, and the count line prints `2` (one "Лекции" heading per year block, since `docker` has lecture pages in both years).

- [ ] **Step 4: Verify the year page**

```bash
grep -q 'Дополнительные материалы' site/public/2026/index.html && echo "OK"
grep -q 'exam.pdf' site/public/2026/index.html && echo "OK"
```

Expected: two `OK` lines.

- [ ] **Step 5: Commit**

```bash
git add site/layouts/_default/term.html site/layouts/year/list.html
git commit -m "Add topic and year page templates showing cross-year material

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01VQNBzTSuyfSt8AB7JhbQSn"
```

---

## Task 6: CI workflow wiring

**Files:**
- Modify: `.github/workflows/latexmk.yml`

**Interfaces:**
- Consumes: `site/scaffold-content.sh` (Task 2), `site/collect-pdfs.sh` (Task 3), `site/check.sh` (Task 4), `site/` Hugo project (Tasks 1-5).

- [ ] **Step 1: Replace the workflow's build/deploy steps**

Current content of `.github/workflows/latexmk.yml`:

```yaml
# SPDX-FileCopyrightText: Copyright (c) 2023-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
---
name: latexmk
'on':
  push:
    branches:
      - master
jobs:
  latexmk:
    timeout-minutes: 15
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: true
      - run: sudo apt-get update --yes --fix-missing && sudo apt-get install --yes wget
      - uses: prafdin/latexmk-action@master # TODO: revert to yegor256 after resolve https://github.com/yegor256/latexmk-action/issues/102
        with:
          cmd: make
          depends: DEPENDS.txt
      - uses: JamesIves/github-pages-deploy-action@v4.7.3
        with:
          branch: gh-pages
          folder: package
          clean: true
        if: github.ref == 'refs/heads/master'
```

New content:

```yaml
# SPDX-FileCopyrightText: Copyright (c) 2023-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
---
name: latexmk
'on':
  push:
    branches:
      - master
jobs:
  latexmk:
    timeout-minutes: 15
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: true
      - run: sudo apt-get update --yes --fix-missing && sudo apt-get install --yes wget
      - uses: prafdin/latexmk-action@master # TODO: revert to yegor256 after resolve https://github.com/yegor256/latexmk-action/issues/102
        with:
          cmd: make years-all
          depends: DEPENDS.txt
      - uses: peaceiris/actions-hugo@v3
        with:
          hugo-version: '0.140.2'
      - run: ./site/scaffold-content.sh
      - run: ./site/collect-pdfs.sh
      - run: ./site/check.sh site
      - run: cd site && hugo --minify
      - uses: JamesIves/github-pages-deploy-action@v4.7.3
        with:
          branch: gh-pages
          folder: site/public
          clean: true
        if: github.ref == 'refs/heads/master'
```

The `cmd: make` → `cmd: make years-all` change scopes the latexmk-action's container to PDF compilation only (its container isn't guaranteed to have Hugo); the Hugo-related steps run directly on the `ubuntu-22.04` runner via a marketplace action, same as the deploy step already does.

- [ ] **Step 2: Validate YAML syntax**

```bash
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/latexmk.yml'))" && echo "YAML OK"
```

Expected: `YAML OK`.

- [ ] **Step 3: Verify the key strings are present**

```bash
grep -q 'cmd: make years-all' .github/workflows/latexmk.yml && echo OK
grep -q "hugo-version: '0.140.2'" .github/workflows/latexmk.yml && echo OK
grep -q 'folder: site/public' .github/workflows/latexmk.yml && echo OK
```

Expected: three `OK` lines.

- [ ] **Step 4: Exercise the same command sequence locally (minus the GitHub-Actions-specific steps)**

PDFs are already built on disk, so `make years-all` is a fast no-op recompile check:

```bash
make years-all
./site/scaffold-content.sh
./site/collect-pdfs.sh
./site/check.sh site
cd site && "$HOME/.local/bin/hugo" --minify && cd ..
echo "Pipeline OK"
```

Expected: no errors, ends with `Pipeline OK`.

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/latexmk.yml
git commit -m "Wire Hugo build into CI, deploy site/public instead of package/

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01VQNBzTSuyfSt8AB7JhbQSn"
```

---

## Task 7: Makefile wiring and old index-generation removal

**Files:**
- Modify: `Makefile`
- Modify: `2025/Makefile`
- Modify: `2026/Makefile`

**Interfaces:**
- Consumes: `site/scaffold-content.sh`, `site/collect-pdfs.sh`, `site/check.sh` (Tasks 2-4), assumes `hugo` is on `PATH` (true in CI after Task 6's `peaceiris/actions-hugo` step; for local use, whoever runs `make site` is expected to have Hugo installed — same assumption the Makefile already makes for `latexmk`).

- [ ] **Step 1: Edit `2025/Makefile`**

Remove the `package/index.html` target and its recipe (the entire block from `package/index.html: $(PDFS)` through the closing `)> "$${dir}/index.html"` line). Change:

```make
all: pdfs package/index.html
```

to:

```make
all: pdfs
```

Resulting full file:

```make
include ../makefile.defs

.PHONY: all

LECTURE_PDFS := $(filter-out assignments/% others/%,$(PDFS))
ASSIGNMENT_PDFS := $(filter assignments/%,$(PDFS))
OTHERS_PDFS := $(filter others/%,$(PDFS))

all: pdfs
```

- [ ] **Step 2: Edit `2026/Makefile`**

Same change: remove the `package/index.html` target/recipe, change:

```make
all: pdfs extras package/index.html
```

to:

```make
all: pdfs extras
```

Resulting full file:

```make
include ../makefile.defs

.PHONY: all

LECTURE_PDFS := $(filter-out assignments/%,$(PDFS))
ASSIGNMENT_PDFS := $(filter assignments/%,$(PDFS))

EXTRA_DIRS = $(shell find ./extra -mindepth 1 -maxdepth 1 -type d | sed 's|^\./||' | sort)
EXTRA_PDFS = $(foreach d,$(EXTRA_DIRS),$(d)/$(notdir $(d)).pdf)

all: pdfs extras

extras: $(EXTRA_PDFS)
```

- [ ] **Step 3: Edit root `Makefile`**

Replace the whole file with:

```make
SHELL := /bin/bash

.SHELLFLAGS = -e -o pipefail -c
.ONESHELL:
.PHONY: all clean site

GITHUB = prafdin/devops-course
DIRS = $(shell find . -mindepth 1 -maxdepth 1 -type d -name '20[0-9][0-9]' -exec basename {} \; | sort)

all: years-all

years-all:
	for d in $(DIRS); do
		cd $${d}
		make all
		cd ..
	done

site: years-all
	./site/scaffold-content.sh
	./site/collect-pdfs.sh
	./site/check.sh site
	cd site && hugo --minify

clean:
	for d in $(DIRS); do
		cd $${d}
		make clean
		cd ..
	done
	rm -rf site/content site/static/2025 site/static/2026 site/public
```

(Dropped `SUB_PACKAGE_INDICES`, the `package/index.html` target, and `rm -rf package` in `clean` since `package/` is no longer produced; `site` is marked `.PHONY` because a real `site/` directory exists on disk.)

- [ ] **Step 4: Verify with a dry run and a real run**

```bash
make -n site
```

Expected: prints the recipe lines for `years-all` (per-year `make all`) followed by the four `site` recipe lines, no errors.

```bash
make site
```

Expected: completes successfully (PDFs already built, so `years-all` is fast); ends with Hugo's build summary. Then:

```bash
test -f site/public/topics/docker/index.html && echo "OK: full pipeline produces the topic page"
```

Expected: `OK: full pipeline produces the topic page`.

- [ ] **Step 5: Manual smoke check with `hugo server`**

```bash
cd site
"$HOME/.local/bin/hugo" server --port 1314 --bind 127.0.0.1 &
server_pid=$!
sleep 2
curl -sf http://127.0.0.1:1314/topics/docker/ | grep -q '<h2>2025</h2>' && echo "OK: served page has 2025"
curl -sf http://127.0.0.1:1314/topics/docker/ | grep -q '<h2>2026</h2>' && echo "OK: served page has 2026"
kill "$server_pid"
cd ..
```

Expected: two `OK:` lines, then the server process is killed.

- [ ] **Step 6: Commit**

```bash
git add Makefile 2025/Makefile 2026/Makefile
git commit -m "Replace bash-heredoc site generation with Hugo build in Makefiles

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01VQNBzTSuyfSt8AB7JhbQSn"
```

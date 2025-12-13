SHELL := /bin/bash

.SHELLFLAGS = -e -o pipefail -c
.ONESHELL:
.PHONY: all

GITHUB = prafdin/devops-course
DIRS = $(shell find . -mindepth 1 -maxdepth 1 -type d -name '20[0-9][0-9]' -exec basename {} \; | sort)

all: years-all package/index.html

years-all:
	for d in $(DIRS); do
		cd $${d}
		make all
		cd ..
	done

package/index.html:
	dir="$$(dirname "$@")"
	title="Курс DevOps"
	mkdir -p "$${dir}"
	(
		echo "<html lang='ru'><head>"
		echo "<meta charset='UTF-8'>"
		echo "<title>$${title}</title>"
		echo "<style>
			section {
				width: 40em;
				margin: 2em auto;
				font-family: monospace;
				font-size: 12pt;
			}
			li {
				margin-top: .5em;
				margin-bottom: .5em;
			}
		</style>"
		echo "</head><body><section>"
		echo "<h1>$${title}</h1>"
		echo "<p>Год прочтения:</p>"
		echo "<ul>"
		for year in $(DIRS); do
			cp -r "$${year}/package" "$${dir}/$${year}"
			echo "<li><a href='$${year}'>$${year}</a></li>"
		done
		echo "</ul>"
		echo "
			</section>
			</body></html>
		"
	)> "$${dir}/index.html"
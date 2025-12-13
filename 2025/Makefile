include ../makefile.defs

.PHONY: all

all: pdfs package/index.html

package/index.html: $(PDFS)
	dir="$$(dirname "$@")"
	title="Курс DevOps 2025"
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
		echo "<p>Слайды лекций:</p>"
		echo "<ul>"
		for pdf in $(PDFS); do
			name=$$(basename "$${pdf}")
			cp "$${pdf}" "$${dir}"
			echo "<li><a href='$${name}'>$${name}</a></li>"
		done
		echo "</ul>"
		echo "
			</section>
			</body></html>
		"
	)> "$${dir}/index.html"
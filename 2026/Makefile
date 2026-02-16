include ../makefile.defs

.PHONY: all

LECTURE_PDFS := $(filter-out assignments/%,$(PDFS))
ASSIGNMENT_PDFS := $(filter assignments/%,$(PDFS))

all: pdfs package/index.html

package/index.html: $(PDFS)
	dir="$$(dirname "$@")"
	title="Курс DevOps 2026"
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
		for pdf in $(LECTURE_PDFS); do
			name=$$(basename "$${pdf}")
			cp "$${pdf}" "$${dir}"
			echo "<li><a href='$${name}'>$${name}</a></li>"
		done
		echo "</ul>"
		mkdir -p "$${dir}/assignments"
		echo "<p>Методички к лабораторным работам:</p>"
		echo "<ul>"
		for pdf in $(ASSIGNMENT_PDFS); do
			name=$$(basename "$${pdf}")
			cp "$${pdf}" "$${dir}/assignments"
			echo "<li><a href='assignments/$${name}'>$${name}</a></li>"
		done
		echo "</ul>"
		echo "<p>Ведомость и варианты: <a href=\"https://docs.google.com/spreadsheets/d/1Yn1ndqJN1kfMd_l4s7Owe69pmjhxSurJq5D-Abu8_c4/edit?usp=sharing\">ОИС. DevOps 2026</a></p>"
		echo "
			</section>
			</body></html>
		"
	)> "$${dir}/index.html"
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
		mkdir -p "$${dir}/extra"
		cp extra/* "$${dir}/extra"
		echo "<p>Записи лекций:</p>"
		echo "<ul>"
		echo "<li><a href='https://disk.yandex.ru/i/Rra5ItteQ2hzdA'>Лекция 3: SSH, Туннелирование, Fast Reverse Proxy</a></li>"
		echo "<li><a href='https://disk.yandex.ru/i/x3U2zlcnubIfxA'>Лекция 4: Network Address Translation</a></li>"
		echo "<li><a href='https://disk.yandex.ru/i/wVwnqWD8rkZDPQ'>Лекция 5: Git в DevOps</a></li>"
		echo "<li><a href='https://disk.yandex.ru/i/_VeOJiuX4Rtplw'>Лекция 6: CI/CD пайплайн</a></li>"
		echo "<li><a href='https://disk.yandex.ru/i/eOyzlNKjqpFEaw'>Лекция 7: Docker часть 1</a></li>"
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
		echo "<p>Запись на лабораторные занятия:</p>"
		echo "<ul>"
		echo "<li><a href='https://docs.google.com/spreadsheets/d/1gvJdCa0G3qM1yffGW0V1X46efWsCyGss_FIsigWkqZM/edit?usp=sharing'>Запись для 6311 и 6312</a></li>"
		echo "<li><a href='https://docs.google.com/spreadsheets/d/12wzJg138y3UQszR306eBbdYeiUjwvcs1OmxCX4Hyhs4/edit?usp=sharing'>Запись для 6313</a></li>"
		echo "</ul>"
		echo "
			</section>
			</body></html>
		"
	)> "$${dir}/index.html"
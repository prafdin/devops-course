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

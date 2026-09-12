include ../makefile.defs

.PHONY: all

LECTURE_PDFS := $(filter-out assignments/%,$(PDFS))
ASSIGNMENT_PDFS := $(filter assignments/%,$(PDFS))

EXTRA_DIRS = $(shell find ./extra -mindepth 1 -maxdepth 1 -type d | sed 's|^\./||' | sort)
EXTRA_PDFS = $(foreach d,$(EXTRA_DIRS),$(d)/$(notdir $(d)).pdf)

all: pdfs extras

extras: $(EXTRA_PDFS)

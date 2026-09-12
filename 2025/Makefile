include ../makefile.defs

.PHONY: all

LECTURE_PDFS := $(filter-out assignments/% others/%,$(PDFS))
ASSIGNMENT_PDFS := $(filter assignments/%,$(PDFS))
OTHERS_PDFS := $(filter others/%,$(PDFS))

all: pdfs

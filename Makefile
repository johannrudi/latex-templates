# -----------------------------------------------------------------------------
# Makefile for compiling latex documents with `latexmk`.
#
# Author:             Johann Rudi <work@johannrudi.com>
# -----------------------------------------------------------------------------

# --------------------------------------
# SETTINGS
# --------------------------------------

# filename of main document *without* the extension ".tex"
DOC=main

# latex compiler and flags
TEXC=latexmk
# latex compiler flags
# -pdf          generate PDF directly (instead of DVI) [used below]
# -pdflatex=""  call a specific backend with specific options [used below]
# -use-make     call make for generating missing files
TEXFLAGS=-use-make
TEXFLAGSFORCE=-f
TEXFLAGSCLEAN=-C

# pdf compiler
PDFC=lualatex
# pdf compiler flags
# pdflatex and lualatex:
# -file-line-error  print compiler-like error message in the form
#                   file:line:error
# -synctex=1  synchronization with SyncTeX for forward/inverse search
# pdflatex only:
# -interactive=nonstopmode  keeps the pdflatex backend from stopping at a
#                           missing file reference and interactively asking you
#                           for an alternative
# -shell-escape  run external commands from inside the tex file
PDFFLAGS=-file-line-error -shell-escape -interaction=nonstopmode -synctex=1

# filename of handout document
HANDOUT_DOC=$(DOC)_handout

# set documents for latexdiff
DIF_DEL=$(DOC)_prev
DIF_ADD=$(DOC)
DIF_DOC=diff

# latexdiff command
DIF=latexdiff
# latexdiff flags
DIF_PREAMBLE=
ifeq ($(PDFC),lualatex)
DIF_PREAMBLE=--preamble=lualatex_diff_preamble.tex
endif
ifeq ($(PDFC),pdflatex)
DIF_PREAMBLE=--preamble=pdflatex_diff_preamble.tex
endif
DIFFLAGS=--flatten $(DIF_PREAMBLE)

# --------------------------------------
# DEFAULT RULES
# --------------------------------------

# The first rule in a Makefile is the one executed by default ("make"). It
# should always be the "all" rule, so that "make" and "make all" are identical.
.PHONY: all
all: pdf

# rule to build all pdf files
.PHONY: pdf
pdf: $(DOC).pdf

# --------------------------------------
# HELP
# --------------------------------------

.PHONY: help
help:
	echo "TODO useful help message"

# --------------------------------------
# PRE-PROCESSING
# --------------------------------------

# In case you didn't know, '$@' is a variable holding the name of the target,
# and '$<' is a variable holding the (first) dependency of a rule.
# "raw2tex" and "dat2tex" are just placeholders for whatever custom steps
# you might have.

#%.tex: %.raw
#	./raw2tex $< > $@

#%.tex: %.dat
#	./dat2tex $< > $@

# --------------------------------------
# MAIN DOCUMENTS
# --------------------------------------

# compile pdf from tex file
%.pdf: %.tex
	$(TEXC) $(TEXFLAGS) -pdf -pdflatex="$(PDFC) $(PDFFLAGS)" $<

# build beamer handout
# Note: %O before $(PDFFLAGS) seems to enable the latexmk option `-jobname=...`
#       %S is replaced by the filename
handout: $(DOC).tex
	$(TEXC) $(TEXFLAGS) -jobname="$(HANDOUT_DOC)" \
		-pdf -pdflatex="$(PDFC) %O $(PDFFLAGS) \
		'\PassOptionsToClass{handout}{beamer}\input{%S}'" $<

# --------------------------------------
# CLEAN
# --------------------------------------

# prefixes:
#   -  ignore nonzero returns
#   @  execute command silently
.PHONY: clean
clean:
	-$(TEXC) $(TEXFLAGSCLEAN) $(DOC).tex
	-$(TEXC) $(TEXFLAGSCLEAN) -jobname="$(HANDOUT_DOC)" $(DOC).tex
	-$(RM) *.bbl
	-$(RM) *.nav *.snm *.spl *.vrb
	-$(RM) *.synctex *.synctex.gz

# --------------------------------------
# LATEXDIFF
# --------------------------------------

# generate diff tex file
$(DIF_DOC).tex: $(DIF_DEL).tex $(DIF_ADD).tex
	$(DIF) $(DIFFLAGS) $^ > $@

# compile pdf from diff tex file
.PHONY: diff
diff: $(DIF_DOC).tex
	$(TEXC) $(TEXFLAGS) $(TEXFLAGSFORCE) -pdf -pdflatex="$(PDFC) $(PDFFLAGS)" $<

.PHONY: cleandiff
cleandiff:
	-$(TEXC) $(TEXFLAGSCLEAN) $(DIF_DOC).tex
	-$(RM) *.bbl
	-$(RM) *.nav *.snm *.spl *.vrb
	-$(RM) *.synctex *.synctex.gz
	$(RM) $(DIF_DOC).tex
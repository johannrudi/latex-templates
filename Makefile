# -----------------------------------------------------------------------------
# Makefile for compiling latex documents with `latexmk`.
#
# Author:             Johann Rudi <work@johannrudi.com>
# -----------------------------------------------------------------------------

# --------------------------------------
# SETTINGS
# --------------------------------------

# filename of main tex document without extension
DOC=main

# pdf compiler and flags
# pdflatex and lualatex:
# -file-line-error  print compiler-like error message in the form
#                   file:line:error
# -synctex=1  synchronization with SyncTeX for forward/inverse search
# pdflatex only:
# -interactive=nonstopmode  keeps the pdflatex backend from stopping at a
#                           missing file reference and interactively asking you
#                           for an alternative
# -shell-escape  run external commands from inside the tex file
PDFC=pdflatex
PDFFLAGS=-file-line-error -shell-escape -interaction=nonstopmode -synctex=1

# latex compiler and flags
# -pdf          generate PDF directly (instead of DVI) [used below]
# -pdflatex=""  call a specific backend with specific options [used below]
# -use-make     call make for generating missing files
TEXC=latexmk
TEXFLAGS=-use-make
TEXFLAGSCLEAN=-C

# suffix for beamer handout
HANDOUT_SUFFIX=_handout

# set arguments for latexdiff
DOC_DIFF_A=$(DOC)_prev
DOC_DIFF_B=$(DOC)
DOC_DIFF=diff

# latexdiff flags
DIFF=latexdiff
DIFF_PREAMBLE = '\
\\usepackage{xcolor,soul}\
\\definecolor{ghGreen}{HTML}{E6FFED}\
\\definecolor{ghRed}{HTML}{FFEBE9}\
\\renewcommand{\\DIFadd}[1]{\\sethlcolor{ghGreen}\\hl{\#1}}\
\\renewcommand{\\DIFdel}[1]{\\sethlcolor{ghRed}\\hl{\\textcolor{black}{\\sout{\#1}}}}\
'
DIFF_FLAGS= --flatten
#--preamble=$(DIFF_PREAMBLE)

# --------------------------------------
# GENERAL BUILD RULES
# --------------------------------------

# You want latexmk to *always* run, because make does not have all the info.
# Also, include non-file targets (e.g. all, clean) in .PHONY so they are run
# regardless of any file of the given name existing.
.PHONY: all pdf $(DOC).pdf

# The first rule in a Makefile is the one executed by default ("make"). It
# should always be the "all" rule, so that "make" and "make all" are identical.
all: pdf

# rule to build main document as pdf file
pdf: $(DOC).pdf

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

# build main document
$(DOC).pdf: $(DOC).tex
	$(TEXC) $(TEXFLAGS) -pdf -pdflatex="$(PDFC) $(PDFFLAGS)" $<

# build beamer handout
# Note: %O before $(PDFFLAGS) seems to enable the latexmk option `-jobname=...`
#       %S is replaced by the filename
handout: $(DOC).tex
	$(TEXC) $(TEXFLAGS) -jobname="$(DOC)$(HANDOUT_SUFFIX)" \
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
	-$(TEXC) $(TEXFLAGSCLEAN)
	-$(TEXC) $(TEXFLAGSCLEAN) -jobname="$(DOC)$(HANDOUT_SUFFIX)" $(DOC).tex
	-rm *.bbl 2>/dev/null || true
	-rm *.nav *.snm *.spl *.vrb 2>/dev/null || true
	-rm *.synctex *.synctex.gz 2>/dev/null || true

# --------------------------------------
# LATEX DIFF
# --------------------------------------

.PHONY: diff
diff:
	$(DIFF) $(DIFF_FLAGS) $(DOC_DIFF_A).tex $(DOC_DIFF_B).tex > $(DOC_DIFF)
	$(TEXC) $(TEXFLAGS) -f -pdf -pdflatex="$(PDFC) $(PDFFLAGS)" $(DOC_DIFF)
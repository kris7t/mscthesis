PROJECTNAME=MScThesis

LATEXMK:=latexmk

PDFLATEX_COMMAND:=pdflatex

TEXFOT:=texfot

TEXFOT_OPTS:=--quiet

PDFLATEX=$(TEXFOT) $(TEXFOT_OPTS) $(PDFLATEX_COMMAND)

PDFLATEX_OPTS:=--file-line-error --shell-escape

LATEXMK_OPTS=-pdf -pdflatex="$(PDFLATEX) $(PDFLATEX_OPTS)" -interaction=nonstopmode

SED:=sed

INKSCAPE:=inkscape

INKSCAPE_OPTS:=--without-gui

INKSCAPE_EXPORT_PDF_OPTS=$(INKSCAPE_OPTS) --export-area=drawing

GS:=gs

GS_OPTS:=-sDEVICE=pdfwrite -q -P- -dNOPAUSE -dBATCH -dCompatibilityLevel=1.4 -sDEVICE=pdfwrite -dOPM=0 -dColorConversionStrategy=/RGB -sProcessColorModel=DeviceRGB -dPDFSETTINGS=/prepress -dOptimize=true -dEmbedAllFonts=true -dCompressFonts=true -dCompressPages=true -dCannotEmbedFontPolicy=/Warning

GS_OPTIMIZE_FIGURE_OPTS=$(GS_OPTS) -dSubsetFonts=false

GS_CREATE_PDFA_OPTS=-dPDFA=2 -dPDFACompatibilityPolicy=1 $(GS_OPTS) -dSubsetFonts=true

.PHONY: all latex figures clean

CONVERT_SVG:=$(patsubst src/figures/%.svg,out/figures/%.pdf,$(wildcard src/figures/*.svg))

CONVERT_PDF:=$(patsubst src/figures/%.pdf,out/figures/%.pdf,$(wildcard src/figures/*.pdf))

all: latex docs/$(PROJECTNAME).pdf

docs/$(PROJECTNAME).pdf: src/PDFA_def.ps out/$(PROJECTNAME).pdf
	@echo "Creating PDF/A-2b: $(PROJECTNAME).pdf"
	@$(GS) $(GS_CREATE_PDFA_OPTS) -sOutputFile=$@ $^

figures: $(CONVERT_SVG) $(CONVERT_PDF)
	@true

$(CONVERT_SVG): out/figures/%.pdf: src/figures/%.svg
	@echo "Processing SVG figure: $<"
	@$(SED) 's/image-rendering="auto"/image-rendering="pixelated"/' $< > $(@:.pdf=.svg)
	@$(INKSCAPE) $(INKSCAPE_EXPORT_PDF_OPTS) --file=$(@:.pdf=.svg) --export-pdf=$@.inkscape_export
	@rm $(@:.pdf=.svg)
	@$(GS) $(GS_OPTIMIZE_FIGURE_OPTS) -sOutputFile=$@ $@.inkscape_export
	@rm $@.inkscape_export

$(CONVERT_PDF): out/figures/%.pdf: src/figures/%.pdf
	@echo "Processing PDF figure: $<"
	@$(GS) $(GS_OPTIMIZE_FIGURE_OPTS) -sOutputFile=$@ $^

latex:
	@if [ -a out/run2.pid ]; then rm -rf out; echo "============"; echo "PREVIOUS RUN WAS UNEXPECTEDLY INTERRUPTED, CLEANING OUTPUT DIRECTORY!"; echo "============"; fi
	@if [ -a out/run1.pid ]; then touch out/run2.pid; fi
	@mkdir -p out
	@touch out/run1.pid
	@mkdir -p out/include out/figures out/chapters docs
	@$(MAKE) --no-print-directory figures
	@cd src; $(LATEXMK) $(LATEXMK_OPTS) -outdir=../out -jobname=$(PROJECTNAME) main; echo $?
	@rm  out/run*.pid

jenkins: clean all

clean:
	rm -rf ./out
	rm -f ./docs/$(PROJECTNAME).pdf

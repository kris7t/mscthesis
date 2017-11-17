PROJECTNAME=MScThesis

.PHONY: all latex figures clean

CONVERT_SVG := $(patsubst src/figures/%.svg,out/figures/%.pdf,$(wildcard src/figures/*.svg))

all: latex pdf/$(PROJECTNAME).pdf

pdf/$(PROJECTNAME).pdf: out/$(PROJECTNAME).pdf src/PDFA_def.ps
	gs -sDEVICE=pdfwrite -q -P- -dNOPAUSE -dBATCH -dCompatibilityLevel=1.4 -dPDFA=2 -dPDFACompatibilityPolicy=1 -dOPM=0 -dColorConversionStrategy=/RGB -sProcessColorModel=DeviceRGB -dPDFSETTINGS=/prepress -dOptimize=true -dEmbedAllFonts=true -dSubsetFonts=true -dCompressFonts=true -dCompressPages=true -dCannotEmbedFontPolicy=/Warning -sDEVICE=pdfwrite -sOutputFile=$@ src/PDFA_def.ps $^

figures: $(CONVERT_SVG)
	@true

$(CONVERT_SVG): out/figures/%.pdf: src/figures/%.svg
	inkscape --file=$^ --export-area=drawing --without-gui --export-pdf=$@

latex:
	@if [ -a out/run2.pid ]; then rm -rf out; echo "============"; echo "PREVIOUS RUN WAS UNEXPECTEDLY INTERRUPTED, CLEANING OUTPUT DIRECTORY!"; echo "============"; fi
	@if [ -a out/run1.pid ]; then touch out/run2.pid; fi
	@mkdir -p out pdf
	@touch out/run1.pid
	@mkdir -p out out/include out/figures out/chapters pdf
	@$(MAKE) --no-print-directory figures
	@cd src; latexmk -pdf -pdflatex="texfot --quiet pdflatex --file-line-error --shell-escape" -outdir=../out -jobname=$(PROJECTNAME) -interaction=nonstopmode main; echo $?
	@rm  out/run*.pid

jenkins: clean all

clean:
	rm -rf ./out
	rm -rf ./pdf

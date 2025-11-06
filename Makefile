PACKAGE=acmart

aeh-axiom:	aeh-axiom.pdf

aeh-axiom.dvi: *.tex $(epsis)
	pdflatex -src aeh-axiom.tex
	bibtex aeh-axiom
	pdflatex -src aeh-axiom.tex
	pdflatex -src aeh-axiom.tex

aeh-axiom.ps:	aeh-axiom.dvi
	dvips -t a4 -o aeh-axiom.ps aeh-axiom.dvi

aeh-axiom.pdf:	aeh-axiom.ps
	ps2pdf aeh-axiom.ps

clean:
	rm -f *.aux *.bbl *.blg *.dvi *.log *.pdf *.ps *.thm

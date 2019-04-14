NAME=2019_ERAD_RS_Controle
all: $(NAME).pdf

%.tex: %.org
	emacs -batch -l ~/.emacs.d/init.el \
	   $^  --funcall org-babel-tangle
	emacs -batch -l ~/.emacs.d/init.el \
           --eval "(setq enable-local-eval t)" \
           --eval "(setq enable-local-variables t)" \
	   --eval "(setq org-export-babel-evaluate t)" \
	   $^  --funcall org-latex-export-to-latex

%.pdf: %.tex
	cp $(NAME).tex /tmp
	pdflatex -shell-escape $^
	bibtex `basename $^ .tex`
	pdflatex -shell-escape $^
	pdflatex -shell-escape $^
	pdflatex -shell-escape $^
# pdftops `basename $^ .tex`.pdf
# ps2pdf14 -dPDFSETTINGS=/prepress `basename $^ .tex`.ps


clean:
	rm -f $(NAME).aux $(NAME).bbl $(NAME).blg $(NAME).log $(NAME).out *~

distclean: clean
	rm -f $(NAME).html $(NAME).tex $(NAME).pdf

all: outline.pdf
clean:
	Ruby/clean.rb
.PHONY: clean
outline.pdf: outline.Rmd MA.bib
	Rscript -e 'rmarkdown::render("$<")'

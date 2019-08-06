projekt := $(shell basename `git rev-parse --show-toplevel`)
current_dir := $(shell pwd)

ifeq ($(DOCKER),TRUE)
	run:=sudo docker run --rm -dp 8787:8787 -v $(current_dir):/home/rstudio $(projekt)
	current_dir=/home/rstudio
endif

all: outline.pdf

build: Dockerfile
	sudo docker build -t $(projekt) .

clean:
	Ruby/clean.rb
	rm -rf kitematic
.PHONY: clean

outline.pdf: outline.Rmd MA.bib
	$(run) Rscript -e 'rmarkdown::render("$(current_dir)/$<")'

### Execution Environment
DOCKER=TRUE
SINGULARITY=FALSE
TORQUE=FALSE
### Location of Files ###
# A directory with one file per tasks that specifies the execution of OUTSCRIPT
INDIR = data/settings
# A script that fills INDIR
INSCRIPT = settings.R
# A directory that contains one corresponding file in OUTDIR per file in INDIR
OUTDIR = data/results
# A script that uses specifications from INDIR to generate results
OUTSCRIPT = script.R
# The used file extension for files in INDIR/OUTDIR
INSUFFIX = .txt
OUTSUFFIX = .txt

### Generall Computation Options ###
# Tasks is the first level of parallelisation
NTASKS = 4
# Cores is the second level of parallelisation which OUTSCRIPT may utilise
NCORES = 1

### Docker Options ###
# --user indicates which user to emulate
# -v which on directory the host should be accessable in the container
# the last argument is the name of the container which is the project name
DFLAGS = --rm --user $(UID) -v $(CURDIR):$(DHOME) $(PROJECT)
DCMD = run
DHOME = /home/rstudio

### Singularity Options ###
# -H is the same as -v for docker
SFLAGS = -H $(CURDIR):$(SHOME) $(PROJECT).sif
SCMD = run
SHOME = /home/rstudio

### qsub Options ###
# see tardis.mpib.berlin.mpg.de/docs
WALLTIME = 0:05:00
MEMORY = 3gb
QUEUE = default
QFLAGS = -d $(CURDIR) -q $(QUEUE) -l nodes=1:ppn=$(NCORES) -l walltime=$(WALLTIME) -l mem=$(MEMORY)

### Automatic Options ###
# the project name is assumed to be the name of the directory
PROJECT := $(strip $(notdir $(CURDIR)))# CURDIR is the place where make is executed
# for the docker permissions the user id is saved
UID = $(shell id -u)

ifeq ($(DOCKER),TRUE)
	DRUN := docker $(DCMD) $(DFLAGS)
	current_dir=/home/rstudio
endif

ifeq ($(SINGULARITY),TRUE)
	SRUN := singularity $(SCMD) $(SFLAGS)
	current_dir=/home/rstudio
endif

ifeq ($(TORQUE),TRUE)
	QRUN1 := qsub $(QFLAGS) -F "
	QRUN2 := " forward.sh
endif

RUN1 = $(QRUN1) $(SRUN) $(DRUN)
RUN2 = $(QRUN2)

all: docs/outline.pdf

build: docker

docker: Dockerfile
	docker build -t $(PROJECT) $(CURDIR)

singularity: $(PROJECT).sif

$(PROJECT).sif: docker
	singularity build $@ docker-daemon://$(PROJECT):latest

clean:
	Ruby/clean.rb
	rm -rf kitematic
.PHONY: clean

docs/outline.pdf: docs/outline.Rmd docs/MA.bib
	$(RUN1) Rscript -e 'rmarkdown::render("$(current_dir)/$<")' $(RUN2)

FROM rocker/verse:3.6.1
ARG BUILD_DATE=2019-11-11
RUN install2.r --error --skipinstalled\
  pacman here pander
RUN Rscript -e 'tinytex::tlmgr_install(c("apa6", "threeparttable", "fancyhdr", "endfloat", "csquotes", "was", "multirow", "threeparttablex", "environ", "trimspaces", "tocloft", "crop", "psnfss", "courier", "setspace"))'
WORKDIR /home/rstudio

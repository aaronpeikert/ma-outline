FROM rocker/verse:3.5.1
RUN install2.r --error --skipinstalled\
  pacman here pander
WORKDIR /home/rstudio

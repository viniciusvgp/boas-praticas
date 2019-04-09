FROM r-base:3.5.1

RUN apt update && apt -y upgrade
RUN apt -y install libxml2-dev libssl-dev libcurl4-openssl-dev libgit2-dev
RUN apt -y install libboost-dev 

# Spack
RUN apt -y install git python curl autoconf file

# DoE.base
RUN apt -y install libgmp-dev

# MPI
RUN apt -y install libopenmpi-dev

# R packages
RUN echo "install.packages(c('tidyverse', 'devtools', 'DoE.base'), repos = 'http://cran.us.r-project.org')" | R --vanilla

RUN useradd -s /bin/bash --create-home user
USER user

ENTRYPOINT /bin/bash
WORKDIR /home/user
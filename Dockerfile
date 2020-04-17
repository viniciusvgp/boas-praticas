FROM r-base:3.6.1

RUN apt update && apt -y upgrade
RUN apt -y install libxml2-dev libssl-dev libcurl4-openssl-dev libgit2-dev
RUN apt -y install libboost-dev 

# Spack
RUN apt -y install git python curl autoconf file

# DoE.base
RUN apt -y install libgmp-dev

# MPI
RUN apt -y install libopenmpi-dev

# GAWK
RUN apt -y install gawk

# Emacs and ESS
RUN apt -y install emacs ess

RUN useradd -s /bin/bash --create-home user
USER user

ENTRYPOINT /bin/bash
WORKDIR /home/user

# R packages
RUN mkdir /home/user/R
RUN echo "install.packages(c('ggplot2', 'tidyverse', 'devtools', 'DoE.base'), repos = 'https://cloud.r-project.org', lib = '/home/user/R/')" | R --vanilla

# Clone spack repository 
RUN git clone https://github.com/spack/spack.git

# Clone and add extra spack repository 
RUN git clone https://gitlab.inria.fr/solverstack/spack-repo.git
RUN ./spack/bin/spack repo add spack-repo

# Install chameleon
RUN ./spack/bin/spack install chameleon@0.9.2+starpu~mpi~cuda ^starpu@1.3.1~fast~mpi~cuda~openmp~examples

# Clean
RUN ./spack/bin/spack clean -a

# Basic Emacs init file
RUN echo "(setq org-confirm-babel-evaluate nil) \
          (setq org-babel-interpreters (quote (\"emacs-lisp\" \"python\" \"ditaa\" \"sql\" \"sh\" \"R\" \"haskell\" \"js\" \"calc\" \"mathomatic\"))) \
	  (add-to-list 'load-path \"/usr/share/emacs/site-lisp/ess/\") \
	  (org-babel-do-load-languages 'org-babel-load-languages '( (R . t) (python . t) (shell . t) (emacs-lisp t) (lisp t) (C t) (org t)))" > .emacs

# build base image
FROM rocker/tidyverse:4.0.0

# Install system dependencies
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y python3-dev python3-venv python3-pip git

# Install virtualenv and pip globally
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install virtualenv wheel

## run git cloning
RUN git clone -b update-input-params-to-umn-udall --single-branch https://github.com/itismeghasyam/mpower-feature-analysis-sage

## change work dir
WORKDIR mpower-feature-analysis

## Pull any updates
RUN git pull

## Python dependencies
RUN python3 -m venv ~/env && \
    . ~/env/bin/activate && \
    python3 -m pip install wheel && \
    python3 -m pip install -r requirements.txt && \
    python3 -m pip install git+https://github.com/Sage-Bionetworks/PDKitRotationFeatures.git && \
    python3 -m pip install numpy==1.20

## get packages from lockfile
ENV RENV_VERSION 0.13.2
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "install.packages('synapser', repos=c('http://ran.synapse.org', 'http://cran.fhcrc.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"
RUN R -e "renv::init(bare = TRUE)"
RUN R -e "renv::restore()"
RUN R -e "renv::use_python(name = '~/env', type = 'virtualenv')"

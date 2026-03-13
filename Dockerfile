############################################
# Stage 1 - Install base R and Debian dependencies
############################################
ARG R_VERSION=0.0.0
FROM rocker/r-ver:${R_VERSION} AS rbase-stage
RUN echo "Stage 1: Installing base R and Debian dependencies"

ARG GIT_USER
ARG APP_NAME
ARG APP_VERSION
ARG R_VERSION
ARG RENV_VERSION

LABEL name=${APP_NAME}
LABEL authors=${GIT_USER}
LABEL maintainer=${GIT_USER}
LABEL version=${APP_VERSION}
LABEL description="Docker image that contains My Portfolio App."

RUN apt-get update && apt-get install -y \
    cmake \
    default-libmysqlclient-dev \
    libabsl-dev \
    libcurl4-openssl-dev \
    libgdal-dev \
    libgeos-dev \
    libnetcdf-dev \
    libpng-dev \
    libproj-dev \
    libtbb-dev \
    libudunits2-dev \
    && rm -rf /var/lib/apt/lists/*

############################################
# Stage 2 - Install "renv"
############################################
FROM rbase-stage AS renv-stage
RUN echo "Stage 2: Installing 'renv'"

ARG CRAN_URL=https://cloud.r-project.org
RUN R -e "install.packages('remotes', repos = '${CRAN_URL}')"
RUN R -e "remotes::install_version('renv', version = '${RENV_VERSION}', repos = '${CRAN_URL}')"

############################################
# Stage 3 - Build environment with "renv"
############################################
FROM renv-stage AS build-env-stage
RUN echo "Stage 3: Building environment with 'renv'"

ENV MAIN_APP_DIR=/app
WORKDIR ${MAIN_APP_DIR}

# Copy only renv-related files for better layer caching.
COPY renv.lock renv.lock
COPY renv/ renv/

RUN R -e "renv::restore()"

############################################
# Stage 4 - Install project package and run Shiny
############################################
FROM build-env-stage AS shiny-app-stage
RUN echo "Stage 4: Installing project package and running Shiny"

WORKDIR ${MAIN_APP_DIR}

# Copy necessary folders and files from the project.
COPY inst ${MAIN_APP_DIR}/inst
COPY man ${MAIN_APP_DIR}/man
COPY R ${MAIN_APP_DIR}/R
COPY DESCRIPTION ${MAIN_APP_DIR}
COPY NAMESPACE ${MAIN_APP_DIR}
# Copy "renv" files from the previous stage.
COPY --from=build-env-stage ${MAIN_APP_DIR}/renv ${MAIN_APP_DIR}/renv
COPY --from=build-env-stage ${MAIN_APP_DIR}/renv.lock  ${MAIN_APP_DIR}/renv.lock

# Install your package
RUN R -e "install.packages('.', repos = NULL, type = 'source')"

EXPOSE 3838

ENV APP_PATH=${MAIN_APP_DIR}/inst/shiny/app.R
CMD ["R", "-e", "shiny::runApp(appDir = Sys.getenv('APP_PATH'), host = '0.0.0.0', port = 3838)"]

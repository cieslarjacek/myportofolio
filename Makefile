# INITIAL SETUP
# Always make sure that the correct environment is set up.
ENV_NAME := dev
ENV_FILE := $(ENV_NAME).env
GIT_USER := $(shell git config --global user.email)

APP_NAME := $(shell grep '^Package:' DESCRIPTION | cut -d ' ' -f2)
APP_VERSION := $(shell grep '^Version:' DESCRIPTION | cut -d ' ' -f2)
RENV_VERSION := $(shell jq -r '.Packages.renv.Version' renv.lock)
SHINY_VERSION := $(shell jq -r '.Packages.shiny.Version' renv.lock)

# DOCKER
IMAGE_NAME := myportfolio-$(ENV_NAME)
docker-build:
	sudo docker build --rm \
		-t $(IMAGE_NAME) -f Dockerfile . 2>&1 | tee docker_build.log

docker-rebuild:
	sudo docker build --rm \
		-t $(IMAGE_NAME) -f Dockerfile . --no-cache 2>&1 | tee docker_build.log

run-shiny:
	sudo docker run \
		-p 3838:3838 \
		--env-file .env \
		--rm -it $(IMAGE_NAME)

# FTPS
create-ftps-config:
	python scripts/create_sftp_config.py $(ENV_FILE)
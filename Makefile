# INITIAL SETUP
# Always make sure that the correct environment is set up.
ENV_NAME := dev
ENV_FILE := $(ENV_NAME).env
GIT_USER := $(shell git config --global user.email)

APP_NAME := $(shell grep '^Package:' DESCRIPTION | cut -d ' ' -f2)
APP_VERSION := $(shell grep '^Version:' DESCRIPTION | cut -d ' ' -f2)
R_VERSION := $(shell jq -r '.R.Version' renv.lock)
RENV_VERSION := $(shell jq -r '.Packages.renv.Version' renv.lock)

# DOCKER
IMAGE_NAME := $(APP_NAME)-$(ENV_NAME)
DOCKERFILE := Dockerfile
BUILD_LOGFILE := docker_build.log
REBUILD_LOGFILE := docker_rebuild.log

.PHONY: docker-build docker-rebuild run-shiny create-ftps-config

docker-build:
	@echo "Building Docker image $(IMAGE_NAME)"
	@echo "Logs: $(BUILD_LOGFILE)"

	sudo docker build --rm \
		--progress=plain \
		--build-arg GIT_USER=$(GIT_USER) \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VERSION=$(APP_VERSION) \
		--build-arg R_VERSION=$(R_VERSION) \
		--build-arg RENV_VERSION=$(RENV_VERSION) \
		--file $(DOCKERFILE) \
		--tag $(IMAGE_NAME) \
		. 2>&1 | tee $(BUILD_LOGFILE)

docker-rebuild:
	@echo "Rebuilding Docker image $(IMAGE_NAME) with no cache ..."
	@echo "Logs: $(REBUILD_LOGFILE)"

	sudo docker build --rm --no-cache \
		--progress=plain \
		--build-arg GIT_USER=$(GIT_USER) \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VERSION=$(APP_VERSION) \
		--build-arg R_VERSION=$(R_VERSION) \
		--build-arg RENV_VERSION=$(RENV_VERSION) \
		--file $(DOCKERFILE) \
		--tag $(IMAGE_NAME) \
        . 2>&1 | tee $(REBUILD_LOGFILE)

run-shiny:
	sudo docker run \
		-p 3838:3838 \
		--env-file $(ENV_FILE) \
		--rm $(IMAGE_NAME)

# FTPS
create-ftps-config:
	python scripts/create_sftp_config.py $(ENV_FILE)
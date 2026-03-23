SHELL := /bin/bash

# INITIAL SETUP
# Always make sure that the correct environment is set up.
ENV_NAME := dev
ENV_FILE := $(ENV_NAME).env
GIT_USER := $(shell git config --global user.email)

APP_MAIN_DIR := /app
APP_NAME := $(shell grep '^Package:' DESCRIPTION | cut -d ' ' -f2)
APP_VERSION := $(shell grep '^Version:' DESCRIPTION | cut -d ' ' -f2)
R_VERSION := $(shell jq -r '.R.Version' renv.lock)
RENV_VERSION := $(shell jq -r '.Packages.renv.Version' renv.lock)

# DOCKER BUILD
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
		--build-arg APP_MAIN_DIR=$(APP_MAIN_DIR) \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VERSION=$(APP_VERSION) \
		--build-arg R_VERSION=$(R_VERSION) \
		--build-arg RENV_VERSION=$(RENV_VERSION) \
		--file $(DOCKERFILE) \
		--tag $(IMAGE_NAME) \
		. \
		2>&1 | tee $(BUILD_LOGFILE)

docker-rebuild:
	@echo "Rebuilding Docker image $(IMAGE_NAME) with no cache ..."
	@echo "Logs: $(REBUILD_LOGFILE)"

	sudo docker build --rm --no-cache \
		--progress=plain \
		--build-arg GIT_USER=$(GIT_USER) \
		--build-arg APP_MAIN_DIR=$(APP_MAIN_DIR) \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VERSION=$(APP_VERSION) \
		--build-arg R_VERSION=$(R_VERSION) \
		--build-arg RENV_VERSION=$(RENV_VERSION) \
		--file $(DOCKERFILE) \
		--tag $(IMAGE_NAME) \
        . \
		2>&1 | tee $(REBUILD_LOGFILE)

# DOCKER RUN
.PHONY: run-bash run-r run-app

run-bash:
	sudo docker run \
		-p 3838:3838 \
		--env-file $(ENV_FILE) \
		--rm -it $(IMAGE_NAME) /bin/bash

run-r:
	sudo docker run \
		-p 3838:3838 \
		--env-file $(ENV_FILE) \
		--rm -it $(IMAGE_NAME) R --no-save --no-restore

run-app:
	sudo docker run \
		-p 3838:3838 \
		--env-file $(ENV_FILE) \
		--rm $(IMAGE_NAME)

# CI PIPELINE
.PHONY: ci-all

ci-all: docker-build ci-lint ci-sast ci-coverage ci-unit-test ci-integration-test ci-functional-test ci-env-test

.PHONY: ci-lint ci-sast ci-coverage ci-unit-tests ci-integration-tests ci-functional-tests ci-env-test

ci-lint:
	docker run \
		-v $(PWD)/ci:$(APP_MAIN_DIR)/ci/ \
		-v $(PWD)/.lintr:$(APP_MAIN_DIR)/.lintr \
		--rm $(IMAGE_NAME) Rscript $(APP_MAIN_DIR)/ci/lint.R \
		2>&1 | tee ci_lint.log

ci-sast:
	@echo "Running SAST check..." | tee ci_sast.log
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
		aquasec/trivy image \
		--skip-dirs "**/openssl/doc" \
		$(IMAGE_NAME) \
		2>&1 | tee -a ci_sast.log; \
	if ! grep -q "CRITICAL: 0" ci_sast.log; then \
		exit 1; \
	fi

ci-coverage:
	docker run \
		-v $(PWD)/ci:$(APP_MAIN_DIR)/ci/ \
		-v $(PWD)/tests:$(APP_MAIN_DIR)/tests/ \
		--rm $(IMAGE_NAME) Rscript $(APP_MAIN_DIR)/ci/coverage.R \
		2>&1 | tee ci_coverage.log

ci-unit-tests:
	docker run \
		-v $(PWD)/ci:$(APP_MAIN_DIR)/ci/ \
		-v $(PWD)/tests:$(APP_MAIN_DIR)/tests/ \
		--rm $(IMAGE_NAME) Rscript $(APP_MAIN_DIR)/ci/unittests.R \
		2>&1 | tee ci_unittests.log

ci-integration-tests:
	docker run --rm $(IMAGE_NAME) Rscript -e "testthat::test_dir('tests/integration')"

ci-functional-tests:
	docker run --rm $(IMAGE_NAME) Rscript -e "testthat::test_dir('tests/functional')"

ci-env-test:
	docker compose -f docker-compose.test.yml up --abort-on-container-exit --exit-code-from app



# FTPS
.PHONY: create-ftps-config

create-ftps-config:
	python scripts/create_sftp_config.py $(ENV_FILE)
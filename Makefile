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

.PHONY: docker-build docker-rebuild

ifdef CI
  DOCKER_COMMAND = docker
else
  DOCKER_COMMAND = sudo docker
endif

ifdef CI
  GHCR_CACHE_IMAGE := \
  	ghcr.io/$(shell echo $$GITHUB_REPOSITORY)/$(IMAGE_NAME):buildcache
  BUILDX_CACHE_FLAGS = \
    --cache-from type=registry,ref=$(GHCR_CACHE_IMAGE) \
    --cache-to type=registry,ref=$(GHCR_CACHE_IMAGE),mode=max
else
  BUILDX_CACHE_FLAGS =
endif

docker-build:
	@echo "Building Docker image $(IMAGE_NAME)"
	@echo "Logs: $(BUILD_LOGFILE)"

	$(DOCKER_COMMAND) buildx build --rm \
		--progress=plain \
		$(BUILDX_CACHE_FLAGS) \
		--build-arg GIT_USER=$(GIT_USER) \
		--build-arg APP_MAIN_DIR=$(APP_MAIN_DIR) \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VERSION=$(APP_VERSION) \
		--build-arg R_VERSION=$(R_VERSION) \
		--build-arg RENV_VERSION=$(RENV_VERSION) \
		--file $(DOCKERFILE) \
		--tag $(IMAGE_NAME) \
		--load \
		. \
		2>&1 | tee $(BUILD_LOGFILE)

docker-rebuild:
	@echo "Rebuilding Docker image $(IMAGE_NAME) with no cache ..."
	@echo "Logs: $(REBUILD_LOGFILE)"

	sudo docker build --rm \
		--no-cache \
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
.PHONY: run-bash run-r ssh-tunnel-open ssh-tunnel-close run-app 

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

VAULT_SSH_USER := $(shell grep '^VAULT_SSH_USER=' $(ENV_FILE) | cut -d '=' -f2)
VAULT_SSH_HOST := $(shell grep '^VAULT_SSH_HOST=' $(ENV_FILE) | cut -d '=' -f2)
VAULT_SSH_PORT := $(shell grep '^VAULT_SSH_PORT=' $(ENV_FILE) | cut -d '=' -f2)
VAULT_SSH_TUNNEL_PORT := $(shell grep '^VAULT_SSH_TUNNEL_PORT=' $(ENV_FILE) | cut -d '=' -f2)

ssh-tunnel-open:
	@echo "Opening SSH tunnel to Vault..."
	@ssh -f -N \
		-p $(VAULT_SSH_PORT) \
		-L 0.0.0.0:$(VAULT_SSH_TUNNEL_PORT):localhost:$(VAULT_SSH_TUNNEL_PORT) \
		$(VAULT_SSH_USER)@$(VAULT_SSH_HOST) \
		-o ExitOnForwardFailure=yes \
		-o StrictHostKeyChecking=no
	@echo "Tunnel opened"

ssh-tunnel-close:
	@echo "Closing SSH tunnel..."
	@pkill -f "ssh -f -N -p $(VAULT_SSH_PORT) -L $(VAULT_SSH_TUNNEL_PORT)" || true
	@echo "Tunnel closed"

run-app: ssh-tunnel-open
	$(DOCKER_COMMAND) run \
		-p 3838:3838 \
		--env-file $(ENV_FILE) \
		--add-host host.docker.internal:host-gateway \
		--rm $(IMAGE_NAME); \
	$(MAKE) ssh-tunnel-close

# LOCAL CI PIPELINE
.PHONY: ci-all ci-only-checks

ci-all: docker-build ci-linting ci-sast ci-coverage ci-unit-tests ci-integration-tests
ci-checks-only: ci-linting ci-sast ci-coverage ci-unit-tests ci-integration-tests

.PHONY: ci-linting ci-sast ci-coverage ci-unit-tests ci-integration-tests

ci-linting:
	docker run \
		-v $(PWD)/ci:$(APP_MAIN_DIR)/ci/ \
		-v $(PWD)/.lintr:$(APP_MAIN_DIR)/.lintr \
		--rm $(IMAGE_NAME) Rscript $(APP_MAIN_DIR)/ci/linting.R \
		2>&1 | tee ci_linting.log

ci-sast:
	@echo "Running SAST check..." | tee ci_sast.log
	@echo "Container image scan (Trivy)..." | tee -a ci_sast.log
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		aquasec/trivy image \
		--exit-code 1 \
		--severity HIGH,CRITICAL \
		--skip-dirs "**/openssl/doc" \
		$(IMAGE_NAME) \
		2>&1 | tee -a ci_sast.log

# TODO: TURN IT ON AFTER oysteR ISSUES WITH SONATYPE MIGRATION ARE RESOLVED.
# https://github.com/sonatype-nexus-community/oysteR/pull/82
# 	docker run \
# 		-v $(PWD)/ci:$(APP_MAIN_DIR)/ci/ \
# 		--env-file $(ENV_FILE) \
# 		--rm $(IMAGE_NAME) Rscript $(APP_MAIN_DIR)/ci/sast.R \
# 		2>&1 | tee -a ci_sast.log

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

# TODO: ADD IT.
# ci-integration-tests:
# 	docker run --rm $(IMAGE_NAME) Rscript -e "testthat::test_dir('tests/integration')"

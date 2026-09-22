SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -c

# GENERAL SETUP
# Always make sure that the correct environment is set up.
ENV_NAME := dev
ENV_FILE := $(ENV_NAME).env
GIT_USER := $(shell git config --global user.email)

APP_MAIN_DIR := /app
APP_NAME := $(shell grep '^Package:' DESCRIPTION | cut -d ' ' -f2)
APP_VERSION := $(shell grep '^Version:' DESCRIPTION | cut -d ' ' -f2)
R_VERSION := $(shell jq -r '.R.Version' renv.lock)
RENV_VERSION := $(shell jq -r '.Packages.renv.Version' renv.lock)

# DOCKER BUILD SETUP
IMAGE_NAME := $(APP_NAME)-$(ENV_NAME)
CI_IMAGE_NAME := $(APP_NAME)-ci
DOCKERFILE := Dockerfile
BUILD_LOGFILE := docker_build.log
REBUILD_LOGFILE := docker_rebuild.log

.PHONY: docker-build docker-build-ci docker-rebuild

ifdef CI
  DOCKER_COMMAND := docker
else
  DOCKER_COMMAND := sudo -E docker
endif

ifdef CI
  GHCR_CACHE_IMAGE := \
  	ghcr.io/$(shell echo $$GITHUB_REPOSITORY)/$(IMAGE_NAME):buildcache
  BUILDX_CACHE_FLAGS := \
    --cache-from type=registry,ref=$(GHCR_CACHE_IMAGE) \
    --cache-to type=registry,ref=$(GHCR_CACHE_IMAGE),mode=max
else
  BUILDX_CACHE_FLAGS :=
endif

# Export variables for docker-compose.
export APP_MAIN_DIR
export CI_IMAGE_NAME
export ENV_FILE
export IMAGE_NAME

# DOCKER BUILD
# Production image.
docker-build:
	@echo "Building Docker image $(IMAGE_NAME)..."
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

# CI image.
docker-build-ci:
	@echo "Building CI Docker image $(CI_IMAGE_NAME)..."
	@echo "Logs: $(BUILD_LOGFILE)"
	$(DOCKER_COMMAND) buildx use default
	$(DOCKER_COMMAND) compose --profile ci build --pull=false ci \
		2>&1 | tee -a $(BUILD_LOGFILE)


docker-rebuild:
	@echo "Rebuilding Docker image $(IMAGE_NAME) with no cache..."
	@echo "Logs: $(REBUILD_LOGFILE)"
	$(DOCKER_COMMAND) buildx build --rm \
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
		--load \
		. \
		2>&1 | tee $(REBUILD_LOGFILE)

# LOCAL CI PIPELINE
.PHONY: ci-all ci-only-checks

ci-all: docker-build docker-build-ci ci-linting ci-sast ci-coverage ci-unit-tests ci-integration-tests
ci-checks-only: ci-linting ci-sast ci-coverage ci-unit-tests ci-integration-tests

ci-linting:
	$(DOCKER_COMMAND) compose --profile ci run --rm ci \
		Rscript $(APP_MAIN_DIR)/ci/linting.R \
		2>&1 | tee ci_linting.log

# Refresh version and digest SHA with:
#	docker run --rm aquasec/trivy:latest --version
#   docker buildx imagetools inspect aquasec/trivy:<version> --format '{{.Manifest.Digest}}'
TRIVY_IMAGE := aquasec/trivy:0.69.3@sha256:bcc376de8d77cfe086a917230e818dc9f8528e3c852f7b1aff648949b6258d1c

ci-sast:
	@echo "Running SAST check..." | tee ci_sast.log
	@echo "Container image scan (Trivy)..." | tee -a ci_sast.log
	$(DOCKER_COMMAND) run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		$(TRIVY_IMAGE) image \
		--exit-code 1 \
		--severity HIGH,CRITICAL \
		--ignore-unfixed \
		--skip-dirs "**/openssl/doc" \
		$(IMAGE_NAME) \
		2>&1 | tee -a ci_sast.log
# TODO: TURN IT ON AFTER oysteR ISSUES WITH SONATYPE MIGRATION ARE RESOLVED.
# https://github.com/sonatype-nexus-community/oysteR/pull/82
#	$(DOCKER_COMMAND) compose --profile ci run --rm ci \
#		Rscript $(APP_MAIN_DIR)/ci/sast.R \
#		2>&1 | tee -a ci_sast.log

ci-coverage:
	$(DOCKER_COMMAND) compose --profile ci run --rm ci \
		Rscript $(APP_MAIN_DIR)/ci/coverage.R \
		2>&1 | tee ci_coverage.log

ci-unit-tests:
	$(DOCKER_COMMAND) compose --profile ci run --rm ci \
		Rscript $(APP_MAIN_DIR)/ci/unittests.R \
		2>&1 | tee ci_unittests.log

# TODO: ADD IT.
# ci-integration-tests:
# 	$(DOCKER_COMMAND) compose --profile ci run --rm ci \
# 		Rscript -e "testthat::test_dir('tests/integration')"

# DOCKER RUN
.PHONY: run-bash run-r ssh-tunnel-open ssh-tunnel-close run-app 

run-bash:
	$(DOCKER_COMMAND) compose --profile ci run --rm ci /bin/bash

run-r:
	$(DOCKER_COMMAND) compose --profile ci run --rm ci R --no-save --no-restore

MINIO_SSH_TUNNEL_PORT  = $(shell grep '^MINIO_SSH_TUNNEL_PORT=' $(ENV_FILE) | cut -d '=' -f2)
DOCKER_TUNNEL_BIND = $(shell grep '^DOCKER_TUNNEL_BIND=' $(ENV_FILE) | cut -d '=' -f2)
VAULT_SSH_USER = $(shell grep '^VAULT_SSH_USER=' $(ENV_FILE) | cut -d '=' -f2)
VAULT_SSH_HOST = $(shell grep '^VAULT_SSH_HOST=' $(ENV_FILE) | cut -d '=' -f2)
VAULT_SSH_PORT = $(shell grep '^VAULT_SSH_PORT=' $(ENV_FILE) | cut -d '=' -f2)
VAULT_SSH_TUNNEL_PORT = $(shell grep '^VAULT_SSH_TUNNEL_PORT=' $(ENV_FILE) | cut -d '=' -f2)

# Control socket for the tunnel. Lets "ssh-tunnel-close" terminate exactly the
# connection "ssh-tunnel-open" created, instead of killing whatever process
# happens to hold the port number.
TUNNEL_CTL := $(HOME)/.ssh/myportfolio-tunnel.ctl

# Forwards:
#   172.17.0.1:8200, :9000 - docker0 gateway for "make run-app"
#							 (container, LOCAL_RUN=false, config from tha vault).
#   127.0.0.1:9000         - loopback for native RStudio runs
#							 (local code, LOCAL_RUN=true, config from "dev.env").
ssh-tunnel-open:
	@if [ -S $(TUNNEL_CTL) ] && ssh -S $(TUNNEL_CTL) -O check $(VAULT_SSH_USER)@$(VAULT_SSH_HOST) 2>/dev/null; then \
		echo "Tunnel already open"; exit 0; \
	fi; \
	rm -f $(TUNNEL_CTL); \
	echo "Opening SSH tunnel to Vault and MinIO..."; \
	ssh -f -N -M -S $(TUNNEL_CTL) \
		-p $(VAULT_SSH_PORT) \
		-L $(DOCKER_TUNNEL_BIND):$(VAULT_SSH_TUNNEL_PORT):localhost:$(VAULT_SSH_TUNNEL_PORT) \
		-L $(DOCKER_TUNNEL_BIND):$(MINIO_SSH_TUNNEL_PORT):localhost:$(MINIO_SSH_TUNNEL_PORT) \
		-L 127.0.0.1:$(MINIO_SSH_TUNNEL_PORT):localhost:$(MINIO_SSH_TUNNEL_PORT) \
		$(VAULT_SSH_USER)@$(VAULT_SSH_HOST) \
		-o ExitOnForwardFailure=yes \
		-o StrictHostKeyChecking=yes && \
	echo "Tunnel opened"

ssh-tunnel-close:
	@if [ -S $(TUNNEL_CTL) ]; then \
		ssh -S $(TUNNEL_CTL) -O exit $(VAULT_SSH_USER)@$(VAULT_SSH_HOST) 2>/dev/null; \
		rm -f $(TUNNEL_CTL); \
		echo "Tunnel closed"; \
	else \
		echo "No tunnel control socket; nothing to close"; \
	fi

# IMPORTANT: Run only with "LOCAL_RUN=false" in ".env" file.
# IMPORTANT: Remember to update "VAULT_TOKEN" in ".env" file.
run-app: ssh-tunnel-open
	$(DOCKER_COMMAND) compose -f docker-compose.yaml -f docker-compose.local.yaml up shiny-app; \
	make ssh-tunnel-close
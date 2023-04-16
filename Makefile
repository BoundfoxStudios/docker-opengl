# !/usr/bin/make - f

SHELL                   := /usr/bin/env bash
SED                     := $(shell [[ `command -v gsed` ]] && echo gsed || echo sed)
REPO_API_URL            ?= https://hub.docker.com/v2
REPO_NAMESPACE          ?= boundfoxstudios
REPO_USERNAME           ?= boundfoxstudios
IMAGE_NAME              ?= opengl
BASE_IMAGE              ?= alpine:edge
LLVM_VERSION            ?= 15
TAG_SUFFIX              ?= $(shell echo "-$(BASE_IMAGE)" | $(SED) 's|:|-|g' | $(SED) 's|/|_|g' 2>/dev/null )
VCS_REF                 := $(shell git rev-parse --short HEAD)
BUILD_DATE              := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
PLATFORM                ?= 
RELEASES                ?= latest stable
STABLE                  ?= 22.3.7
LATEST                  ?= 23.0.0
BUILD_PROGRESS          ?= auto
BUILD_OUTPUT            ?= type=registry
BUILD_TYPE              ?= release
BUILD_OPTIMIZATION      ?= 3

# Default target is to build all defined Mesa releases.
.PHONY: default
default: $(STABLE)

.PHONY: all
all: $(RELEASES)

# Build base images for all releases using buildx.
.PHONY: $(RELEASES)
.SILENT: $(RELEASES)
export BUILD_OUTPUT
$(RELEASES):
	if [ "$(@)" == "stable" ]; \
	then \
		MESA_VERSION="$(STABLE)"; \
	elif [ "$(@)" == "latest" ]; \
	then \
		MESA_VERSION="$(LATEST)"; \
	else \
		MESA_VERSION="$(@)"; \
	fi; \
	docker buildx build \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg BUILD_OPTIMIZATION=$(BUILD_OPTIMIZATION) \
		--build-arg BUILD_TYPE=$(BUILD_TYPE) \
		--build-arg LLVM_VERSION=$(LLVM_VERSION) \
		--build-arg MESA_VERSION="$$MESA_VERSION"  \
		--build-arg VCS_REF=$(VCS_REF) \
		--cache-from $(REPO_NAMESPACE)/$(IMAGE_NAME):$(@)$(TAG_SUFFIX) \
		--tag $(REPO_NAMESPACE)/$(IMAGE_NAME):$(@)$(TAG_SUFFIX) \
		--tag $(REPO_NAMESPACE)/$(IMAGE_NAME):$(@) \
		--platform=$(PLATFORM) \
		--progress=$(BUILD_PROGRESS) \
		--output=$(BUILD_OUTPUT) \
		--file Dockerfile .
	
# Update README on DockerHub registry.
.PHONY: push-readme
.SILENT: push-readme
push-readme:
	echo "Authenticating to $(REPO_API_URL)"; \
		token=$$(curl -s -X POST -H "Content-Type: application/json" -d '{"username": "$(REPO_USERNAME)", "password": "'"$$REPO_PASSWORD"'"}' $(REPO_API_URL)/users/login/ | jq -r .token); \
		code=$$(jq -n --arg description "$$(<README.md)" '{"registry":"registry-1.docker.io","full_description": $$description }' | curl -s -o /dev/null  -L -w "%{http_code}" $(REPO_API_URL)/repositories/$(REPO_NAMESPACE)/$(IMAGE_NAME)/ -d @- -X PATCH -H "Content-Type: application/json" -H "Authorization: JWT $$token"); \
		if [ "$$code" != "200" ]; \
		then \
			echo "Failed to update README.md"; \
			exit 1; \
		else \
			echo "Success"; \
		fi;

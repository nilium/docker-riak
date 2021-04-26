DOCKER ?= docker
DOCKER_REGISTRY ?= ghcr.io/nilium
DOCKER_IMAGE ?= riak
DOCKER_TAG ?= latest

DOCKER_FLAGS ?=

.PHONY: all docker

all: docker

docker:
	$(DOCKER) build $(DOCKER_FLAGS) -t "$(DOCKER_REGISTRY)/$(DOCKER_IMAGE):$(DOCKER_TAG)" .

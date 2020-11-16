.PHONY: default build auto-build-and-push


PLATFORMS ?= linux/amd64,linux/arm64
DOCKER_IMAGE ?= raquette/heketi
VERSION ?= "edge"

MANIFEST_TAG = $(DOCKER_IMAGE):$(VERSION)

default: build

auto-build-and-push:
	docker buildx build  --push --platform $(PLATFORMS) -t "$(MANIFEST_TAG)"  --build-arg VERSION=${VERSION} -f Dockerfile . 

build:
	docker buildx build --platform $(PLATFORMS) -t "$(MANIFEST_TAG)"  --build-arg VERSION=${VERSION} -f Dockerfile . 

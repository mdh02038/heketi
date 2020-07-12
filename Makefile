# note: call scripts from /scripts

.PHONY: default binary-image clean-images clean push release release-all manifest clean-image clean

OS ?= linux
ARCH ?= ??? 
ALL_ARCH ?= arm64 amd64
DOCKER_IMAGE ?= raquette/heketi
TAG ?= v1.0.0
REPOSITORY_GENERIC = ${DOCKER_IMAGE}:${TAG}
REPOSITORY_ARCH = ${DOCKER_IMAGE}:${TAG}-${ARCH}

default: binary-images

binary-image: 
	docker buildx build --pull --platform ${OS}/${ARCH} -t "${REPOSITORY_ARCH}"  -f Dockerfile . 

binary-images:
	(set -e ; $(foreach arch,$(ALL_ARCH), \
		make release ARCH=${arch} ; \
	))

push:
	docker push ${REPOSITORY_ARCH}

release:  binary-image push manifest

release-all:
	-rm -rf ~/.docker/manifests/*
	(set -e ; $(foreach arch,$(ALL_ARCH), \
		make release ARCH=${arch} ; \
	))
	(set -e ; \
                docker manifest push --purge $(REPOSITORY_GENERIC); \
	)

manifest:
	(set -e ; \
		docker manifest create -a $(REPOSITORY_GENERIC) $(REPOSITORY_ARCH); \
		docker manifest annotate --arch $(ARCH) $(REPOSITORY_GENERIC)  $(REPOSITORY_ARCH); \
	)


clean-images:
	(set -e ; $(foreach arch,$(ALL_ARCH), \
	    make clean-image ARCH=${arch};  \
	))
	-docker rmi "${REPOSITORY_GENERIC}"

clean-image: 
	-docker rmi "${REPOSITORY_ARCH}" 
	-rm -rf ~/.docker/manifests/*

clean: clean-images
	-rm syslinux.tar


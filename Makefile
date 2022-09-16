CONTAINER_REGISTRY?="quay.io/fromani"
CONTAINER_IMAGE?="ebpf-debugtools"

RELEASE_SEQUENTIAL?=01
RELEASE_VERSION?=devel-v0.0.$(shell date +%Y%m%d)$(RELEASE_SEQUENTIAL)

.PHONY: all
all: image manifests

.PHONY: manifests
manifests: daemonset.yaml.tmpl
	env CONTAINER_IMAGE="$(CONTAINER_REGISTRY)/$(CONTAINER_IMAGE):$(RELEASE_VERSION)" sh -c "envsubst < daemonset.yaml.tmpl > daemonset.yaml"

.PHONY: image
image:
	podman build -f Dockerfile -t $(CONTAINER_REGISTRY)/$(CONTAINER_IMAGE):$(RELEASE_VERSION) .

.PHONY: push
push:
	podman push $(CONTAINER_REGISTRY)/$(CONTAINER_IMAGE):$(RELEASE_VERSION)

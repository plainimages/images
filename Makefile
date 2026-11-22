NAME     ?= spicedb
VERSION  ?= v1.57.1
ARCH     ?= $(shell uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/')
REGISTRY ?= ghcr.io/plainimages
IMAGE    := $(REGISTRY)/$(NAME)-apko:$(VERSION)-$(ARCH)

KEY      ?= keys/melange.rsa
OUT      := output/$(NAME)-$(ARCH).tar

.DEFAULT_GOAL := help
.PHONY: help keygen package image test run all clean

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-8s %s\n", $$1, $$2}'
	@echo
	@echo "  Image: $(IMAGE)"

keygen: ## Generate a local melange signing key (once per machine)
	@mkdir -p keys
	melange keygen $(KEY)

package: ## Build the APK with melange
	melange build images/$(NAME)/melange.yaml --signing-key $(KEY) --arch $(ARCH)

image: ## Build the image with apko and load it into Docker
	@mkdir -p output
	apko build images/$(NAME)/apko.yaml $(IMAGE) $(OUT) -k $(KEY).pub --arch $(ARCH)
	docker load -i $(OUT) | tee /dev/stderr | sed -n 's/^Loaded image: //p' | xargs -I{} docker tag {} $(IMAGE)

test: ## Smoke-test the loaded image (gRPC health check)
	./scripts/smoke-test.sh $(IMAGE)

run: ## Run SpiceDB in testing mode on localhost:50051
	docker run --rm -p 50051:50051 $(IMAGE) serve-testing --skip-release-check

all: package image test ## Build package + image, then test

clean: ## Remove build outputs
	rm -rf output packages

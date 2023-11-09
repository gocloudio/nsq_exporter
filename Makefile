BUILD_DIR = build

GO       = go
GOX      = gox
GOX_ARGS = -output="$(BUILD_DIR)/{{.Dir}}_{{.OS}}_{{.Arch}}" -osarch="linux/amd64 linux/386 linux/arm linux/arm64 darwin/amd64 freebsd/amd64 freebsd/386 windows/386 windows/amd64"

.PHONY: build
build:
	$(GO) build -o $(BUILD_DIR)/nsq_exporter .

.PHONY: deps-init deps-get
deps-init:
	@go get -u github.com/kardianos/govendor
	$(GOPATH)/bin/govendor init

deps-get: deps-init
	@$(GOPATH)/bin/govendor get github.com/gocloudio/nsq_exporter

.PHONY: clean
clean:
	rm -R $(BUILD_DIR)/* || true

.PHONY: test
test:
	$(GO) test ./...

.PHONY: release-build
release-build:
	@go get -u github.com/mitchellh/gox
	@$(GOX) $(GOX_ARGS) github.com/gocloudio/nsq_exporter

REPO ?= registry.ap-northeast-1.aliyuncs.com/gocloudio
TAG ?= latest
IMAGE_PREFIX := $(REPO)/
.PHONY: build-image
build-image: IMAGE = $(IMAGE_PREFIX)nsq_exporter:$(TAG)
build-image:
	echo $(IMAGE) > .image-label
	DOCKER_BUILDKIT=1 docker buildx build --platform linux/arm64,linux/amd64 -t $(IMAGE) \
		-f Dockerfile . --push

BIN_DIR := $(shell pwd)/bin

# Tool versions
# https://github.com/rust-lang/mdBook/releases
MDBOOK_VERSION = 0.5.4
MDBOOK_SHA256 = 3f28de05dafca9d0f2eab99c662116b0e37b89b1d96a08f8f430b9eeae958cd7
MDBOOK := $(BIN_DIR)/mdbook

.PHONY: all
all: lint test

.PHONY: book
book: $(MDBOOK)
	rm -rf docs/book
	cd docs; $(MDBOOK) build

.PHONY: lint
lint:
	test -z "$$(go tool goimports -l -local $$(go list -m) . | tee /dev/stderr)"
	go tool staticcheck ./...
	go vet ./...

.PHONY: test
test:
	go test -race -count=1 -v ./...

$(MDBOOK):
	mkdir -p $(BIN_DIR)
	tmp=$$(mktemp -d); \
	trap 'rm -rf "$$tmp"' EXIT; \
	curl -fsL -o "$$tmp/mdbook.tar.gz" https://github.com/rust-lang/mdBook/releases/download/v$(MDBOOK_VERSION)/mdbook-v$(MDBOOK_VERSION)-x86_64-unknown-linux-gnu.tar.gz && \
	echo "$(MDBOOK_SHA256)  $$tmp/mdbook.tar.gz" | sha256sum -c - && \
	tar -C $(BIN_DIR) -xzf "$$tmp/mdbook.tar.gz"

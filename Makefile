APP_NAME ?= DVTver
BINARY_NAME ?= bin/$(APP_NAME)
MAIN_PATH ?= ./cmd
VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_TIME ?= $(shell date -u '+%Y-%m-%d_%H:%M:%S')
LDFLAGS ?= -ldflags "-X main.Version=%(VERSION) -X main.BuildTime=$(BUILD_TIME)"

GOFILES ?= $(shell find . -name "*.go" -type f -not -path "./vendor/*" -not -path "./.git/*")

.DEFAULT_GOAL := build

build:
	@echo "Building $(APP_NAME)..."
	@mkdir -p bin
	go build $(LDFLAGS) -o $(BINARY_NAME) $(MAIN_PATH)

run: build
	@echo "Running $(APP_NAME)..."
	./$(BINARY_NAME)

run-only:
	@echo "Running $(APP_NAME)..."
    ./$(BINARY_NAME)

deps:
	@echo "Installing dependencies..."
	go mod download
	go mod tidy

deps-update:
	@echo "Updating dependencies..."
	go get -u ./...
	go mod tidy

fmt:
	@echo "Formatting code..."
	gofmt -s -w $(GOFILES)
	gofumpt -l -w -s $(GOFILES)
	goimports -l -w $(GOFILES)

lint:
	@echo "Running linter..."
	golangci-lint run --timeout=10m -v ./...

test:
	@echo "Running tests..."
	go test -v ./...

test-coverage:
	@echo "Running tests with coverage..."
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

bench:
	@echo "Running benchmarks..."
	go test -bench=. ./...

clean:
	@echo "Cleaning build artifacts..."
	rm -rf bin/
	rm -f coverage.out coverage.html

install: build
	@echo "Installing $(APP_NAME)..."
	go install $(LDFLAGS) $(MAIN_PATH)

docs:
	@echo "Generating documentation..."
	godoc -http=:6060

help:
	@echo "Available targets:"
	@echo " build                 - Build the application"
	@echo " run                   - Build and run the application"
	@echo " run-only              - Run the application (without building)"
	@echo " deps                  - Install dependencies"
	@echo " deps-update            - Update dependencies"
	@echo " fmt                    - Format code"
	@echo " lint                   - Run linter"
	@echo " test                   - Run tests"
	@echo " test-coverage          - Run tests with coverage report"
	@echo " bench                  - Run benchmarks"
	@echo " clean                  - Clean build artifacts"
	@echo " install                - Install the application"
	@echo " docs                   - Generate documentation"
	@echo " help                   - Show this help"

dev: fmt lint test build

ci: deps fmt lint test build

.PHONY: build run run-only deps deps-update fmt lint test test-coverage bench clean install docs help dev ci


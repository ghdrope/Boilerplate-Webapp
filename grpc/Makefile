# === Utility-style Makefile for Go gRPC Project ===

# Test Coverage Threshold
MIN_COVERAGE ?= 0

.PHONY: server client lint

# === Compose Commands ===

ci_workflow_test: ## Run full CI test suite (lint/build/test)
	make lint
	make format-check
	make build
	make test
	make coverage

fix: ## Fix formatting issues
	make format

# === App lifecycle ===

compose-dev: ## Start all services in development environment but as production mode with docker-compose
	docker-compose -f ../compose/docker-compose-dev.yaml up --build

compose-dev-down: ## Stop all services in development environment
	docker-compose -f ../compose/docker-compose-dev.yaml down

# === App lifecycle ===

server: ## Run the gRPC server locally in development mode
	ENV=dev go run ./server

client: ## Run the gRPC client to test the server
	go run ./client

preview: build-server ## Build and run the gRPC server in production mode
	./bin/server

# === Build lifecycle ===

build: clean ## Build the gRPC server binary
	go build -o bin/grpc-server ./server

build-server: clean ## Build the gRPC server binary
	go build -o ./bin/server ./server

build-client: clean ## Build the gRPC client binary
	go build -o ./bin/client ./client

# === Tests ===

test: ## Run Go tests
	go test ./...

coverage: ## Run tests with coverage and enforce minimum coverage
	go test -coverprofile=coverage.out ./...
	@coverage=$$(go tool cover -func=coverage.out | grep total: | awk '{print substr($$3, 1, length($$3)-1)}'); \
	minimum=$(MIN_COVERAGE); \
	if (( $$(echo "$$minimum > 0" | bc -l) )); then \
		result=$$(echo "$$coverage >= $$minimum" | bc); \
		if [ $$result -eq 1 ]; then \
			echo "Coverage $$coverage% >= $$minimum% ✔"; \
		else \
			echo "Coverage $$coverage% < $$minimum% ✘"; \
			exit 1; \
		fi; \
	else \
		echo "Coverage $$coverage% (no minimum enforced)"; \
	fi

# === Quality ===

lint: ## Run golangci-lint
	golangci-lint run ./...

format: ## Format code with gofmt
	gofmt -w ./server ./client

format-check: ## Check code formatting
	gofmt -l ./server ./client
	test -z "$(gofmt -l ./server ./client)"

# === Cleanup ===

clean: ## Clean build artifacts, and test coverage reports
	rm -rf bin/ coverage.out

# === Help ===

help: ## Show available commands
	@grep -E '^[a-zA-Z0-9:_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
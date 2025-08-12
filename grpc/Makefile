# === Utility-style Makefile for Go gRPC Project ===

# Test Coverage Threshold
MIN_COVERAGE ?= 75

.PHONY: server client lint format format-check clean \
        test test-unit test-integration \
        ci_workflow_test fix \
        compose-dev compose-dev-down preview \
        build build-server build-client help \
        grpc-list-services grpc-list-methods grpc-describe grpc-call \
		sast-audit

# === Compose Commands ===

ci_workflow_test_push: ## Run full CI feature branches push test suite (format/lint/build/unit test/coverage)
	make lint
	make format-check
	make clean
	make build
	make test-unit

ci_workflow_test_pr: clean build ## Run full CI feature branches PR to development test suite (integration test)
	make test-integration

sast_workflow_test_pr: clean build ## Run full SAST test suite
	make sast-audit
	make sast-trivy-fs
	make sast-trivy-dockerfile

fix: ## Fix formatting issues
	make format

# === Docker Compose ===

app-dev: ## Start all services in development environment but as production mode with docker-compose
	docker-compose -f ../compose/docker-compose-dev.yaml up --build

app-dev-down: ## Stop all services in development environment
	docker-compose -f ../compose/docker-compose-dev.yaml down

# === App lifecycle ===

server: ## Run the gRPC server locally in development mode
	ENV=dev go run ./cmd/server

client: ## Run the gRPC client to test the server
	go run ./cmd/client

preview: build-server ## Build and run the gRPC server in production mode
	./bin/server

app-dev: clean compose-dev ## Run app in development environment but as production mode

app-dev-down: compose-dev-down ## Stop app in development environment but as production mode

# === Build lifecycle ===

build: clean ## Build the gRPC server binary
	go build -o bin/grpc-server ./cmd/server

build-server: clean ## Build the gRPC server binary
	go build -o ./bin/server ./cmd/server

build-client: clean ## Build the gRPC client binary
	go build -o ./bin/client ./cmd/client

# === Tests ===

test: test-unit test-integration ## Run all tests (unit + integration) with coverage + threshold (only unit)
	@echo "✔ All tests passed."

test-unit: ## Run unit tests only with coverage and enforce threshold
	go test -coverprofile=coverage.out ./internal/...
	@coverage=$$(go tool cover -func=coverage.out | grep total: | awk '{print substr($$3, 1, length($$3)-1)}'); \
	minimum=$(MIN_COVERAGE); \
	if (( $$(echo "$$minimum > 0" | bc -l) )); then \
		result=$$(echo "$$coverage >= $$minimum" | bc); \
		if [ $$result -eq 1 ]; then \
			echo "Unit test coverage $$coverage% >= $$minimum% ✔"; \
		else \
			echo "Unit test coverage $$coverage% < $$minimum% ✘"; \
			exit 1; \
		fi; \
	else \
		echo "Unit test coverage $$coverage% (no minimum enforced)"; \
	fi

test-integration: ## Run integration tests only (no coverage, no threshold)
	go test ./tests/integration/...

# === Quality ===

lint: ## Run golangci-lint
	golangci-lint run ./...

format: ## Format code with gofmt
	gofmt -w ./cmd ./internal

format-check: ## Check code formatting
	@if [ -n "$$(gofmt -l ./cmd ./internal)" ]; then \
		echo "Formatting issues found:"; \
		gofmt -l ./cmd ./internal; \
		exit 1; \
	fi

# === Security Scans ===

sast-audit: ## Run Go vulnerability scan with govulncheck
	@go run golang.org/x/vuln/cmd/govulncheck@v1.1.4 -json ./... > govulncheck-report.json

sast-trivy-fs: ## Run Trivy filesystem scan
	trivy fs --severity HIGH,CRITICAL --scanners vuln,secret .

sast-trivy-dockerfile: ## Run Trivy Dockerfile config scan
	trivy config --severity HIGH,CRITICAL ../docker/grpc.dockerfile

# === Cleanup ===

clean: ## Clean build artifacts, and test coverage reports
	rm -rf bin/ coverage.out govulncheck-report.json
	go clean -testcache

# === Help ===

help: ## Show available commands
	@grep -E '^[a-zA-Z0-9:_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

#
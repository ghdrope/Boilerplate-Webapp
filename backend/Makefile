# === Utility-style Makefile for Kotlin/Gradle Backend ===

# === Composite Commands ===

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

fix: ## Fix formatting issues with Spotless
	make format

# === Docker Compose ===

compose-dev: ## Start all services in development environment but as production mode with docker-compose
	docker-compose -f ../compose/docker-compose-dev.yaml up --build

compose-dev-down: ## Stop all services in development environment
	docker-compose -f ../compose/docker-compose-dev.yaml down

# === App lifecycle ===

dev: clean ## Run the Spring Boot app in dev mode with 'local' profile
	SPRING_PROFILES_ACTIVE=local ./gradlew bootRun

preview: clean build ## Build and run the Spring Boot app in production mode
	@jarfile=$$(ls build/libs/*.jar | head -n 1) && java -jar "$$jarfile" --spring.profiles.active=local

app-dev: clean compose-dev ## Run app in development environment but as production mode

app-dev-down: compose-dev-down ## Stop app in development environment but as production mode

# === Build lifecycle ===

build: clean ## Clean and build the project
	./gradlew bootJar

# === Tests and Coverage ===

test: clean ## Run all tests (unit + integration) with coverage
	./gradlew test

test-unit: clean ## Run only unit tests with coverage
	./gradlew testUnit jacocoTestReport

test-integration: clean ## Run only integration tests (no coverage)
	./gradlew testIntegration

coverage: ## Generate test coverage report (Jacoco)
	./gradlew jacocoTestReport

# === Quality ===

lint: ## Run static analysis with Detekt
	./gradlew detekt

format: ## Apply code formatting with Spotless
	./gradlew spotlessApply

format-check: # Check code formatting without applying changes
	./gradlew spotlessCheck

# === Security Scans ===

sast-audit: ## Run OWASP Dependency-Check scan
	./gradlew dependencyCheckAnalyze

sast-trivy-fs: ## Run Trivy filesystem scan
	./gradlew trivyFsScan

sast-trivy-dockerfile: ## Run Trivy Dockerfile config scan
	./gradlew trivyDockerfileScan

# === Cleanup ===

clean: ## Clean build artifacts and caches
	./gradlew clean

# === Help ===

help: ## Show available commands
	@grep -E '^[a-zA-Z0-9:_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
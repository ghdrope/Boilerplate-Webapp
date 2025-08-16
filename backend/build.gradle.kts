plugins {
    // Spring Boot and Kotlin plugins
    id("org.springframework.boot") version "3.5.4"
    id("io.spring.dependency-management") version "1.1.4"
    kotlin("jvm") version "2.0.21"
    kotlin("plugin.spring") version "2.0.0"

    // Quality tools
    id("io.gitlab.arturbosch.detekt") version "1.23.8"
    id("com.diffplug.spotless") version "7.2.1"
    jacoco

    // OWASP Dependency-Check plugin for vulnerability scanning
    id("org.owasp.dependencycheck") version "12.1.2"
}

group = "ghdrope.boilerplate"
version = "0.0.5"
java.sourceCompatibility = JavaVersion.VERSION_21

kotlin {
    // Use JDK 21 toolchain for Kotlin compilation
    jvmToolchain(21)
}

repositories {
    mavenCentral()
}

dependencies {
    // Spring Boot starters for web and actuator endpoints
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-actuator")

    // Kotlin reflection and Jackson Kotlin module for JSON serialization/deserialization
    implementation("org.jetbrains.kotlin:kotlin-reflect")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")

    // Spring Boot starter test excluding legacy JUnit 4 engine
    testImplementation("org.springframework.boot:spring-boot-starter-test") {
        exclude(group = "org.junit.vintage", module = "junit-vintage-engine")
    }
}

tasks.withType<Test> {
    // Use JUnit Platform (JUnit 5) for all tests
    useJUnitPlatform()
}

// === Jacoco configuration tool configuration ===
jacoco {
    toolVersion = "0.8.13"  // Specify Jacoco version explicitly
}

// Task for running unit tests only (excludes integration tests tagged as "integration")
tasks.register<Test>("testUnit") {
    description = "Run only unit tests (excluding integration tests)"
    useJUnitPlatform {
        excludeTags("integration")
    }
    finalizedBy(
        tasks.jacocoTestReport,
        tasks.jacocoTestCoverageVerification
    )
}

// Task for running only integration tests (tests tagged with "integration")
tasks.register<Test>("testIntegration") {
    description = "Run only integration tests"
    useJUnitPlatform {
        includeTags("integration")
    }
}

// Default test task runs all tests and triggers coverage report generation
tasks.test {
    useJUnitPlatform()
    finalizedBy(
        tasks.jacocoTestReport,
        tasks.jacocoTestCoverageVerification
    )
}

// Jacoco HTML coverage report generation
tasks.jacocoTestReport {
    dependsOn(tasks.named("testUnit"))  // Run unit tests first

    reports {
        html.required.set(true)
        xml.required.set(false)
        csv.required.set(false)
    }

    // Exclude main Spring Boot application class from coverage report
    classDirectories.setFrom(
        files(
            fileTree(buildDir.resolve("classes/java/main")) {
                exclude("ghdrope/boilerplate/backend/BackendApplication.class")
            }
        )
    )
}

// Enforce minimum code coverage (75%)
tasks.jacocoTestCoverageVerification {
    dependsOn(tasks.named("testUnit"))

    violationRules {
        rule {
            limit {
                minimum = "0.75".toBigDecimal()
            }
        }
    }

    classDirectories.setFrom(tasks.jacocoTestReport.get().classDirectories)
    sourceDirectories.setFrom(sourceSets.main.get().allSource.srcDirs)
    executionData.setFrom(fileTree(layout.buildDirectory.asFile.get()).include("/jacoco/*.exec"))
}

// Make the check lifecycle depend on coverage verification
tasks.check {
    dependsOn(tasks.jacocoTestCoverageVerification)
}

// === Detekt static analysis configuration ===
detekt {
    config.setFrom(files("detekt.yml"))
    buildUponDefaultConfig = true
    allRules = false  // Use rules defined in detekt.yml only
}

// === Spotless Kotlin formatting configuration ===
spotless {
    kotlin {
        target("src/**/*.kt")   // Target Kotlin source files for formatting
        ktlint()                // Use ktlint formatter
    }
}

// === OWASP Dependency-Check plugin configuration ===
dependencyCheck {
    nvd.apiKey = System.getenv("NVD_API_KEY") ?: ""
    failBuildOnCVSS = 7.0F  // Fail build on vulnerabilities with CVSS >= 7.0
    format = "SARIF"        // Output format suitable for GitHub integration
    outputDirectory = "$buildDir/reports/dependency-check"

    analyzers.apply {
        isAssemblyEnabled = false  // Disable .NET Assembly analyzer to avoid Windows-specific errors
    }

    scanSet = listOf(file("src"), file("build.gradle.kts")) // Directories and files to scan
}

// === Custom Trivy scanning tasks ===

// Run Trivy filesystem scan on backend folder for high/critical issues
tasks.register<Exec>("trivyFsScan") {
    group = "security"
    description = "Run Trivy FS scan on backend folder for HIGH and CRITICAL vulnerabilities"

    commandLine(
        "trivy", "fs",
        "--severity", "HIGH,CRITICAL",
        "--exit-code", "1",
        "--scanners", "vuln,secret",
        "."
    )
}

// Run Trivy Dockerfile config scan on backend Dockerfile for high/critical issues
tasks.register<Exec>("trivyDockerfileScan") {
    group = "security"
    description = "Run Trivy config scan on backend Dockerfile for HIGH and CRITICAL vulnerabilities"

    commandLine(
        "trivy", "config",
        "--severity", "HIGH,CRITICAL",
        "--exit-code", "1",
        "../docker/backend.dockerfile"
    )
}
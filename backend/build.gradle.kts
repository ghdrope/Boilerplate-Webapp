plugins {
    id("org.springframework.boot") version "3.5.4"
    id("io.spring.dependency-management") version "1.1.4"
    kotlin("jvm") version "2.0.21"
    kotlin("plugin.spring") version "2.0.0"

    // Quality tools
    id("io.gitlab.arturbosch.detekt") version "1.23.8"
    id("com.diffplug.spotless") version "7.2.1"
    jacoco
}

group = "ghdrope.boilerplate"
version = "0.0.3"
java.sourceCompatibility = JavaVersion.VERSION_21

kotlin {
    jvmToolchain(21)
}

repositories {
    mavenCentral()
}

dependencies {
    // Spring Boot starters
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-actuator")

    // Kotlin support
    implementation("org.jetbrains.kotlin:kotlin-reflect")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")

    // Testing dependencies
    testImplementation("org.springframework.boot:spring-boot-starter-test") {
        exclude(group = "org.junit.vintage", module = "junit-vintage-engine")
    }
}

tasks.withType<Test> {
    useJUnitPlatform()
}

// === Jacoco configuration ===
jacoco {
    toolVersion = "0.8.13"
}

// Task to run only unit tests (excludes tests tagged with "integration")
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

// Task to run only integration tests (tests tagged with "integration")
tasks.register<Test>("testIntegration") {
    description = "Run only integration tests"
    useJUnitPlatform {
        includeTags("integration")
    }
}

// Default test task configuration
tasks.test {
    useJUnitPlatform()
    finalizedBy(
        tasks.jacocoTestReport,
        tasks.jacocoTestCoverageVerification
    )
}

// Jacoco test coverage report configuration
tasks.jacocoTestReport {
    dependsOn(tasks.named("testUnit"))  // Ensure unit tests run first

    reports {
        html.required.set(true)  // Generate HTML report
        xml.required.set(false)
        csv.required.set(false)
    }

    // Exclude BackendApplication from coverage reports to avoid affecting coverage metrics
    classDirectories.setFrom(
        files(
            fileTree("${buildDir}/classes/java/main") {
                exclude("ghdrope/boilerplate/backend/BackendApplication.class")
            }
        )
    )
}

// Jacoco test coverage verification (enforces minimum coverage)
tasks.jacocoTestCoverageVerification {
    dependsOn(tasks.named("testUnit"))  // Run after unit tests

    violationRules {
        rule {
            limit {
                minimum = "0.75".toBigDecimal()  // Require at least 75% coverage
            }
        }
    }

    // Use same filtered class directories as the report task for consistency
    classDirectories.setFrom(tasks.jacocoTestReport.get().classDirectories)

    // Use all source directories from main source set
    sourceDirectories.setFrom(sourceSets.main.get().allSource.srcDirs)

    // Use the execution data from test runs
    executionData.setFrom(fileTree(layout.buildDirectory.asFile.get()).include("/jacoco/*.exec"))
}

// Make sure 'check' depends on coverage verification
tasks.check {
    dependsOn(tasks.jacocoTestCoverageVerification)
}

// === Detekt configuration ===
detekt {
    config.setFrom(files("detekt.yml"))
    buildUponDefaultConfig = true
    allRules = false
}

// === Spotless configuration for code formatting ===
spotless {
    kotlin {
        target("src/**/*.kt")
        ktlint()
    }
}

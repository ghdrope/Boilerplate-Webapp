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
version = "0.0.2-SNAPSHOT"
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
    
    // Testing
    testImplementation("org.springframework.boot:spring-boot-starter-test") {
        exclude(group = "org.junit.vintage", module = "junit-vintage-engine")
    }
}

tasks.withType<Test> {
    ignoreFailures = true
    useJUnitPlatform()
}

// Jacoco config
jacoco {
    toolVersion = "0.8.13"
}

tasks.jacocoTestReport {
    dependsOn(tasks.test)
    reports {
        html.required.set(true)
        xml.required.set(false)
        csv.required.set(false)
    }
}

tasks.jacocoTestCoverageVerification {
    dependsOn(tasks.test)
    violationRules {
        rule {
            limit {
                minimum = "0.75".toBigDecimal() // requires >= 75% coverage
            }
        }
    }
    sourceSets(sourceSets.main.get())
    executionData.setFrom(fileTree(buildDir).include("/jacoco/*.exec"))
}

tasks.check {
    dependsOn(tasks.jacocoTestCoverageVerification)
}

// Detekt config
detekt {
    config = files("detekt.yml")
    buildUponDefaultConfig = true
    allRules = false
}

// Spotless formatting
spotless {
    kotlin {
        target("src/**/*.kt")
        ktlint()
    }
}
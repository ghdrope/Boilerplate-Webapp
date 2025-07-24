package ghdrope.boilerplate.backend

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

/**
 * Main Spring Boot application class for the backend service.
 *
 * The `@SpringBootApplication` annotation enables auto-configuration,
 * component scanning, and configuration support.
 */
@SpringBootApplication
class BackendApplication

/**
 * Application entry point.
 *
 * Runs the Spring Boot application.
 *
 * @param args command-line arguments
 */
fun main(args: Array<String>) {
    runApplication<BackendApplication>(*args)
}
package ghdrope.boilerplate.backend

import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

/**
 * REST controller exposing a basic health check endpoint.
 *
 * Useful for verifying that the backend is up and responsive.
 */
@RestController
class HelloController {
    private val logger = LoggerFactory.getLogger(HelloController::class.java)

    companion object {
        /**
         * Static greeting message used in the `/hello` response.
         */
        private const val GREETING = "Hello from backend!"
    }

    /**
     * GET `/hello`.
     *
     * Returns a simple greeting message for health check or testing purposes.
     *
     * @return A static greeting string
     */
    @GetMapping("/hello")
    fun hello(): String {
        logger.info("Health check endpoint `/hello` called.")
        return GREETING
    }
}

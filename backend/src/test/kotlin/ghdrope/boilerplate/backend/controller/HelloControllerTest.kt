package ghdrope.boilerplate.backend.controller

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test

/**
 * Unit tests for [HelloController].
 *
 * These tests verify the behavior of the controller logic without
 * loading the Spring context or making actual HTTP requests.
 */
class HelloControllerTest {
    private val controller = HelloController()

    /**
     * Verifies that calling [HelloController.hello] returns
     * the expected greeting string.
     */
    @Test
    fun `hello() should return greeting message`() {
        val response = controller.hello()
        assertEquals("Hello from backend!", response)
    }
}

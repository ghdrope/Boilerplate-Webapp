package ghdrope.boilerplate.backend.controller

import org.junit.jupiter.api.Tag
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.get

/**
 * Integration test for [HelloController].
 *
 * This test loads the Spring Web MVC context and uses [MockMvc] to
 * perform HTTP requests, verifying the full web layer behavior.
 * It is tagged as "integration" to separate it from unit tests.
 */
@Tag("integration")
@WebMvcTest(HelloController::class)
class HelloControllerIntegrationTest(
    @Autowired val mockMvc: MockMvc,
) {
    /**
     * Tests that a GET request to "/hello" returns
     * the expected greeting string with HTTP 200 OK status.
     */
    @Test
    fun `GET hello returns greeting`() {
        mockMvc
            .get("/hello")
            .andExpect {
                status { isOk() }
                content { string("Hello from backend!") }
            }
    }
}

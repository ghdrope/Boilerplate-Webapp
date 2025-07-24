package ghdrope.boilerplate.backend

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

/**
 * REST controller that exposes backend endpoints.
 */
@RestController
class HelloController {
    
    /**
     * HTTP GET endpoint at `/hello`.
     *
     * Returns a simple greeting string.
     *
     * @return greeting message
     */
    @GetMapping("/hello")
    fun hello() = "Hello from backend!"
}
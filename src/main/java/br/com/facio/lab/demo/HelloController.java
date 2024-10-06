package br.com.facio.lab.demo;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    private final Counter requestCounter;

    public HelloController(MeterRegistry meterRegistry) {
        this.requestCounter = meterRegistry.counter("http_requests_total", "endpoint", "/hello");
    }

    @GetMapping("/hello")
    public String hello() {
        requestCounter.increment();
        return "Hello, World!";
    }
}

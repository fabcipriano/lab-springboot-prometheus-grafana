package br.com.facio.lab;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Random;
import java.util.concurrent.TimeUnit;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@RestController
public class TimerController {

    private final Timer requestTimer;

    private static final Logger logger = LogManager.getLogger(TimerController.class);

    public TimerController(MeterRegistry meterRegistry) {
                // Configure the timer to record percentiles and publish a histogram
                this.requestTimer = Timer.builder("http_request_duration_seconds")
                .description("Duration of HTTP requests in seconds")
                .tags("endpoint", "/process")
                .publishPercentileHistogram(true) // Enable histogram
                .publishPercentiles(0.5, 0.90, 0.95)
                .register(meterRegistry);
    }

    @GetMapping("/process")
    public String process() throws InterruptedException {
        return requestTimer.record(() -> {
            try {
                // Generate a random number between 1 and 10
                int randomSleepTime = new Random().nextInt(12) + 1;
                logger.debug("Random sleep time: {} seconds", randomSleepTime);

                // Simulate processing time with random sleep
                TimeUnit.SECONDS.sleep(randomSleepTime);
            } catch (InterruptedException e) {
                logger.error("Thread was interrupted", e);
                Thread.currentThread().interrupt();
            }

            logger.info("Processing complete");
            return "Processing complete!";
        });
    }
}
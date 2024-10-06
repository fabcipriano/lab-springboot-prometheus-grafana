package br.com.facio.lab;

import io.micrometer.core.instrument.DistributionSummary;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class SummaryController {

    private final DistributionSummary responseSizeSummary;

    public SummaryController(MeterRegistry meterRegistry) {
        this.responseSizeSummary = DistributionSummary.builder("response_size_bytes")
                .description("Size of HTTP responses in bytes")
                .register(meterRegistry);
    }

    @GetMapping("/data")
    public String getData() {
        String response = "Some large data response";
        responseSizeSummary.record(response.getBytes().length);  // Record the size of the response
        return response;
    }
}
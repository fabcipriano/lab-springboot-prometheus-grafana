#!/bin/bash

# Step 1: Create Spring Boot Project Directory
echo "Creating Spring Boot project directory..."
mkdir springboot-prometheus-grafana-lab
cd springboot-prometheus-grafana-lab

# Step 2: Create Spring Boot Application with Micrometer and Actuator
echo "Creating Spring Boot application with Micrometer and Actuator..."
mkdir -p src/main/java/com/example/demo
mkdir -p src/main/resources

# Create a basic Spring Boot Application
cat <<EOL > src/main/java/com/example/demo/DemoApplication.java
package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
EOL

# Create a simple controller to expose metrics
cat <<EOL > src/main/java/com/example/demo/HelloController.java
package com.example.demo;

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
EOL

# Create application.properties to expose Prometheus metrics
cat <<EOL > src/main/resources/application.properties
management.endpoints.web.exposure.include=prometheus
management.metrics.export.prometheus.enabled=true
EOL

# Create a basic Maven pom.xml file
cat <<EOL > pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example</groupId>
    <artifactId>demo</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <java.version>11</java.version>
    </properties>

    <dependencies>
        <!-- Spring Boot Starter -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
        </dependency>

        <!-- Spring Boot Actuator -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>

        <!-- Micrometer Prometheus Registry -->
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-registry-prometheus</artifactId>
        </dependency>

        <!-- Spring Boot Test -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
EOL

# Step 3: Create Docker Compose File for Prometheus, Grafana, and Spring Boot App
echo "Creating Docker Compose file..."
cat <<EOL > docker-compose.yml
version: '3'
services:
  springboot-app:
    build: .
    ports:
      - "8080:8080"
    networks:
      - monitoring

  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"
    networks:
      - monitoring

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    networks:
      - monitoring

networks:
  monitoring:
EOL

# Step 4: Create Prometheus Configuration File
echo "Creating Prometheus configuration file..."
cat <<EOL > prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'springboot-app'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['springboot-app:8080']
EOL

# Step 5: Create Dockerfile for Spring Boot Application
echo "Creating Dockerfile for Spring Boot application..."
cat <<EOL > Dockerfile
# Use Maven to build the application
FROM maven:3.8.1-openjdk-11 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Use OpenJDK to run the application
FROM openjdk:11-jre-slim
WORKDIR /app
COPY --from=build /app/target/demo-1.0-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
EOL

# Step 6: Build and Run the Docker Containers
echo "Building and running the Docker containers..."
docker-compose up --build -d

# Step 7: Display Access Information
echo "Setup complete!"
echo "Access Prometheus at: http://localhost:9090"
echo "Access Grafana at: http://localhost:3000 (default login: admin/admin)"
echo "Access Spring Boot app at: http://localhost:8080/hello"
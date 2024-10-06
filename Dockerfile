# Use OpenJDK 11 with Alpine to run the application
FROM openjdk:11-jdk-slim
WORKDIR /app
COPY target/simple-lab-1.0-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
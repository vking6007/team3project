# Multi-stage build for Spring Boot app

# Stage 1: Build the application
FROM maven:3.9.6-eclipse-temurin-21 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn -q -e -B -DskipTests dependency:go-offline
COPY src ./src
RUN mvn -q -e -B -DskipTests clean package

# Stage 2: Runtime image
FROM openjdk:21-jdk-slim

# Install curl for health checks
RUN apt-get update -qq && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the jar file from builder stage
COPY --from=builder /app/target/team3project-0.0.1-SNAPSHOT.jar app.jar

# Expose port
EXPOSE 8085

# Set timezone
ENV TZ=UTC

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8085/actuator/health || exit 1

# Run the jar
ENTRYPOINT ["java", "-jar", "app.jar"]
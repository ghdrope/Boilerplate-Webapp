#
# ----- Stage 1: Build -----
#
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /app

# Copy wrapper and build scripts first for better caching
COPY backend/gradlew backend/gradlew.bat ./
COPY backend/gradle ./gradle
COPY backend/build.gradle.kts backend/settings.gradle.kts ./

# Ensure wrapper is executable
RUN chmod +x gradlew

# Pre-download dependencies to leverage Docker cache
RUN ./gradlew --no-daemon dependencies

# Copy the application source
COPY backend/src ./src

# Build only the bootable JAR (skip tests, linting, formatting checks)
RUN ./gradlew --no-daemon clean bootJar -x test -x detekt -x spotlessCheck



#
# ----- Stage 2: Runtime -----
#
FROM eclipse-temurin:21-jdk-alpine

# Install curl (useful for healthchecks or debugging)
RUN apk add --no-cache curl

# Create a non-root user and group to run the app securely
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set working directory for the app
WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /app/build/libs/*.jar app.jar

# Expose the default Spring Boot port
EXPOSE 8080

# Switch to non-root user to improve container security
USER appuser

# Healthcheck to verify the app responds on /actuator/health with HTTP 200
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Entrypoint for distroless
CMD ["java", "-jar", "app.jar"]

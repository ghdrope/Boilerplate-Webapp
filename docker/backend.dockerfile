#
# ----- Stage 1: Build -----
#
FROM gradle:8.3-jdk17 AS builder

WORKDIR /backend

# Copy build files to leverage Docker cache for dependencies
COPY backend/build.gradle.kts backend/settings.gradle.kts ./
COPY backend/gradle ./gradle

# Download dependencies (cache step)
RUN gradle --no-daemon build -x test || true

# Copy the rest of the source code
COPY backend/src ./src

# Build the Spring Boot jar (skip tests for faster builds)
RUN gradle --no-daemon clean bootJar -x test

#
# ----- Stage 2: Runtime -----
#
FROM eclipse-temurin:17-jre

WORKDIR /backend

# Copy the jar built from the previous stage
COPY --from=builder /backend/build/libs/*.jar app.jar

# Expose default Spring Boot port
EXPOSE 8080

# Command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
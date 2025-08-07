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

# Install curl
RUN apk add --no-cache curl

WORKDIR /app

# Copy only the final built JAR
COPY --from=builder /app/build/libs/*.jar app.jar

# Spring Boot default port
EXPOSE 8080

# Entrypoint for distroless
CMD ["java", "-jar", "app.jar"]

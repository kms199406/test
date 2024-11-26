# Stage 1: Build
FROM gradle:8.5.0-jdk17 AS build
WORKDIR /project

# Copy build files first to leverage Docker caching for dependencies
COPY build.gradle settings.gradle gradlew /project/
COPY gradle /project/gradle
RUN chmod +x /project/gradlew

# Cache dependencies to optimize build times
RUN /project/gradlew dependencies --no-daemon || return 0

# Copy source files
COPY src /project/src

# Build argument for environment selection
ARG BUILD_ENV=local

# Run the build without tests for both environments
RUN /project/gradlew clean build -x test --no-daemon

# Stage 2: Run
FROM openjdk:17
WORKDIR /project

# Environment variables for different environments
ARG BUILD_ENV=local
ENV SPRING_PROFILES_ACTIVE=$BUILD_ENV

# Set different JVM options based on environment
ENV JAVA_OPTS_LOCAL="-Xms256m -Xmx1024m"
ENV JAVA_OPTS_PROD="-Xms512m -Xmx2048m"

# Create directory for certificates in production
RUN mkdir -p /app/certs

# Copy the built jar from the previous stage
COPY --from=build /project/build/libs/*.jar /project/app.jar

# Health check configuration
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD if [ "$SPRING_PROFILES_ACTIVE" = "prod" ]; then \
            curl --fail https://localhost:8080/actuator/health || exit 1; \
        else \
            curl --fail http://localhost:8080/actuator/health || exit 1; \
        fi

# Run the application with environment-specific settings
ENTRYPOINT ["sh", "-c", "\
    if [ \"$SPRING_PROFILES_ACTIVE\" = \"local\" ]; then \
        java $JAVA_OPTS_LOCAL -jar /project/app.jar; \
    else \
        java $JAVA_OPTS_PROD -jar /project/app.jar; \
    fi"]
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

# Run the build
ARG BUILD_ENV=local
RUN if [ "$BUILD_ENV" = "local" ] ; then /project/gradlew clean build -x test --no-daemon; else /project/gradlew clean build --no-daemon; fi

# Stage 2: Run
FROM openjdk:17
WORKDIR /project

# Set environment variables for JVM options and application properties
ARG BUILD_ENV=local
ENV SPRING_PROFILES_ACTIVE=$BUILD_ENV
ENV JAVA_OPTS="-Xms512m -Xmx2048m"

# Copy the built jar from the previous stage
COPY --from=build /project/build/libs/*.jar /project/*.jar

# Health check for production environment
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD if [ "$SPRING_PROFILES_ACTIVE" = "prod" ]; then curl --fail http://localhost:433/actuator/health || exit 1; fi

# Run the application with JVM options
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /project/*.jar"]

# Stage 1: Build
FROM gradle:8.5.0-jdk17 AS build
WORKDIR /project
RUN mkdir -p /project/certs/prod && chmod -R 755 /project/certs
RUN mkdir -p /project/scripts && chmod -R 755 /project/scripts

# Copy build files first to leverage Docker caching for dependencies
COPY build.gradle settings.gradle gradlew /project/
COPY gradle /project/gradle
RUN chmod +x /project/gradlew

# Cache dependencies to optimize build times
RUN /project/gradlew dependencies --no-daemon || return 0

# Copy source files
COPY src /project/src

# Run the build
ARG BUILD_ENV=prod
RUN /project/gradlew clean build -x test --no-daemon

# Stage 2: Run
FROM openjdk:17
WORKDIR /project
RUN mkdir -p /project/certs/prod && chmod -R 755 /project/certs

# Copy SSL certificates
COPY certs/prod /project/certs/prod

# Set permissions for SSL certificates
RUN chmod -R 600 /project/certs/prod/*.p12 && \
    chmod -R 600 /project/certs/prod/*.pem && \
    chown -R 1000:1000 /project/certs/prod

# Set environment variables for JVM options and application properties
ARG BUILD_ENV=prod
ENV SPRING_PROFILES_ACTIVE=$BUILD_ENV
ENV JAVA_OPTS="-Xms512m -Xmx2048m \
  -Djavax.net.ssl.keyStore=/project/certs/prod/springboot.p12 \
  -Djavax.net.ssl.keyStorePassword=Ccenter123456! \
  -Djavax.net.ssl.keyStoreType=PKCS12"

# Copy the built jar from the previous stage
COPY --from=build /project/build/libs/*.jar /project/*.jar

COPY scripts/set_kibana_password.sh /project/scripts
RUN chmod +x /project/scripts/set_kibana_password.sh

# Health check for production environment
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD if [ "$SPRING_PROFILES_ACTIVE" = "prod" ]; then curl --fail https://www.projectkkk.com:443/actuator/health || exit 1; fi

# Run the application with JVM options
ENTRYPOINT ["sh", "-c", "/project/scripts/set_kibana_password.sh && java $JAVA_OPTS -jar /project/*.jar"]

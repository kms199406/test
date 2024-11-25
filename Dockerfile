# Step 1: Use an official Gradle image to build the project
FROM gradle:8.5-jdk17 AS builder
WORKDIR /app

# gradle wrapper 파일들을 먼저 복사하고 권한 설정
COPY gradle gradle/
COPY gradlew build.gradle settings.gradle ./
RUN chmod +x gradlew
# DOS 형식을 UNIX 형식으로 변환 (필요한 경우)
RUN sed -i 's/\r$//' gradlew

# 나머지 소스 파일들 복사
COPY src ./src

# Gradle 파일 복사
COPY gradle/gradle-8.5-bin.zip /app/gradle/gradle-8.5-bin.zip

# Firebase 설정 파일 복사
COPY src/main/resources/superb-analog-439512-g8-firebase-adminsdk-l7nbt-2305deb251.json /app/serviceAccountKey.json

# gradle-wrapper.properties 수정
RUN sed -i 's|https://services.gradle.org/distributions/gradle-8.5-bin.zip|file:///app/gradle/gradle-8.5-bin.zip|' gradle/wrapper/gradle-wrapper.properties

# Gradle 빌드
RUN ./gradlew build -x test --no-daemon

# Step 2: Runtime stage
FROM openjdk:17-jdk-slim
WORKDIR /app

# Copy application files
COPY --from=builder /app/build/libs/*.jar app.jar
COPY --from=builder /app/serviceAccountKey.json /app/serviceAccountKey.json

# Copy and set permissions for wait-for-it script
COPY scripts/wait-for-it.sh /app/wait-for-it.sh
RUN chmod +x /app/wait-for-it.sh

# Copy SSL certificates and set permissions
COPY localhost.p12 elastic-stack-ca.p12 springboot-server.p12 /app/
RUN chmod 600 /app/*.p12

EXPOSE 443

ENTRYPOINT ["/app/wait-for-it.sh", "kafka:9092", "--timeout=120", "--", \
            "/app/wait-for-it.sh", "elasticsearch:9200", "--timeout=240", "--", \
            "java", "-Dserver.port=443", \
            "-Dserver.ssl.key-store=/app/springboot-server.p12", \
            "-Dserver.ssl.key-store-password=Ccenter123456!", \
            "-Dserver.ssl.key-store-type=PKCS12", \
            "-jar", "app.jar"]
// home/project/config/kafka/KafkaTopicProperties.java
package home.project.config.kafka;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Getter
@Setter
@Component
@ConfigurationProperties(prefix = "spring.kafka.topics")
public class KafkaTopicProperties {
    private String kafkaLogs = "kafka-logs";
    private String errorLogs = "error-logs";
}
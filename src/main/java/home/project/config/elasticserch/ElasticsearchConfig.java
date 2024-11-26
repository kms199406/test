package home.project.config.elasticserch;

import org.apache.http.ssl.SSLContextBuilder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.FileSystemResource;
import org.springframework.data.elasticsearch.client.ClientConfiguration;
import org.springframework.data.elasticsearch.client.elc.ElasticsearchConfiguration;
import org.springframework.lang.NonNull;

import javax.net.ssl.SSLContext;
import java.time.Duration;

@Configuration
public class ElasticsearchConfig extends ElasticsearchConfiguration {
    @Value("${spring.elasticsearch.uris}")
    private String elasticsearchUrl;

    @Value("${spring.profiles.active}")
    private String activeProfile;

    @Value("${spring.elasticsearch.username}")  // 변경됨
    private String username;

    @Value("${spring.elasticsearch.password}")  // 변경됨
    private String password;

    @Value("${spring.elasticsearch.ssl.trust-store}")  // 변경됨
    private String trustStorePath;

    @Value("${spring.elasticsearch.ssl.trust-store-password}")  // 변경됨
    private String trustStorePassword;

    @Value("${spring.elasticsearch.ssl.keystore-path}")  // 변경됨
    private String keystorePath;

    @Value("${spring.elasticsearch.ssl.keystore-password}")  // 변경됨
    private String keystorePassword;

    @Value("${spring.elasticsearch.connection-timeout:30000}")  // 추가됨
    private long connectTimeout;

    @Value("${spring.elasticsearch.read-timeout:60000}")  // 추가됨
    private long readTimeout;

    @Override
    @NonNull
    public ClientConfiguration clientConfiguration() {
        if ("local".equals(activeProfile)) {
            return ClientConfiguration.builder()
                    .connectedTo(elasticsearchUrl.replace("http://", ""))
                    .withSocketTimeout(Duration.ofMillis(readTimeout))
                    .withConnectTimeout(Duration.ofMillis(connectTimeout))
                    .build();
        }
        return createProdConfiguration();
    }

    private ClientConfiguration createProdConfiguration() {
        try {
            SSLContext sslContext = SSLContextBuilder.create()
                    .loadTrustMaterial(
                            new FileSystemResource(trustStorePath).getFile(),
                            trustStorePassword.toCharArray()
                    )
                    .loadKeyMaterial(
                            new FileSystemResource(keystorePath).getFile(),
                            keystorePassword.toCharArray(),
                            keystorePassword.toCharArray()
                    )
                    .build();

            return ClientConfiguration.builder()
                    .connectedTo(elasticsearchUrl.replace("https://", ""))
                    .usingSsl(sslContext)
                    .withBasicAuth(username, password)
                    .withSocketTimeout(Duration.ofMillis(readTimeout))
                    .withConnectTimeout(Duration.ofMillis(connectTimeout))
                    .build();
        } catch (Exception e) {
            throw new RuntimeException("Failed to create SSL context for Elasticsearch", e);
        }
    }
}
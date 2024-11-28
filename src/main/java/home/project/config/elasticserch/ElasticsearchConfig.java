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
    @Value("${spring.elasticsearch.rest.uris}")
    private String elasticsearchUrl;

    @Value("${spring.profiles.active}")
    private String activeProfile;

    @Value("${spring.elasticsearch.rest.username:}")  // prod에서만 사용
    private String username;

    @Value("${spring.elasticsearch.rest.password:}")  // prod에서만 사용
    private String password;

    @Value("${spring.elasticsearch.rest.ssl.trust-store:}")  // prod에서만 사용
    private String trustStorePath;

    @Value("${spring.elasticsearch.rest.ssl.trust-store-password:}")  // prod에서만 사용
    private String trustStorePassword;

    @Value("${spring.elasticsearch.rest.ssl.key-store:}")  // prod에서만 사용
    private String keystorePath;

    @Value("${spring.elasticsearch.rest.ssl.key-store-password:}")  // prod에서만 사용
    private String keystorePassword;

    @Override
    @NonNull
    public ClientConfiguration clientConfiguration() {
        if ("local".equals(activeProfile)) {
            return ClientConfiguration.builder()
                    .connectedTo(elasticsearchUrl.replace("http://", ""))
                    .withSocketTimeout(Duration.ofSeconds(30))
                    .withConnectTimeout(Duration.ofSeconds(60))
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
                    .withSocketTimeout(Duration.ofSeconds(30))
                    .withConnectTimeout(Duration.ofSeconds(60))
                    .build();
        } catch (Exception e) {
            throw new RuntimeException("Failed to create SSL context for Elasticsearch", e);
        }
    }
}

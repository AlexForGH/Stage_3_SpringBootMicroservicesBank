package org.pl.config;

import org.pl.security.AccessTokenProvider;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

@Configuration
public class RestClientConfig {

    @Value("${api.account.base.url}")
    private String apiAccountBaseUrl;

    @Value("${api.transfer.base.url}")
    private String apiTransferBaseUrl;

    @Bean
    @Qualifier("restAccountServiceClient")
    public RestClient restAccountServiceClient(AccessTokenProvider accessTokenProvider) {
        return RestClient.builder()
                .baseUrl(apiAccountBaseUrl)
                .defaultHeader("Content-Type", "application/json")
                .defaultHeader("Accept", "application/json")
                .requestInterceptor((request, body, execution) -> {
                    // Достаём токен и вставляем в каждый запрос
                    String token = accessTokenProvider.getAccessToken();
                    request.getHeaders().setBearerAuth(token);
                    return execution.execute(request, body);
                })
                .build();
    }

    @Bean
    @Qualifier("restTransferServiceClient")
    public RestClient restTransferServiceClient(AccessTokenProvider accessTokenProvider) {
        return RestClient.builder()
                .baseUrl(apiTransferBaseUrl)
                .defaultHeader("Content-Type", "application/json")
                .defaultHeader("Accept", "application/json")
                .requestInterceptor((request, body, execution) -> {
                    // Достаём токен и вставляем в каждый запрос
                    String token = accessTokenProvider.getAccessToken();
                    request.getHeaders().setBearerAuth(token);
                    return execution.execute(request, body);
                })
                .build();
    }
}

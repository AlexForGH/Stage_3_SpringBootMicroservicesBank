package org.pl.config;

import org.pl.security.AccessTokenProvider;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

@Configuration
public class RestClientConfig {

    @Value("${api.cash.base.url}")
    private String apiCashBaseUrl;

    @Bean
    @Qualifier("restCashServiceClient")
    public RestClient restCashServiceClient(AccessTokenProvider tokenProvider) {
        return RestClient.builder()
                .baseUrl(apiCashBaseUrl)
                .defaultHeader("Content-Type", "application/json")
                .defaultHeader("Accept", "application/json")
                .requestInterceptor((request, body, execution) -> {
                    // Пробрасываем ТОТ ЖЕ токен, с которым пришел запрос
                    String token = tokenProvider.getCurrentAccessToken();
                    request.getHeaders().setBearerAuth(token);
                    return execution.execute(request, body);
                })
                .build();
    }

}
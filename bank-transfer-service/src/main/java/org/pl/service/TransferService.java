package org.pl.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.math.BigDecimal;

@Service
public class TransferService {

    private final RestClient restCashServiceClient;

    @Value("${api.cash.base.endpoint}")
    String apiCashBaseEndpoint;

    public TransferService(RestClient restCashServiceClient) {
        this.restCashServiceClient = restCashServiceClient;
    }

    public HttpStatus transferCash(String loginFrom, String loginTo, BigDecimal cashToTransfer) {
        return restCashServiceClient.post()
                .uri(uriBuilder -> uriBuilder
                        .path(apiCashBaseEndpoint)
                        .queryParam("login_f", loginFrom)
                        .queryParam("login_t", loginTo)
                        .queryParam("c_t_t", cashToTransfer)
                        .build()
                )
                .retrieve()
                .body(HttpStatus.class);
    }

    public HttpStatus getCash(String login, BigDecimal cash) {
        return restCashServiceClient.post()
                .uri(uriBuilder -> uriBuilder
                        .path(apiCashBaseEndpoint)
                        .queryParam("cash_action", "GET_CASH")
                        .queryParam("login", login)
                        .queryParam("cash", cash)
                        .build()
                )
                .retrieve()
                .body(HttpStatus.class);
    }

    public HttpStatus putCash(String login, BigDecimal cash) {
        return restCashServiceClient.post()
                .uri(uriBuilder -> uriBuilder
                        .path(apiCashBaseEndpoint)
                        .queryParam("cash_action", "PUT_CASH")
                        .queryParam("login", login)
                        .queryParam("cash", cash)
                        .build()
                )
                .retrieve()
                .body(HttpStatus.class);
    }
}

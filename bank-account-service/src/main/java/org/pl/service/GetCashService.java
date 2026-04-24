package org.pl.service;

import org.pl.controller.dto.CashResponse;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

@Service
public class GetCashService {

    @Qualifier("restCashServiceClient")
    private final RestClient restCashServiceClient;

    @Value("${api.cash.base.endpoint}")
    private String apiCashBaseEndpoint;

    public GetCashService(RestClient restCashServiceClient) {
        this.restCashServiceClient = restCashServiceClient;
    }

    public CashResponse getCashResponse(String login) {
        return restCashServiceClient.get()
                .uri(apiCashBaseEndpoint + "?login={login}", login)
                .retrieve()
                .body(CashResponse.class);
    }
}

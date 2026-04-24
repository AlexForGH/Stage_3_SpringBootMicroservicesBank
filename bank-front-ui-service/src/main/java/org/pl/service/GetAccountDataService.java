package org.pl.service;

import org.pl.controller.dto.AccountResponse;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.time.LocalDate;
import java.util.List;

@Service
public class GetAccountDataService {

    @Qualifier("restAccountServiceClient")
    private final RestClient restAccountServiceClient;

    @Value("${api.account.base.endpoint}")
    String apiAccountBaseEndpoint;

    public GetAccountDataService(RestClient restAccountServiceClient) {
        this.restAccountServiceClient = restAccountServiceClient;
    }

    public AccountResponse getAccountResponse(String login) {
        return restAccountServiceClient.get()
                .uri(apiAccountBaseEndpoint + "?login={login}", login)
                .retrieve()
                .body(AccountResponse.class);
    }

    public List<AccountResponse> getAccountResponses() {
        return restAccountServiceClient.get()
                .uri(apiAccountBaseEndpoint)
                .retrieve()
                .body(new ParameterizedTypeReference<>() {
                });
    }

    public AccountResponse postAccountChangesData(
            String login,
            String newFirstName,
            String newLastName,
            LocalDate newBirthDate
    ) {
        return restAccountServiceClient.post()
                .uri(uriBuilder -> uriBuilder
                        .path(apiAccountBaseEndpoint)
                        .queryParam("login", login)
                        .queryParam("new_fn", newFirstName)
                        .queryParam("new_ln", newLastName)
                        .queryParam("new_bd", newBirthDate)
                        .build()
                )
                .retrieve()
                .body(AccountResponse.class);
    }
}

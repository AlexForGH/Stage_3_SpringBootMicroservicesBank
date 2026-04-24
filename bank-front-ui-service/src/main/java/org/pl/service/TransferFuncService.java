package org.pl.service;

import org.pl.controller.dto.AccountResponse;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.math.BigDecimal;

@Service
public class TransferFuncService {

    @Qualifier("restTransferServiceClient")
    private final RestClient restTransferServiceClient;

    private final GetAccountDataService getAccountDataService;

    @Value("${api.transfer.base.endpoint}")
    String apiAccountBaseEndpoint;

    public TransferFuncService(
            RestClient restTransferServiceClient,
            GetAccountDataService getAccountDataService
    ) {
        this.restTransferServiceClient = restTransferServiceClient;
        this.getAccountDataService = getAccountDataService;
    }

    public HttpStatus transferCash(String loginFrom, String loginTo, BigDecimal cashToTransfer) {
        AccountResponse accountResponseFrom = getAccountDataService.getAccountResponse(loginFrom);
        if (accountResponseFrom.getCash().compareTo(cashToTransfer) < 0) {
            return HttpStatus.BAD_REQUEST;
        }
        return restTransferServiceClient.post()
                .uri(uriBuilder -> uriBuilder
                        .path(apiAccountBaseEndpoint)
                        .queryParam("login_f", loginFrom)
                        .queryParam("login_t", loginTo)
                        .queryParam("c_t_t", cashToTransfer)
                        .build()
                )
                .retrieve()
                .body(HttpStatus.class);
    }

    public HttpStatus getCash(String login, BigDecimal cash) {
        AccountResponse accountResponse = getAccountDataService.getAccountResponse(login);
        if (accountResponse.getCash().compareTo(cash) < 0) {
            return HttpStatus.BAD_REQUEST;
        }
        return restTransferServiceClient.post()
                .uri(uriBuilder -> uriBuilder
                        .path(apiAccountBaseEndpoint)
                        .queryParam("cash_action", "GET_CASH")
                        .queryParam("login", login)
                        .queryParam("cash", cash)
                        .build()
                )
                .retrieve()
                .body(HttpStatus.class);
    }

    public HttpStatus putCash(String login, BigDecimal cash) {
        return restTransferServiceClient.post()
                .uri(uriBuilder -> uriBuilder
                        .path(apiAccountBaseEndpoint)
                        .queryParam("cash_action", "PUT_CASH")
                        .queryParam("login", login)
                        .queryParam("cash", cash)
                        .build()
                )
                .retrieve()
                .body(HttpStatus.class);
    }
}

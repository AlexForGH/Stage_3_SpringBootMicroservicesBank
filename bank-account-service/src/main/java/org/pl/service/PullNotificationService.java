package org.pl.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

@Service
public class PullNotificationService {

    private final RestClient restNotificationServiceClient;

    @Value("${spring.application.name}")
    private String myServiceName;

    @Value("${api.notification.base.endpoint}")
    private String notificationBaseEndpoint;

    public PullNotificationService(RestClient restNotificationServiceClient) {
        this.restNotificationServiceClient = restNotificationServiceClient;
    }

    public HttpStatus pullNotification(String message) {
        return restNotificationServiceClient.post()
                .uri(uriBuilder -> uriBuilder
                        .path(notificationBaseEndpoint)
                        .queryParam("service_name", myServiceName)
                        .queryParam("message", message)
                        .build()
                )
                .retrieve()
                .body(HttpStatus.class);
    }
}

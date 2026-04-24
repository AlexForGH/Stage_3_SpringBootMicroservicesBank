package org.pl.service;

import jakarta.annotation.PostConstruct;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.header.internals.RecordHeader;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;

import java.util.concurrent.CompletableFuture;

@Service
public class PullNotificationService {

    //для диагностики
    @PostConstruct
    public void init() {
        System.out.println("=== PULL NOTIFICATION SERVICE INIT ===");
        System.out.println("myServiceName = " + myServiceName);
        System.out.println("kafkaTemplate = " + (orderKafkaTemplate != null ? "present" : "null"));
        System.out.println("=======================================");
    }

    @Value("${spring.application.name}")
    private String myServiceName;

    private final KafkaTemplate<String, String> orderKafkaTemplate;

    public PullNotificationService(KafkaTemplate<String, String> orderKafkaTemplate) {
        this.orderKafkaTemplate = orderKafkaTemplate;
    }

    public CompletableFuture<SendResult<String, String>> pullNotification(String message) {

        System.out.println("=== ПЫТАЕМСЯ ОТПРАВИТЬ ===");
        System.out.println("message = " + message);
        System.out.println("kafkaTemplate = " + orderKafkaTemplate);

        ProducerRecord<String, String> producerRecord = new ProducerRecord<>(
                "notifications",
                message
        );
        producerRecord.headers().add(new RecordHeader("header.service-name", myServiceName.getBytes()));

        CompletableFuture<SendResult<String, String>> future = orderKafkaTemplate.send(producerRecord);

        future.whenComplete((result, ex) -> {
            if (ex != null) {
                System.err.println("!!! ОШИБКА ОТПРАВКИ !!!");
                ex.printStackTrace();
            } else {
                System.out.println("✓ ОТПРАВЛЕНО! Partition: " + result.getRecordMetadata().partition() +
                        ", Offset: " + result.getRecordMetadata().offset());
            }
        });

        return future;
    }
//    private final RestClient restNotificationServiceClient;
//
//    @Value("${spring.application.name}")
//    private String myServiceName;
//
//    @Value("${api.notification.base.endpoint}")
//    private String notificationBaseEndpoint;
//
//    public PullNotificationService(RestClient restNotificationServiceClient) {
//        this.restNotificationServiceClient = restNotificationServiceClient;
//    }
//
//    public HttpStatus pullNotification(String message) {
//        return restNotificationServiceClient.post()
//                .uri(uriBuilder -> uriBuilder
//                        .path(notificationBaseEndpoint)
//                        .queryParam("service_name", myServiceName)
//                        .queryParam("message", message)
//                        .build()
//                )
//                .retrieve()
//                .body(HttpStatus.class);
//    }
}

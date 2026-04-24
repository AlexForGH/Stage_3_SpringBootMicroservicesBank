package org.pl.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Slf4j
@Service
public class NotificationService {

    @KafkaListener(
            topics = "notifications",
            groupId = "org-pl",
            containerFactory = "kafkaListenerContainerFactory",
            autoStartup = "true"
    )
    public void listenOrder(
            @Header(value = "header.service-name", required = false) String serviceName,
            @Payload String message,
            @Header(KafkaHeaders.RECEIVED_PARTITION) int partition,
            @Header(KafkaHeaders.OFFSET) long offset,
            @Header(KafkaHeaders.RECEIVED_TIMESTAMP) long timestamp) {

        log.info("===========================================");
        log.info("📨 ПОЛУЧЕНО СООБЩЕНИЕ ИЗ KAFKA");
        log.info("   Сервис-отправитель: {}", serviceName);
        log.info("   Сообщение: {}", message);
        log.info("   Партиция: {}", partition);
        log.info("   Оффсет: {}", offset);
        log.info("   Время получения: {}", LocalDateTime.now());
        log.info("===========================================");
    }
}
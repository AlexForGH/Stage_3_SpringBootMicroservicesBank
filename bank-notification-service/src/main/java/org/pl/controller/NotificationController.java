package org.pl.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;

@Slf4j
@RestController
@RequestMapping("${api.notification.base.endpoint}")
public class NotificationController {

    @PostMapping(params = {"service_name", "message"}, produces = MediaType.APPLICATION_JSON_VALUE)
    public HttpStatus getAndLogNotification(
            @RequestParam("service_name") String serviceName,
            @RequestParam("message") String message
    ) {
        log.warn("bank-notification-service translated {}: {} by time: {}", serviceName, message, LocalDateTime.now());
        return HttpStatus.OK;
    }
}

package org.pl.controller;

import org.pl.service.PullNotificationService;
import org.pl.service.TransferService;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;

@RestController
@RequestMapping("${api.transfer.base.endpoint}")
public class TransferController {

    private final TransferService transferService;
    private final PullNotificationService pullNotificationService;

    public TransferController(
            TransferService transferService,
            PullNotificationService pullNotificationService
    ) {
        this.transferService = transferService;
        this.pullNotificationService = pullNotificationService;
    }

    @PostMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public HttpStatus transferCash(
            @RequestParam("login_f") String loginFrom,
            @RequestParam("login_t") String loginTo,
            @RequestParam("c_t_t") BigDecimal cashToTransfer
    ) {
        pullNotificationService.pullNotification("осуществлен перевод от пользователя " + loginFrom +
                " к пользователю " + loginTo + " на сумму " + cashToTransfer);
        return transferService.transferCash(loginFrom, loginTo, cashToTransfer);
    }

    @PostMapping(params = {"cash_action", "login", "cash"}, produces = MediaType.APPLICATION_JSON_VALUE)
    public HttpStatus getOrPutCash(
            @RequestParam("cash_action") String cashAction,
            @RequestParam("login") String login,
            @RequestParam("cash") BigDecimal cash
    ) {
        if (cashAction.equals("GET_CASH")) {
            pullNotificationService.pullNotification("пользователь " + login + " снял наличные на сумму " + cash);
            return transferService.getCash(login, cash);
        } else if (cashAction.equals("PUT_CASH")) {
            pullNotificationService.pullNotification("пользователь " + login + " внес наличные на сумму " + cash);
            return transferService.putCash(login, cash);
        }
        return HttpStatus.BAD_REQUEST;
    }
}

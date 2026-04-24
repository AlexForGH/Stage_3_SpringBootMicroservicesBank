package org.pl.controller;

import org.pl.model.Cash;
import org.pl.service.CashService;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

@RestController
@RequestMapping("${api.cash.base.endpoint}")
@EnableMethodSecurity
public class CashController {

    private final CashService cashService;

    public CashController(CashService cashService) {
        this.cashService = cashService;
    }

    @PreAuthorize("hasRole('MANAGE_SELF_CASH')")
    @GetMapping(params = "login", produces = MediaType.APPLICATION_JSON_VALUE)
    public Cash findByLogin(@RequestParam String login) {
        return cashService.findByLogin(login);
    }

    @PreAuthorize("hasRole('MANAGE_SELF_CASH')")
    @PostMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public HttpStatus transferCash(
            @RequestParam("login_f") String loginFrom,
            @RequestParam("login_t") String loginTo,
            @RequestParam("c_t_t") BigDecimal cashToTransfer
    ) {
        return cashService.transferCash(loginFrom, loginTo, cashToTransfer);
    }

    @PreAuthorize("hasRole('MANAGE_SELF_CASH')")
    @PostMapping(params = {"cash_action", "login", "cash"}, produces = MediaType.APPLICATION_JSON_VALUE)
    public HttpStatus getOrPutCash(
            @RequestParam("cash_action") String cashAction,
            @RequestParam("login") String login,
            @RequestParam("cash") BigDecimal cash
    ) {
        if (cashAction.equals("GET_CASH")) {
            return cashService.getCash(login, cash);
        } else if (cashAction.equals("PUT_CASH")) {
            return cashService.putCash(login, cash);
        }
        return HttpStatus.BAD_REQUEST;
    }
}

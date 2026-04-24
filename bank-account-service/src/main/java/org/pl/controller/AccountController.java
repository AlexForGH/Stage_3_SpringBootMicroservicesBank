package org.pl.controller;

import org.pl.controller.dto.CashResponse;
import org.pl.model.Account;
import org.pl.service.AccountService;
import org.pl.service.GetCashService;
import org.pl.service.PullNotificationService;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@EnableMethodSecurity
@RestController
@RequestMapping("${api.account.base.endpoint}")
public class AccountController {

    private final AccountService accountService;
    private final GetCashService getCashService;
    private final PullNotificationService pullNotificationService;

    public AccountController(
            AccountService accountService,
            GetCashService getCashService,
            PullNotificationService pullNotificationService
    ) {
        this.accountService = accountService;
        this.getCashService = getCashService;
        this.pullNotificationService = pullNotificationService;
    }

    @PreAuthorize("hasRole('MANAGE_SELF_INFO')")
    @GetMapping(params = "login", produces = MediaType.APPLICATION_JSON_VALUE)
    public Account findByLogin(@RequestParam String login) {
        CashResponse cashResponse = getCashService.getCashResponse(login);
        Account account = accountService.findByLogin(login);
        account.setCash(cashResponse.getCash());
        pullNotificationService.pullNotification("передан в UI аккаунт: " + account);
        return account;
    }

    @PreAuthorize("hasRole('MANAGE_SELF_INFO')")
    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public List<Account> findAll() {
        List<Account> accounts = accountService.findAll();
        pullNotificationService.pullNotification("передан в UI список аккаунтов: " + accounts.toString());
        return accounts;
    }

    @PreAuthorize("hasRole('MANAGE_SELF_INFO')")
    @PostMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public Account updateAccount(
            @RequestParam("login") String login,
            @RequestParam("new_fn") String newFirstName,
            @RequestParam("new_ln") String newLastName,
            @RequestParam("new_bd") LocalDate newBirthDate
    ) {
        Account account = accountService.findByLogin(login);
        account.setFirstName(newFirstName);
        account.setLastName(newLastName);
        account.setBirthDate(newBirthDate);

        accountService.save(account);
        pullNotificationService.pullNotification("обновлен и передан в UI аккаунт: " + account);
        return accountService.save(account);
    }
}

package org.pl.controller;

import org.pl.controller.dto.AccountResponse;
import org.pl.service.GetAccountDataService;
import org.pl.service.TransferFuncService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Controller
@EnableMethodSecurity
public class FrontUIController {

    private final GetAccountDataService getAccountDataService;
    private final TransferFuncService transferFuncService;

    @Value("${api.front_ui.endpoint.account}")
    private String apiFrontUIEndpointAccount;

    public FrontUIController(GetAccountDataService getAccountDataService, TransferFuncService transferFuncService) {
        this.getAccountDataService = getAccountDataService;
        this.transferFuncService = transferFuncService;
    }

    @GetMapping
    public String index() {
        return "redirect:" + apiFrontUIEndpointAccount;
    }

    @PreAuthorize("hasRole('MANAGE_SELF_INFO')")
    @GetMapping("${api.front_ui.endpoint.account}")
    public String getAccount(@RequestParam String login, Model model) {
        AccountResponse accountResponse = getAccountDataService.getAccountResponse(login);
        fillModel(
                model,
                accountResponse,
                getAccountDataService.getAccountResponses(),
                "Добро пожаловать уважаемый пользователь " + accountResponse.getLogin(),
                null
        );
        return "main";
    }

    @PreAuthorize("hasRole('MANAGE_SELF_INFO')")
    @PostMapping("${api.front_ui.endpoint.account}")
    public String editAccount(
            Model model,
            @RequestParam("login") String login,
            @RequestParam("first_name") String firstName,
            @RequestParam("last_name") String lastName,
            @RequestParam("birthdate") LocalDate birthdate
    ) {
        AccountResponse accountResponse = getAccountDataService.postAccountChangesData(
                login,
                firstName,
                lastName,
                birthdate
        );
        fillModel(
                model,
                accountResponse,
                getAccountDataService.getAccountResponses(),
                "Добро пожаловать уважаемый пользователь " + accountResponse.getLogin(),
                null
        );
        return "redirect:" + apiFrontUIEndpointAccount + "?login=" + login;
    }

    @PreAuthorize("hasRole('MANAGE_SELF_CASH')")
    @PostMapping("${api.front_ui.endpoint.cash}")
    public String getOrPutCash(
            Model model,
            @RequestParam("login") String login,
            @RequestParam("cash") BigDecimal cash,
            @RequestParam("cash_action") String cashAction
    ) {
        if (cashAction.equals("GET_CASH")) {
            HttpStatus httpStatus = transferFuncService.getCash(login, cash);
            AccountResponse accountResponse = getAccountDataService.getAccountResponse(login);
            List<AccountResponse> accountResponses = getAccountDataService.getAccountResponses();
            if (httpStatus.is2xxSuccessful()) {
                fillModel(
                        model,
                        accountResponse,
                        accountResponses,
                        "Снятие наличных проведено успешно",
                        null
                );
            } else {
                fillModel(
                        model,
                        accountResponse,
                        accountResponses,
                        null,
                        "Ошибка снятия наличных (похоже, у вас недостаточный баланс)"
                );
            }
        } else if (cashAction.equals("PUT_CASH")) {
            HttpStatus httpStatus = transferFuncService.putCash(login, cash);
            AccountResponse accountResponse = getAccountDataService.getAccountResponse(login);
            List<AccountResponse> accountResponses = getAccountDataService.getAccountResponses();
            if (httpStatus.is2xxSuccessful()) {
                fillModel(
                        model,
                        accountResponse,
                        accountResponses,
                        "Пополнение наличных проведено успешно",
                        null
                );
            } else {
                fillModel(
                        model,
                        accountResponse,
                        accountResponses,
                        null,
                        "Непредвиденная шибка"
                );
            }
        }
        return "main";
    }

    @PreAuthorize("hasRole('MANAGE_SELF_CASH')")
    @PostMapping("${api.front_ui.endpoint.transfer}")
    public String transferCash(
            Model model,
            @RequestParam("login_from") String loginFrom,
            @RequestParam("login_to") String loginTo,
            @RequestParam("cash_to_transfer") BigDecimal cashToTransfer
    ) {
        HttpStatus httpStatus = transferFuncService.transferCash(loginFrom, loginTo, cashToTransfer);
        AccountResponse accountResponse = getAccountDataService.getAccountResponse(loginFrom);
        List<AccountResponse> accountResponses = getAccountDataService.getAccountResponses();
        if (httpStatus.is2xxSuccessful()) {
            fillModel(
                    model,
                    accountResponse,
                    accountResponses,
                    "Успешный перевод пользователю " + loginTo,
                    null
            );
        } else {
            fillModel(
                    model,
                    accountResponse,
                    accountResponses,
                    null,
                    "Ошибка перевода пользователю " + loginTo + " (похоже, у вас недостаточный баланс)"
            );
        }
        return "main";
    }

    private void fillModel(
            Model model,
            AccountResponse accountResponse,
            List<AccountResponse> accountResponses,
            String info,
            String error
    ) {
        if (info != null) {
            model.addAttribute("info", info);
        }
        if (error != null) {
            model.addAttribute("error", error);
        }
        model.addAttribute("login", accountResponse.getLogin());
        model.addAttribute("first_name", accountResponse.getFirstName());
        model.addAttribute("last_name", accountResponse.getLastName());
        model.addAttribute("birthdate", accountResponse.getBirthDate().format(DateTimeFormatter.ISO_DATE));
        model.addAttribute("cash", accountResponse.getCash());
        model.addAttribute("accounts", accountResponses);
    }
}

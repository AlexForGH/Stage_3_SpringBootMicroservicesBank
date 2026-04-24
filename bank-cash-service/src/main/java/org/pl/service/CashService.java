package org.pl.service;

import org.pl.exception.CashDataNotFoundException;
import org.pl.model.Cash;
import org.pl.repo.CashRepo;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
public class CashService {

    private final CashRepo cashRepo;

    public CashService(CashRepo cashRepo) {
        this.cashRepo = cashRepo;
    }

    public Cash findByLogin(String login) {
        return cashRepo.findByLogin(login)
                .orElseThrow(() -> new CashDataNotFoundException("Cash data not found by login: " + login));
    }

    @Transactional
    public HttpStatus transferCash(String loginFrom, String loginTo, BigDecimal cashToTransfer) {
        getCash(loginFrom, cashToTransfer);
        putCash(loginTo, cashToTransfer);
        return HttpStatus.OK;
    }

    @Transactional
    public HttpStatus getCash(String login, BigDecimal cash) {
        Cash _cash = findByLogin(login);
        _cash.setCash(_cash.getCash().subtract(cash));
        cashRepo.save(_cash);
        return HttpStatus.OK;
    }

    @Transactional
    public HttpStatus putCash(String login, BigDecimal cash) {
        Cash _cash = findByLogin(login);
        _cash.setCash(_cash.getCash().add(cash));
        cashRepo.save(_cash);
        return HttpStatus.OK;
    }
}

package org.pl.service;

import org.pl.exception.AccountNotFoundException;
import org.pl.model.Account;
import org.pl.repo.AccountRepo;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class AccountService {

    private final AccountRepo accountRepo;

    public AccountService(AccountRepo accountRepo) {
        this.accountRepo = accountRepo;
    }

    @Transactional
    public Account findByLogin(String login) {
        return accountRepo.findByLogin(login)
                .orElseThrow(() -> new AccountNotFoundException("Account not found with login: " + login));
    }

    @Transactional
    public List<Account> findAll() {
        return accountRepo.findAll();
    }

    @Transactional
    public Account save(Account account) {
        return accountRepo.save(account);
    }
}

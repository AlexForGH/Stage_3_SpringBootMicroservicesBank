package org.pl.repo;

import org.pl.model.Cash;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CashRepo extends JpaRepository<Cash, Long> {
    Optional<Cash> findByLogin(String login);
}

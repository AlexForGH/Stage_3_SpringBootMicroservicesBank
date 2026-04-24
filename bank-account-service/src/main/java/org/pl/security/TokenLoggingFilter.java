package org.pl.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Base64;

@Component
@Slf4j
public class TokenLoggingFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain chain) throws IOException, ServletException {

        String authHeader = request.getHeader("Authorization");

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            log.info("Входящий JWT: {}", token);

            // Разбираем середину JWT (payload)
            String[] parts = token.split("\\.");
            if (parts.length > 1) {
                String payload = new String(Base64.getUrlDecoder().decode(parts[1]));
                log.info("Payload: {}", payload);
            }
        } else {
            log.warn("Нет Authorization header");
        }

        chain.doFilter(request, response);
    }
}

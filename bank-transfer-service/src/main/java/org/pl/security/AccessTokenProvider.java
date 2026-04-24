package org.pl.security;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class AccessTokenProvider {

    public String getCurrentAccessToken() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null) {
            throw new IllegalStateException("No authentication in context");
        }

        // У Resource Server authentication — это JwtAuthenticationToken или BearerTokenAuthentication
        if (authentication instanceof JwtAuthenticationToken jwtAuth) {
            // JwtAuthenticationToken содержит Jwt напрямую
            return jwtAuth.getToken().getTokenValue();
        }

        // Альтернативный вариант
        if (authentication.getCredentials() instanceof Jwt jwt) {
            return jwt.getTokenValue();
        }

        throw new IllegalStateException("Cannot extract JWT from authentication: " + authentication.getClass());
    }
}
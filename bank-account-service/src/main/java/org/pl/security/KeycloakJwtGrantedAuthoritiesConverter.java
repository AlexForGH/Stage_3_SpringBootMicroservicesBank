package org.pl.security;

import lombok.extern.slf4j.Slf4j;
import org.springframework.core.convert.converter.Converter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Component;

import java.util.Collection;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

@Component
@Slf4j
public class KeycloakJwtGrantedAuthoritiesConverter implements Converter<Jwt, Collection<GrantedAuthority>> {

    @Override
    public Collection<GrantedAuthority> convert(Jwt jwt) {
        Set<GrantedAuthority> authorities = new HashSet<>();

        // 1. Realm roles
        Map<String, Object> realmAccess = jwt.getClaimAsMap("realm_access");
        log.info("realm_access: {}", realmAccess);

        if (realmAccess != null && realmAccess.containsKey("roles")) {
            Object rolesObj = realmAccess.get("roles");
            log.info("roles object: {} (type: {})", rolesObj,
                    rolesObj != null ? rolesObj.getClass().getName() : "null");

            if (rolesObj instanceof Collection<?> roles) {
                roles.stream()
                        .map(Object::toString)
                        .peek(role -> log.info("➕ Adding role: ROLE_{}", role))
                        .map(role -> "ROLE_" + role)
                        .map(SimpleGrantedAuthority::new)
                        .forEach(authorities::add);
            }
        }

        log.info("Final authorities: {}", authorities);
        return authorities;
    }
}
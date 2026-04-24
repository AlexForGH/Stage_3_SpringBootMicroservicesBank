package org.pl.security;

import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.client.oidc.userinfo.OidcUserRequest;
import org.springframework.security.oauth2.client.oidc.userinfo.OidcUserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserService;
import org.springframework.security.oauth2.core.oidc.user.DefaultOidcUser;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * ПИШУ ПОЯСНЕНИЯ ДЛЯ СЕБЯ, т.к. есть еще вариант реактивной реализации - легко запутаться
 * KeycloakOAuth2UserService нужен для парсинга JWT вручную, т.к. Spring Security по умолчанию
 * не умеет доставать роли из Keycloak. Они сидят внутри JWT в полях realm_access и
 * resource_access. Поэтому нужно самим лезть в токен и выдираем их оттуда
 * OAuth2UserService<OidcUserRequest, OidcUser> - это контракт  "на вход OidcUserRequest,
 * на выход OidcUserSpring", Security будет дёргать этот метод, когда нужно загрузить
 * пользователя из Keycloak
 */
@Slf4j
@Component
public class KeycloakOAuth2UserService implements OAuth2UserService<OidcUserRequest, OidcUser> {

    @Value("${spring.security.oauth2.client.registration.keycloak.client-id}")
    private String clientId;

    @Value("${spring.security.oauth2.client.provider.keycloak.jwk-set-uri}")
    private String jwkSetUri;  // Берем прямо из конфига!

    // Стандартный сервис Spring Security. Он умеет загружать базового OIDC-юзера
    // со скоупами (SCOPE_openid, SCOPE_profile). Нужен, чтобы не делать всю
    // работу с нуля
    private final OidcUserService delegate = new OidcUserService();

    // Декодер JWT-токенов. Будет проверять подпись, срок, issuer.
    // Не final, потому что инициализируем в @PostConstruct (нужен @Value)
    // см. ниже
    private JwtDecoder jwtDecoder;

    // Зачем так (через @PostConstruct): Java сначала инициализирует поля, потом засовывает @Value.
    // То есть если просто объявлять переменную, которая использует в себе keycloakIssuerUri,
    // он будет ещё null
    @PostConstruct
    public void init() {
        log.info("Initializing JwtDecoder with JWK Set URI: {}", jwkSetUri);
        this.jwtDecoder = NimbusJwtDecoder.withJwkSetUri(jwkSetUri).build();
    }

    // Это точка входа. Spring Security передаёт сюда userRequest,
    // внутри которого access token, refresh token, client registration и т.д.
    @Override
    public OidcUser loadUser(OidcUserRequest userRequest) {
        // Берем стандартный OIDC-сервис.
        // Он:
        //   Сходит в UserInfo endpoint Keycloak
        //   Соберёт базового пользователя
        //   Навешает authorities типа SCOPE_openid, SCOPE_profile, SCOPE_email
        // Получаем готового OIDC-юзера, но без кастомных ролей
        OidcUser oidcUser = delegate.loadUser(userRequest);

        // 1. Парсим access token (строка JWT)
        //    Декодим и валидируем:
        //        Проверяем подпись (через JWK Set)
        //        Проверяем, что токен не просрочен
        //        Проверяем issuer (должен совпадать с нашим keycloakIssuerUri)
        //        Проверяем audience и т.д.
        //    На выходе — объект Jwt с типизированными методами доступа к claims
        Jwt jwt = jwtDecoder.decode(userRequest.getAccessToken().getTokenValue());

        // 2. Достаём realm-level роли
        Set<GrantedAuthority> realmRoles = extractRealmRoles(jwt);

        // 3. Достаём client-level роли для нашего клиента
        Set<GrantedAuthority> clientRoles = extractClientRoles(jwt, clientId);

        // 4. Склеиваем authorities
        List<GrantedAuthority> authorities = new ArrayList<>();
        authorities.addAll(oidcUser.getAuthorities());
        authorities.addAll(realmRoles);
        authorities.addAll(clientRoles);

        // Создаём нового OIDC-юзера:
        //    С нашими authorities (включая роли)
        //    С токенами от базового пользователя
        //    Явно указываем, что имя брать из поля preferred_username, а не из sub
        // Возвращаем в Spring Security, и он кладёт этого пользователя в
        // контекст безопасности
        return new DefaultOidcUser(
                authorities,
                oidcUser.getIdToken(),
                oidcUser.getUserInfo(),
                "preferred_username"
        );

        /**
         * Вся цепочка целиком:
         *     Приходит запрос с кодом авторизации
         *     Spring Security обменивает код на токены
         *     Вызывает KeycloakOAuth2UserService.loadUser()
         *     Мы дёргаем delegate.loadUser() → получаем базового пользователя
         *     Валидируем access token через JwtDecoder
         *     Выдираем роли из токена
         *     Склеиваем authorities
         *     Отдаём Spring Security готового пользователя с ролями
         *     Дальше OidcSuccessHandler проверяет роль ROLE_USER и редиректит
         */
    }

    private Set<GrantedAuthority> extractRealmRoles(Jwt jwt) {
        // HashSet — чтобы избежать дублей (вдруг Keycloak дважды одну роль пришлёт)
        Set<GrantedAuthority> authorities = new HashSet<>();

        // Достаём claim realm_access. Это JSON-объект вида:
        //                {
        //                  "realm_access": {
        //                    "roles": ["user", "admin", "offline_access"]
        //                  }
        //                }
        // getClaimAsMap возвращает Map<String, Object> или null, если claim'а нет
        Map<String, Object> realmAccess = jwt.getClaimAsMap("realm_access");

        // Проверяем на null (обязательно, иначе NPE)
        // Кастим roles к списку строк
        // Для каждой роли:
        //    Добавляем префикс ROLE_ (Spring Security convention)
        //    Оборачиваем в SimpleGrantedAuthority
        //    Кладём в Set
        if (realmAccess != null) {
            List<String> roles = (List<String>) realmAccess.get("roles");
            if (roles != null) {
                roles.forEach(role ->
                        authorities.add(new SimpleGrantedAuthority("ROLE_" + role))
                );
            }
        }

        log.warn("Extracted realm roles: {}", authorities);
        return authorities;
    }

    // По текущим настройкам keycloak таких ролей для клиентов нет, но для справки
    private Set<GrantedAuthority> extractClientRoles(Jwt jwt, String clientId) {
        Set<GrantedAuthority> authorities = new HashSet<>();

        // Достаём resource_access. В Keycloak там лежат роли для конкретных клиентов:
        //                {
        //                    "resource_access": {
        //                    "bank-front-ui-service": {
        //                        "roles": ["front-user", "manager"]
        //                    },
        //                    "account-service": {
        //                        "roles": ["reader"]
        //                    }
        //                  }
        //                }
        Map<String, Object> resourceAccess = jwt.getClaimAsMap("resource_access");
        //  Берём объект для нашего конкретного clientId
        //  Из него достаём roles
        //  Добавляем с префиксом ROLE_
        if (resourceAccess != null) {
            Map<String, Object> clientAccess = (Map<String, Object>) resourceAccess.get(clientId);
            if (clientAccess != null) {
                List<String> roles = (List<String>) clientAccess.get("roles");
                if (roles != null) {
                    roles.forEach(role ->
                            authorities.add(new SimpleGrantedAuthority("ROLE_" + role))
                    );
                }
            }
        }
        log.warn("Extracted client roles: {}", authorities);
        return authorities;
    }
}
package org.pl.config;

import lombok.RequiredArgsConstructor;
import org.pl.security.KeycloakOAuth2UserService;
import org.pl.security.OidcSuccessHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;

/**
 * ПИШУ ПОЯСНЕНИЯ ДЛЯ СЕБЯ, т.к. есть еще вариант реактивной реализации - легко запутаться
 */
@Configuration
@RequiredArgsConstructor
public class SecurityConfig {

    private final KeycloakOAuth2UserService keycloakOAuth2UserService;
    private final OidcSuccessHandler oidcSuccessHandler;

    /**
     * Это точка входа всей конфигурации безопасности. SecurityFilterChain — это
     * цепочка фильтров, через которую проходят все HTTP-запросы. Каждый фильтр что-то
     * проверяет: аутентификацию, CSRF, заголовки и т.д.
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) {
        http
                // Блок настройки авторизации запросов
                // Любой запрос к любому эндпоинту требует аутентификации.
                // Никаких открытых страниц, никакого сваггера, ничего.
                // Либо залогинен, либо получаем 401
                .authorizeHttpRequests(auth -> auth
                        // Все запросы требуют аутентификации
                        .anyRequest().authenticated()
                )
                // Отключаем CSRF-защиту. Обычно так делают, когда API используется
                // только мобильными приложениями или SPA, где CSRF-токены не хранятся
                // в cookies. Если тут будет веб-форма с куками — это уязвимость
                .csrf(AbstractHttpConfigurer::disable)
                // Включаем OAuth2/OIDC логин через провайдера (Keycloak).
                // Тут два важных момента:
                //    successHandler —  после успешной аутентификации не идем на
                //                      дефолтную страницу, а вызываем наш хендлер,
                //                      который проверит роль USER
                //    oidcUserService — вместо стандартного провайдера информации о
                //                      пользователе используем наш, который накачает
                //                      роли из токена
                // Неавторизованный пользователь будет перенаправлен на страницу логина провайдера
                .oauth2Login(oauth2 -> oauth2
                        .successHandler(oidcSuccessHandler) // кастомный обработчик в случае успешного входа
                        .userInfoEndpoint(userInfo -> userInfo
                                .oidcUserService(keycloakOAuth2UserService)
                        )
                )
                // Блок настройки выхода из системы
                .logout(logout -> logout
                        // После успешного выхода перенаправляем пользователя на главную страницу
                        .logoutSuccessUrl("/")
                        // Разрешаем всем вызывать эндпоинт выхода
                        .permitAll()
                );

        // Строим и возвращаем цепочку фильтров безопасности
        return http.build();
    }
}

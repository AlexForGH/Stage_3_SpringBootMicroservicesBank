package org.pl.security;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * ПИШУ ПОЯСНЕНИЯ ДЛЯ СЕБЯ, т.к. есть еще вариант реактивной реализации - легко запутаться
 * OidcSuccessHandler нужен для проверки ролей и редиректа. В данном случае для сценария:
 * после успешного входа через OAuth2 нужно проверить, есть ли у пользователя роль USER,
 * если нет - отлуп, если есть - редирект на фронт с логином в URL
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class OidcSuccessHandler implements AuthenticationSuccessHandler {

    @Value("${api.front_ui.base_url}")
    private String selfBaseUrl;

    @Value("${api.front_ui.endpoint.account}")
    private String frontUIEndpointAccount;

    @Override
    public void onAuthenticationSuccess(
            HttpServletRequest request,
            HttpServletResponse response,
            Authentication authentication
    ) throws IOException {
        // Убеждаемся, что это именно OAuth2-аутентификация. Если кто-то зашел через
        // basic auth или form login — нас это не интересует
        if (authentication instanceof OAuth2AuthenticationToken oauth2Token) {
            // Получаем OAuth пользователя из токена
            OAuth2User oAuth2User = oauth2Token.getPrincipal();
            // Получаем имя пользователя из атрибутов принципала
            String username = oAuth2User.getAttribute("preferred_username");
            // Если preferred_username нет, можно взять login или sub
            if (username == null) {
                username = oauth2Token.getName(); // обычно это sub
            }

            // Проверка: есть ли у пользователя роль USER
            log.warn("Authorities list for user {}: {}", username, oAuth2User.getAuthorities());
            boolean hasUserRole = oAuth2User.getAuthorities()
                    .stream()
                    .anyMatch(auth -> auth.getAuthority().equals("ROLE_USER"));

            // Пропускаем только тех, у кого есть роль ROLE_USER. Если у пользователя
            // только ROLE_ADMIN или вообще нет ролей - 401.
            // Возвращаем 401, никакого редиректа. Пользователь висит
            // в Keycloak, залогинен, но наш бек его не пускает, т.к. такой макет html
            if (!hasUserRole) {
                log.warn("Access denied: user {} has not role ROLE_USER", username);
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }

            // Кодируем логин на всякий случай
            String encodedUsername = URLEncoder.encode(username, StandardCharsets.UTF_8);

            // Перенаправляем на нужный URL: отправляем пользователя на фронт, в URL параметр login.
            // Фронт подхватит и отобразит соответствующую инфу
            response.sendRedirect(selfBaseUrl + frontUIEndpointAccount + "?login=" + encodedUsername);
        } else {
            response.sendRedirect("/");
        }
    }
}

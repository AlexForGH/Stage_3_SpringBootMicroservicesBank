package org.pl.security;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientService;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class AccessTokenProvider {

    private final OAuth2AuthorizedClientService authorizedClientService;

    public String getAccessToken() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication instanceof OAuth2AuthenticationToken oauthToken) {
            String clientRegistrationId = oauthToken.getAuthorizedClientRegistrationId();
            String principalName = oauthToken.getName();

            OAuth2AuthorizedClient authorizedClient = authorizedClientService.loadAuthorizedClient(
                    clientRegistrationId, principalName);

            if (authorizedClient != null) {
                return authorizedClient.getAccessToken().getTokenValue();
            }
        }

        throw new IllegalStateException("Нет активного access token");
    }
}

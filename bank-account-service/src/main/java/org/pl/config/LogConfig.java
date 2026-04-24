package org.pl.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class LogConfig {

    @Bean(name = "customLogger")
    public Logger customLogger() {
        return LoggerFactory.getLogger("MY_LOGGER");
    }
}

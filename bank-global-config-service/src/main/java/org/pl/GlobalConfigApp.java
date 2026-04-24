package org.pl;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.config.server.EnableConfigServer;

@SpringBootApplication
@EnableConfigServer // Аннотация для включения режима Config Server
public class GlobalConfigApp {
    public static void main(String[] args) {
        SpringApplication.run(GlobalConfigApp.class, args);
    }
}

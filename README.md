# Stage_3_SpringBootMicroservicesBank

![Демо работы](./demo.gif)

## *EN*
#### The project demonstrates development capabilities using Spring Boot microservice application, configuration management organization via Spring Boot Cloud, and security implementation through Spring Security and Keycloak
#### Technology stack: Spring Framework, Spring Boot, PostgreSQL, HTML, Thymeleaf, Spring Web, Spring Data JPA, Spring Cloud, Docker (Multi Stage Build), Docker Compose, RESTful API, Spring Security, Keycloak

### Application features:
    - user editing their own data
    - simulation of balance withdrawal/deposit by user
    - funds transfer to another user

### Application deployment:
    - Before you begin, you'll need:
            - Java (JRE) (version 23 was used during project development)
            - Docker (Multi Stage Build)
    1. Using an IDE (IntelliJIdea was used during project development):
            - clone the repository
            - open the project in the IDE
            - build project on the host: ./mvnw clean package -DskipTests
                    or
            - uncomment service build stages in Dockerfiles
            - right‑click on the docker-compose.yml and select “Run docker-compose.yml”
            - open a browser at http://localhost:8080/
            - the Keycloak admin panel will open
            - create users according to Schema.sql from the bank-account-service/bank-cash-service
            - assign them the appropriate roles/rights
            - go to the browser at http://localhost:10005/
            - the application's start page will open
      2. Without an IDE
            - clone the repository
            - build project on the host: ./mvnw clean package -DskipTests
                    or
            - uncomment service build stages in Dockerfiles
            - run the following Docker commands:
                - docker compose up --build
            - open a browser at http://localhost:8080/
            - the Keycloak admin panel will open
            - create users according to Schema.sql from the bank-account-service/bank-cash-service
            - assign them the appropriate roles/rights
            - run the following Docker commands:
                    - docker compose up --build
            - go to the browser at http://localhost:10005/
            - the application's start page will open


## *RU*
#### Проект для демонстрации возможностей разработки с использованием Spring Boot микросервисного приложения, организации управления конфигурациями через Spring Boot Cloud и обеспечения безопасности через Spring Security и Keycloak
#### Технологический стек: Spring Framework, Spring Boot, PostgreSQL, HTML, Thymeleaf, Spring Web, Spring Data JPA, Spring Cloud, Docker (Multi Stage Build), Docker Compose, RESTful API, Spring Security, Keycloak

### Возможности приложения:
    - редактирование пользоватлем своих данных
    - имитация снятия/пополнения пользователем своего баланса
    - перевод средств другому пользователю

### Развертывание приложения:
    - Перед началом работы необходимы:
            - Java (JRE) (при разработке проекта использовалась версия 23)
            - Docker (Multi Stage Build)
    1. Через IDE (при разработке проекта использовалась IntelliJIdea):
            - клонировать репозиторий
            - открыть проект в IDE
            - собрать проект на хосте: ./mvnw clean package -DskipTests
                    либо
            - раскомментировать в Docker-файлах этапы сборки серсивов
            - нажать ПКМ на docker-compose.yml и выбрать "Run docker-compose.yml"
            - зайти в браузер по адресу http://localhost:8080/
            - откроется admin-панель Keycloak
            - создать пользователей в соответствии с schema.sql из bank-account-service/bank-cash-service
            - назначить им соответствующие роли/права
            - зайти в браузер по адресу http://localhost:10005/
            - откроется стартовая страница приложения
    2. Без использования IDE
            - клонировать репозиторий
            - собрать проект на хосте: ./mvnw clean package -DskipTests
                    либо
            - раскомментировать в Docker-файлах этапы сборки серсивов
            - выполнить команды докера:
                - docker compose up --build
            - зайти в браузер по адресу http://localhost:8080/
            - откроется admin-панель Keycloak
            - создать пользователей в соответствии с schema.sql из bank-account-service/bank-cash-service
            - назначить им соответствующие роли/права
            - выполнить команды докера:
                    - docker compose up --build
            - зайти в браузер по адресу http://localhost:10005/
            - откроется стартовая страница приложения

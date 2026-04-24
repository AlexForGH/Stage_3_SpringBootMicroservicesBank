#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🚀 Starting build process...${NC}\n"

# Массив Java микросервисов
java_services=(
    "global-config"
    "cash"
    "account"
    "transfer"
    "notification"
    "front-ui"
)

# Инфраструктурные сервисы (тоже с префиксом bank-)
infra_services=(
    "keycloak"
    "postgres"
)

echo -e "${YELLOW}📦 Building all Spring Boot microservices with mvnw...${NC}\n"

# Собираем все микросервисы
./mvnw clean package -DskipTests

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Maven build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All Spring Boot microservices built successfully${NC}\n"

echo -e "${YELLOW}🐳 Building Docker images for Java microservices...${NC}\n"

# Собираем Docker образы для Java микросервисов
for service in "${java_services[@]}"; do
    echo -e "${YELLOW}🔨 Building bank-$service:latest from Dockerfile.$service...${NC}"

    # Проверяем существование Dockerfile
    if [ ! -f "Dockerfile.$service" ]; then
        echo -e "${RED}❌ Dockerfile.$service not found!${NC}"
        exit 1
    fi

    # Собираем образ
    docker build -t "bank-$service:latest" -f "Dockerfile.$service" .

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Successfully built bank-$service:latest${NC}"
    else
        echo -e "${RED}❌ Failed to build bank-$service:latest${NC}"
        exit 1
    fi
    echo "------------------------"
done

echo -e "${YELLOW}🐳 Building Docker images for infrastructure services...${NC}\n"

# Собираем инфраструктурные сервисы (тоже с префиксом bank-)
for service in "${infra_services[@]}"; do
    echo -e "${YELLOW}🔨 Building bank-$service:latest from Dockerfile.$service...${NC}"

    # Проверяем существование Dockerfile
    if [ ! -f "Dockerfile.$service" ]; then
        echo -e "${RED}❌ Dockerfile.$service not found!${NC}"
        exit 1
    fi

    # Собираем образ
    docker build -t "bank-$service:latest" -f "Dockerfile.$service" .

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Successfully built bank-$service:latest${NC}"
    else
        echo -e "${RED}❌ Failed to build bank-$service:latest${NC}"
        exit 1
    fi
    echo "------------------------"
done

echo -e "\n${GREEN}🎉 All Docker images built successfully!${NC}"
echo -e "\n${YELLOW}📋 Built images:${NC}"
docker images | grep "bank-"

echo -e "\n${GREEN}✨ Build process complete!${NC}"
echo -e "${YELLOW}💡 Теперь устанавливайте Helm чарт: cd bank-chart && helm install bank-app .${NC}"
#!/bin/bash

# Создаем структуру директорий
mkdir -p bank-chart/charts/{keycloak,postgres,global-config,cash,account,transfer,notification,front-ui}/templates

# Создаем корневой Chart.yaml
cat > bank-chart/Chart.yaml << 'EOF'
apiVersion: v2
name: bank-chart
description: Bank microservices application
type: application
version: 0.1.0
appVersion: 1.0.0

dependencies:
  - name: keycloak
    version: 0.1.0
    condition: keycloak.enabled
  - name: postgres
    version: 0.1.0
    condition: postgres.enabled
  - name: global-config
    version: 0.1.0
    condition: global-config.enabled
  - name: cash
    version: 0.1.0
    condition: cash.enabled
  - name: account
    version: 0.1.0
    condition: account.enabled
  - name: transfer
    version: 0.1.0
    condition: transfer.enabled
  - name: notification
    version: 0.1.0
    condition: notification.enabled
  - name: front-ui
    version: 0.1.0
    condition: front-ui.enabled
EOF

# Создаем корневой values.yaml
cat > bank-chart/values.yaml << 'EOF'
global:
  serviceUrls:
    keycloak: "http://keycloak-service:8080"
    postgres: "postgres-service:5432"
    globalConfig: "http://bank-global-config-service:10000"
    cash: "http://bank-cash-service:10001"
    account: "http://bank-account-service:10002"
    transfer: "http://bank-transfer-service:10003"
    notification: "http://bank-notification-service:10004"
    frontUi: "http://bank-front-ui-service:30005"
    keycloakPublic: "http://localhost:30080"
  exposure:
    keycloak:
      type: NodePort
      nodePort: 30080
    frontUi:
      type: NodePort
      nodePort: 30005

keycloak:
  enabled: true
  replicaCount: 1
  image:
    repository: bank-keycloak
    tag: latest
    pullPolicy: IfNotPresent
  service:
    port: 8080
    targetPort: 8080
    name: keycloak-service
  resources:
    requests:
      memory: "512Mi"
      cpu: "500m"
    limits:
      memory: "1Gi"
      cpu: "1000m"
  probe:
    initialDelaySeconds: 60
    periodSeconds: 10
    timeoutSeconds: 3
    failureThreshold: 20

postgres:
  enabled: true
  replicaCount: 1
  image:
    repository: bank-postgres
    tag: latest
    pullPolicy: IfNotPresent
  service:
    port: 5432
    targetPort: 5432
    name: postgres-service
  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  persistence:
    enabled: true
    size: 1Gi
  probe:
    initialDelaySeconds: 5
    periodSeconds: 5
    timeoutSeconds: 5
    failureThreshold: 5

global-config:
  enabled: true
  replicaCount: 1
  image:
    repository: bank-global-config
    tag: latest
    pullPolicy: IfNotPresent
  service:
    port: 10000
    targetPort: 10000
    name: bank-global-config-service
  resources:
    requests:
      memory: "128Mi"
      cpu: "50m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  probe:
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 3
    failureThreshold: 10

cash:
  enabled: true
  replicaCount: 1
  image:
    repository: bank-cash
    tag: latest
    pullPolicy: IfNotPresent
  service:
    port: 10001
    targetPort: 10001
    name: bank-cash-service
  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  probe:
    initialDelaySeconds: 40
    periodSeconds: 10
    timeoutSeconds: 3
    failureThreshold: 10

account:
  enabled: true
  replicaCount: 1
  image:
    repository: bank-account
    tag: latest
    pullPolicy: IfNotPresent
  service:
    port: 10002
    targetPort: 10002
    name: bank-account-service
  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  probe:
    initialDelaySeconds: 40
    periodSeconds: 10
    timeoutSeconds: 3
    failureThreshold: 10

transfer:
  enabled: true
  replicaCount: 1
  image:
    repository: bank-transfer
    tag: latest
    pullPolicy: IfNotPresent
  service:
    port: 10003
    targetPort: 10003
    name: bank-transfer-service
  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  probe:
    initialDelaySeconds: 40
    periodSeconds: 10
    timeoutSeconds: 3
    failureThreshold: 10

notification:
  enabled: true
  replicaCount: 1
  image:
    repository: bank-notification
    tag: latest
    pullPolicy: IfNotPresent
  service:
    port: 10004
    targetPort: 10004
    name: bank-notification-service
  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  probe:
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 3
    failureThreshold: 10

front-ui:
  enabled: true
  replicaCount: 1
  image:
    repository: bank-front-ui
    tag: latest
    pullPolicy: IfNotPresent
  service:
    port: 30005
    targetPort: 30005
    name: bank-front-ui-service
  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  probe:
    initialDelaySeconds: 40
    periodSeconds: 10
    timeoutSeconds: 3
    failureThreshold: 10
EOF

# Функция для создания файлов Java микросервисов
create_java_subchart() {
  local name=$1
  local port=$2
  local initialDelay=$3
  local env_vars=$4
  local service_name="bank-${name}-service"

  # Chart.yaml
  cat > bank-chart/charts/$name/Chart.yaml << EOF
apiVersion: v2
name: $name
description: $name Service
type: application
version: 0.1.0
appVersion: 1.0.0
EOF

  # values.yaml
  cat > bank-chart/charts/$name/values.yaml << EOF
replicaCount: 1
image:
  repository: bank-$name
  tag: latest
  pullPolicy: IfNotPresent
service:
  port: $port
  targetPort: $port
  name: $service_name
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"
    cpu: "500m"
probe:
  initialDelaySeconds: $initialDelay
  periodSeconds: 10
  timeoutSeconds: 3
  failureThreshold: 10
EOF

  # deployment.yaml
  cat > bank-chart/charts/$name/templates/deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-$name
  labels:
    app: $name
    release: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: $name
      release: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: $name
        release: {{ .Release.Name }}
    spec:
      containers:
      - name: $name
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: {{ .Values.service.targetPort }}
        env:
        # Spring Cloud Config
        - name: GLOBAL_CONFIG_SERVER_URL
          value: {{ $.Values.global.serviceUrls.globalConfig }}
        - name: SPRING_CLOUD_CONFIG_FAIL_FAST
          value: "true"
        - name: SPRING_CLOUD_CONFIG_RETRY_MAX_ATTEMPTS
          value: "20"
        # Keycloak
        - name: KEYCLOAK_HOST
          value: {{ $.Values.global.serviceUrls.keycloak }}
        - name: KEYCLOAK_PUBLIC_HOST
          value: {{ $.Values.global.serviceUrls.keycloakPublic }}
        - name: SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI
          value: {{ $.Values.global.serviceUrls.keycloak }}/realms/bank-realm
$env_vars
        resources:
{{ toYaml .Values.resources | indent 10 }}
        livenessProbe:
          httpGet:
            path: /actuator/health/liveness
            port: {{ .Values.service.targetPort }}
          initialDelaySeconds: {{ .Values.probe.initialDelaySeconds }}
          periodSeconds: {{ .Values.probe.periodSeconds }}
          timeoutSeconds: {{ .Values.probe.timeoutSeconds }}
          failureThreshold: {{ .Values.probe.failureThreshold }}
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: {{ .Values.service.targetPort }}
          initialDelaySeconds: {{ .Values.probe.initialDelaySeconds }}
          periodSeconds: {{ .Values.probe.periodSeconds }}
          timeoutSeconds: {{ .Values.probe.timeoutSeconds }}
          failureThreshold: {{ .Values.probe.failureThreshold }}
      restartPolicy: Always
EOF

  # service.yaml
  cat > bank-chart/charts/$name/templates/service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.service.name }}
  labels:
    app: $name
    release: {{ .Release.Name }}
spec:
  type: {{ if eq .Chart.Name "front-ui" }}{{ .Values.global.exposure.frontUi.type }}{{ else }}ClusterIP{{ end }}
  ports:
  - port: {{ .Values.service.port }}
    targetPort: {{ .Values.service.targetPort }}
    protocol: TCP
    name: http
    {{- if and (eq .Chart.Name "front-ui") (eq .Values.global.exposure.frontUi.type "NodePort") }}
    nodePort: {{ .Values.global.exposure.frontUi.nodePort }}
    {{- end }}
  selector:
    app: $name
    release: {{ .Release.Name }}
EOF
}

# Создаем все Java микросервисы
create_java_subchart "global-config" "10000" "30" "        - name: DB_URL_PART
          value: {{ $.Values.global.serviceUrls.postgres }}"

create_java_subchart "cash" "10001" "40" "        - name: DB_URL_PART
          value: {{ $.Values.global.serviceUrls.postgres }}"

create_java_subchart "account" "10002" "40" "        - name: DB_URL_PART
          value: {{ $.Values.global.serviceUrls.postgres }}
        - name: CASH_SERVER_URL
          value: {{ $.Values.global.serviceUrls.cash }}
        - name: NOTIFICATION_SERVER_URL
          value: {{ $.Values.global.serviceUrls.notification }}"

create_java_subchart "transfer" "10003" "40" "        - name: CASH_SERVER_URL
          value: {{ $.Values.global.serviceUrls.cash }}
        - name: NOTIFICATION_SERVER_URL
          value: {{ $.Values.global.serviceUrls.notification }}"

create_java_subchart "notification" "10004" "30" ""

create_java_subchart "front-ui" "30005" "40" "        - name: ACCOUNT_SERVER_URL
          value: {{ $.Values.global.serviceUrls.account }}
        - name: TRANSFER_SERVER_URL
          value: {{ $.Values.global.serviceUrls.transfer }}"

# keycloak
cat > bank-chart/charts/keycloak/Chart.yaml << 'EOF'
apiVersion: v2
name: keycloak
description: Keycloak authentication service
type: application
version: 0.1.0
appVersion: 1.0.0
EOF

cat > bank-chart/charts/keycloak/values.yaml << 'EOF'
replicaCount: 1
image:
  repository: bank-keycloak
  tag: latest
  pullPolicy: IfNotPresent
service:
  port: 8080
  targetPort: 8080
  name: keycloak-service
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
probe:
  initialDelaySeconds: 60
  periodSeconds: 10
  timeoutSeconds: 3
  failureThreshold: 20
EOF

# keycloak deployment.yaml
cat > bank-chart/charts/keycloak/templates/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-keycloak
  labels:
    app: keycloak
    release: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: keycloak
      release: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: keycloak
        release: {{ .Release.Name }}
    spec:
      containers:
      - name: keycloak
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: {{ .Values.service.targetPort }}
        env:
        - name: KEYCLOAK_ADMIN
          value: "admin"
        - name: KEYCLOAK_ADMIN_PASSWORD
          value: "admin"
        - name: KC_HOSTNAME
          value: "localhost"
        - name: KC_HOSTNAME_PORT
          value: "{{ .Values.global.exposure.keycloak.nodePort }}"
        - name: KC_PROXY
          value: "edge"
        resources:
{{ toYaml .Values.resources | indent 10 }}
        livenessProbe:
          tcpSocket:
            port: {{ .Values.service.targetPort }}
          initialDelaySeconds: {{ .Values.probe.initialDelaySeconds }}
          periodSeconds: {{ .Values.probe.periodSeconds }}
          timeoutSeconds: {{ .Values.probe.timeoutSeconds }}
          failureThreshold: {{ .Values.probe.failureThreshold }}
        readinessProbe:
          tcpSocket:
            port: {{ .Values.service.targetPort }}
          initialDelaySeconds: {{ .Values.probe.initialDelaySeconds }}
          periodSeconds: {{ .Values.probe.periodSeconds }}
          timeoutSeconds: {{ .Values.probe.timeoutSeconds }}
          failureThreshold: {{ .Values.probe.failureThreshold }}
      restartPolicy: Always
EOF

# keycloak service.yaml
cat > bank-chart/charts/keycloak/templates/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.service.name }}
  labels:
    app: keycloak
    release: {{ .Release.Name }}
spec:
  type: {{ .Values.global.exposure.keycloak.type }}
  ports:
  - port: {{ .Values.service.port }}
    targetPort: {{ .Values.service.targetPort }}
    {{- if eq .Values.global.exposure.keycloak.type "NodePort" }}
    nodePort: {{ .Values.global.exposure.keycloak.nodePort }}
    {{- end }}
    protocol: TCP
    name: http
  selector:
    app: keycloak
    release: {{ .Release.Name }}
EOF

# postgres
cat > bank-chart/charts/postgres/Chart.yaml << 'EOF'
apiVersion: v2
name: postgres
description: PostgreSQL database
type: application
version: 0.1.0
appVersion: 1.0.0
EOF

cat > bank-chart/charts/postgres/values.yaml << 'EOF'
replicaCount: 1
image:
  repository: bank-postgres
  tag: latest
  pullPolicy: IfNotPresent
service:
  port: 5432
  targetPort: 5432
  name: postgres-service
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"
    cpu: "500m"
persistence:
  enabled: true
  size: 1Gi
probe:
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 5
  failureThreshold: 5
EOF

cat > bank-chart/charts/postgres/templates/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-postgres
  labels:
    app: postgres
    release: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: postgres
      release: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: postgres
        release: {{ .Release.Name }}
    spec:
      containers:
      - name: postgres
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: {{ .Values.service.targetPort }}
        env:
        - name: POSTGRES_DB
          value: "my_schema"
        - name: POSTGRES_USER
          value: "user"
        - name: POSTGRES_PASSWORD
          value: "pass"
        resources:
{{ toYaml .Values.resources | indent 10 }}
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql
        livenessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - user
            - -d
            - my_schema
          initialDelaySeconds: {{ .Values.probe.initialDelaySeconds }}
          periodSeconds: {{ .Values.probe.periodSeconds }}
          timeoutSeconds: {{ .Values.probe.timeoutSeconds }}
          failureThreshold: {{ .Values.probe.failureThreshold }}
        readinessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - user
            - -d
            - my_schema
          initialDelaySeconds: {{ .Values.probe.initialDelaySeconds }}
          periodSeconds: {{ .Values.probe.periodSeconds }}
          timeoutSeconds: {{ .Values.probe.timeoutSeconds }}
          failureThreshold: {{ .Values.probe.failureThreshold }}
      volumes:
      - name: postgres-data
        persistentVolumeClaim:
          claimName: {{ .Release.Name }}-postgres-pvc
      restartPolicy: Always
EOF

cat > bank-chart/charts/postgres/templates/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.service.name }}
  labels:
    app: postgres
    release: {{ .Release.Name }}
spec:
  type: ClusterIP
  ports:
  - port: {{ .Values.service.port }}
    targetPort: {{ .Values.service.targetPort }}
    protocol: TCP
    name: postgres
  selector:
    app: postgres
    release: {{ .Release.Name }}
EOF

cat > bank-chart/charts/postgres/templates/pvc.yaml << 'EOF'
{{- if .Values.persistence.enabled }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .Release.Name }}-postgres-pvc
  labels:
    app: postgres
    release: {{ .Release.Name }}
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: {{ .Values.persistence.size }}
{{- end }}
EOF

echo "✅ Helm chart успешно создан в директории bank-chart/"
echo ""
echo "📌 Имена сервисов соответствуют docker-compose:"
echo "   - bank-global-config-service"
echo "   - bank-cash-service"
echo "   - bank-account-service"
echo "   - bank-transfer-service"
echo "   - bank-notification-service"
echo "   - bank-front-ui-service"
echo "   - keycloak-service"
echo "   - postgres-service"
echo ""
echo "📦 Для установки выполните:"
echo "  cd bank-chart"
echo "  helm dependency update"
echo "  helm install bank-app ."
echo ""
echo "🌐 После установки сервисы будут доступны:"
echo "  - Keycloak: http://localhost:30080"
echo "  - Front-UI: http://localhost:30005"
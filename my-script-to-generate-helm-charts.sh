#!/bin/bash

# Создаем структуру директорий
mkdir -p bank-chart/charts/{keycloak,kafka,postgres,global-config,cash,account,transfer,notification,front-ui,zipkin,logstash,elasticsearch,kibana}/templates

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
  - name: kafka
    version: 0.1.0
    condition: kafka.enabled
  - name: zipkin
    version: 0.1.0
    condition: zipkin.enabled
  - name: logstash
    version: 0.1.0
    condition: logstash.enabled
  - name: elasticsearch
    version: 0.1.0
    condition: elasticsearch.enabled
  - name: kibana
    version: 0.1.0
    condition: kibana.enabled
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
    kafka: "bank-kafka-service:9092"
    zipkin: "http://bank-zipkin-service:9411"
    logstash: "bank-logstash-service:5000"
    elasticsearch: "http://bank-elasticsearch-service:9200"
    kibana: "http://bank-kibana-service:5601"
  exposure:
    keycloak:
      type: NodePort
      nodePort: 30080
    frontUi:
      type: NodePort
      nodePort: 30005
    zipkin:
      type: NodePort
      nodePort: 30411
    kibana:
      type: NodePort
      nodePort: 30601

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

kafka:
  enabled: true
  replicaCount: 1
  image:
    repository: bank-kafka
    tag: latest
    pullPolicy: IfNotPresent
  service:
    port: 9092
    targetPort: 9092
    name: bank-kafka-service
  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  persistence:
    enabled: true
    size: 512Mi
  probe:
    initialDelaySeconds: 60
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 10

zipkin:
  enabled: true
  replicaCount: 1
  image:
    repository: bank-zipkin
    tag: latest
    pullPolicy: IfNotPresent
  service:
    port: 9411
    targetPort: 9411
    name: bank-zipkin-service
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
    timeoutSeconds: 5
    failureThreshold: 10

logstash:
  enabled: true
  replicaCount: 1
  image:
    repository: bank-logstash
    tag: latest
    pullPolicy: IfNotPresent
  service:
    port: 5000
    targetPort: 5000
    metricsPort: 9600
    metricsTargetPort: 9600
    name: bank-logstash-service
  resources:
    requests:
      memory: "256Mi"
      cpu: "100m"
    limits:
      memory: "768Mi"
      cpu: "500m"
  probe:
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 10

elasticsearch:
  enabled: true
  replicaCount: 1
  image:
    repository: bank-elasticsearch
    tag: latest
    pullPolicy: IfNotPresent
  service:
    port: 9200
    targetPort: 9200
    transportPort: 9300
    transportTargetPort: 9300
    name: bank-elasticsearch-service
  resources:
    requests:
      memory: "768Mi"
      cpu: "250m"
    limits:
      memory: "1536Mi"
      cpu: "1000m"
  persistence:
    enabled: true
    size: 2Gi
  probe:
    initialDelaySeconds: 60
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 20

kibana:
  enabled: true
  replicaCount: 1
  image:
    repository: bank-kibana
    tag: latest
    pullPolicy: IfNotPresent
  service:
    port: 5601
    targetPort: 5601
    name: bank-kibana-service
  resources:
    requests:
      memory: "256Mi"
      cpu: "100m"
    limits:
      memory: "768Mi"
      cpu: "500m"
  probe:
    initialDelaySeconds: 60
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 20

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
          value: {{ $.Values.global.serviceUrls.postgres }}
        - name: ZIPKIN_SERVER_URL
          value: {{ $.Values.global.serviceUrls.zipkin }}"

create_java_subchart "account" "10002" "40" "        - name: DB_URL_PART
          value: {{ $.Values.global.serviceUrls.postgres }}
        - name: CASH_SERVER_URL
          value: {{ $.Values.global.serviceUrls.cash }}
        - name: NOTIFICATION_SERVER_URL
          value: {{ $.Values.global.serviceUrls.notification }}
        - name: KAFKA_SERVER_URL
          value: {{ $.Values.global.serviceUrls.kafka }}
        - name: ZIPKIN_SERVER_URL
          value: {{ $.Values.global.serviceUrls.zipkin }}
        - name: LOGSTASH_SERVER_URL
          value: {{ $.Values.global.serviceUrls.logstash }}"

create_java_subchart "transfer" "10003" "40" "        - name: CASH_SERVER_URL
          value: {{ $.Values.global.serviceUrls.cash }}
        - name: NOTIFICATION_SERVER_URL
          value: {{ $.Values.global.serviceUrls.notification }}
        - name: KAFKA_SERVER_URL
          value: {{ $.Values.global.serviceUrls.kafka }}
        - name: ZIPKIN_SERVER_URL
          value: {{ $.Values.global.serviceUrls.zipkin }}"

create_java_subchart "notification" "10004" "30" "        - name: KAFKA_SERVER_URL
          value: {{ $.Values.global.serviceUrls.kafka }}"

create_java_subchart "front-ui" "30005" "40" "        - name: ACCOUNT_SERVER_URL
          value: {{ $.Values.global.serviceUrls.account }}
        - name: TRANSFER_SERVER_URL
          value: {{ $.Values.global.serviceUrls.transfer }}
        - name: ZIPKIN_SERVER_URL
          value: {{ $.Values.global.serviceUrls.zipkin }}"

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

# Создаем директорию для Kafka
mkdir -p bank-chart/charts/kafka/templates

# Chart.yaml для Kafka
cat > bank-chart/charts/kafka/Chart.yaml << 'EOF'
apiVersion: v2
name: kafka
description: Kafka message broker
type: application
version: 0.1.0
appVersion: 1.0.0
EOF

# values.yaml для Kafka
cat > bank-chart/charts/kafka/values.yaml << 'EOF'
replicaCount: 1
image:
  repository: bank-kafka
  tag: latest
  pullPolicy: IfNotPresent
service:
  port: 9092
  targetPort: 9092
  name: bank-kafka-service
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
persistence:
  enabled: true
  size: 1Gi
probe:
  initialDelaySeconds: 60
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 10
EOF

# deployment.yaml для Kafka
cat > bank-chart/charts/kafka/templates/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-kafka
  labels:
    app: kafka
    release: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: kafka
      release: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: kafka
        release: {{ .Release.Name }}
    spec:
      containers:
      - name: kafka
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: {{ .Values.service.targetPort }}
        - containerPort: 9093
          name: controller
        env:
        - name: KAFKA_PROCESS_ROLES
          value: "broker,controller"
        - name: KAFKA_NODE_ID
          value: "1"
        - name: KAFKA_CONTROLLER_QUORUM_VOTERS
          value: "1@localhost:9093"
        - name: KAFKA_CONTROLLER_LISTENER_NAMES
          value: "CONTROLLER"
        - name: KAFKA_LISTENERS
          value: "PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093"
        - name: KAFKA_ADVERTISED_LISTENERS
          value: "PLAINTEXT://{{ .Values.service.name }}:9092"
        - name: KAFKA_LISTENER_SECURITY_PROTOCOL_MAP
          value: "PLAINTEXT:PLAINTEXT,CONTROLLER:PLAINTEXT"
        - name: KAFKA_AUTO_CREATE_TOPICS_ENABLE
          value: "true"
        - name: KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR
          value: "1"
        - name: KAFKA_OFFSETS_TOPIC_NUM_PARTITIONS
          value: "1"
        - name: KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR
          value: "1"
        - name: KAFKA_TRANSACTION_STATE_LOG_MIN_ISR
          value: "1"
        - name: KAFKA_LOG_DIRS
          value: "/var/lib/kafka/data"
        - name: KAFKA_CLUSTER_ID
          value: "5L6g3nShT-eMCtK--X86sw"
        - name: KAFKA_BROKER_ID
          value: "1"
        - name: KAFKA_HEAP_OPTS
          value: "-Xmx256M -Xms128M"
        resources:
          requests:
            memory: {{ .Values.resources.requests.memory | quote }}
            cpu: {{ .Values.resources.requests.cpu | quote }}
          limits:
            memory: {{ .Values.resources.limits.memory | quote }}
            cpu: {{ .Values.resources.limits.cpu | quote }}
        volumeMounts:
        - name: kafka-data
          mountPath: /var/lib/kafka/data
        # ПРОСТЫЕ TCP PROBES - не зависят от наличия утилит
        livenessProbe:
          tcpSocket:
            port: {{ .Values.service.targetPort }}
          initialDelaySeconds: 60
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 6
        readinessProbe:
          tcpSocket:
            port: {{ .Values.service.targetPort }}
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 6
      volumes:
      - name: kafka-data
        persistentVolumeClaim:
          claimName: {{ .Release.Name }}-kafka-pvc
      restartPolicy: Always
EOF

# service.yaml для Kafka
cat > bank-chart/charts/kafka/templates/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.service.name }}
  labels:
    app: kafka
    release: {{ .Release.Name }}
spec:
  type: ClusterIP
  ports:
  - port: {{ .Values.service.port }}
    targetPort: {{ .Values.service.targetPort }}
    protocol: TCP
    name: kafka
  selector:
    app: kafka
    release: {{ .Release.Name }}
EOF

# pvc.yaml для Kafka
cat > bank-chart/charts/kafka/templates/pvc.yaml << 'EOF'
{{- if .Values.persistence.enabled }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .Release.Name }}-kafka-pvc
  labels:
    app: kafka
    release: {{ .Release.Name }}
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: {{ .Values.persistence.size }}
{{- end }}
EOF

# zipkin
cat > bank-chart/charts/zipkin/Chart.yaml << 'EOF'
apiVersion: v2
name: zipkin
description: Zipkin tracing server
type: application
version: 0.1.0
appVersion: 1.0.0
EOF

cat > bank-chart/charts/zipkin/values.yaml << 'EOF'
replicaCount: 1
image:
  repository: bank-zipkin
  tag: latest
  pullPolicy: IfNotPresent
service:
  port: 9411
  targetPort: 9411
  name: bank-zipkin-service
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
  timeoutSeconds: 5
  failureThreshold: 10
EOF

cat > bank-chart/charts/zipkin/templates/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-zipkin
  labels:
    app: zipkin
    release: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: zipkin
      release: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: zipkin
        release: {{ .Release.Name }}
    spec:
      containers:
      - name: zipkin
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: {{ .Values.service.targetPort }}
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

cat > bank-chart/charts/zipkin/templates/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.service.name }}
  labels:
    app: zipkin
    release: {{ .Release.Name }}
spec:
  type: {{ .Values.global.exposure.zipkin.type }}
  ports:
  - port: {{ .Values.service.port }}
    targetPort: {{ .Values.service.targetPort }}
    protocol: TCP
    name: http
    {{- if eq .Values.global.exposure.zipkin.type "NodePort" }}
    nodePort: {{ .Values.global.exposure.zipkin.nodePort }}
    {{- end }}
  selector:
    app: zipkin
    release: {{ .Release.Name }}
EOF

# logstash
cat > bank-chart/charts/logstash/Chart.yaml << 'EOF'
apiVersion: v2
name: logstash
description: Logstash log pipeline
type: application
version: 0.1.0
appVersion: 1.0.0
EOF

cat > bank-chart/charts/logstash/values.yaml << 'EOF'
replicaCount: 1
image:
  repository: bank-logstash
  tag: latest
  pullPolicy: IfNotPresent
service:
  port: 5000
  targetPort: 5000
  metricsPort: 9600
  metricsTargetPort: 9600
  name: bank-logstash-service
resources:
  requests:
    memory: "256Mi"
    cpu: "100m"
  limits:
    memory: "768Mi"
    cpu: "500m"
probe:
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 10
EOF

cat > bank-chart/charts/logstash/templates/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-logstash
  labels:
    app: logstash
    release: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: logstash
      release: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: logstash
        release: {{ .Release.Name }}
    spec:
      containers:
      - name: logstash
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: {{ .Values.service.targetPort }}
        - containerPort: {{ .Values.service.metricsTargetPort }}
        env:
        - name: LS_JAVA_OPTS
          value: "-Xmx256m -Xms256m"
        - name: ELASTICSEARCH_URL
          value: {{ $.Values.global.serviceUrls.elasticsearch }}
        resources:
{{ toYaml .Values.resources | indent 10 }}
        livenessProbe:
          tcpSocket:
            port: {{ .Values.service.metricsTargetPort }}
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

cat > bank-chart/charts/logstash/templates/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.service.name }}
  labels:
    app: logstash
    release: {{ .Release.Name }}
spec:
  type: ClusterIP
  ports:
  - port: {{ .Values.service.port }}
    targetPort: {{ .Values.service.targetPort }}
    protocol: TCP
    name: logs
  - port: {{ .Values.service.metricsPort }}
    targetPort: {{ .Values.service.metricsTargetPort }}
    protocol: TCP
    name: metrics
  selector:
    app: logstash
    release: {{ .Release.Name }}
EOF

# elasticsearch
cat > bank-chart/charts/elasticsearch/Chart.yaml << 'EOF'
apiVersion: v2
name: elasticsearch
description: Elasticsearch search engine
type: application
version: 0.1.0
appVersion: 1.0.0
EOF

cat > bank-chart/charts/elasticsearch/values.yaml << 'EOF'
replicaCount: 1
image:
  repository: bank-elasticsearch
  tag: latest
  pullPolicy: IfNotPresent
service:
  port: 9200
  targetPort: 9200
  transportPort: 9300
  transportTargetPort: 9300
  name: bank-elasticsearch-service
resources:
  requests:
    memory: "768Mi"
    cpu: "250m"
  limits:
    memory: "1536Mi"
    cpu: "1000m"
persistence:
  enabled: true
  size: 2Gi
probe:
  initialDelaySeconds: 60
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 20
EOF

cat > bank-chart/charts/elasticsearch/templates/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-elasticsearch
  labels:
    app: elasticsearch
    release: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: elasticsearch
      release: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: elasticsearch
        release: {{ .Release.Name }}
    spec:
      containers:
      - name: elasticsearch
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: {{ .Values.service.targetPort }}
        - containerPort: {{ .Values.service.transportTargetPort }}
        env:
        - name: ES_JAVA_OPTS
          value: "-Xms512m -Xmx512m"
        - name: bootstrap.memory_lock
          value: "true"
        resources:
{{ toYaml .Values.resources | indent 10 }}
        volumeMounts:
        - name: elasticsearch-data
          mountPath: /usr/share/elasticsearch/data
        livenessProbe:
          httpGet:
            path: /_cluster/health
            port: {{ .Values.service.targetPort }}
          initialDelaySeconds: {{ .Values.probe.initialDelaySeconds }}
          periodSeconds: {{ .Values.probe.periodSeconds }}
          timeoutSeconds: {{ .Values.probe.timeoutSeconds }}
          failureThreshold: {{ .Values.probe.failureThreshold }}
        readinessProbe:
          httpGet:
            path: /_cluster/health
            port: {{ .Values.service.targetPort }}
          initialDelaySeconds: {{ .Values.probe.initialDelaySeconds }}
          periodSeconds: {{ .Values.probe.periodSeconds }}
          timeoutSeconds: {{ .Values.probe.timeoutSeconds }}
          failureThreshold: {{ .Values.probe.failureThreshold }}
      volumes:
      - name: elasticsearch-data
        persistentVolumeClaim:
          claimName: {{ .Release.Name }}-elasticsearch-pvc
      restartPolicy: Always
EOF

cat > bank-chart/charts/elasticsearch/templates/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.service.name }}
  labels:
    app: elasticsearch
    release: {{ .Release.Name }}
spec:
  type: ClusterIP
  ports:
  - port: {{ .Values.service.port }}
    targetPort: {{ .Values.service.targetPort }}
    protocol: TCP
    name: http
  - port: {{ .Values.service.transportPort }}
    targetPort: {{ .Values.service.transportTargetPort }}
    protocol: TCP
    name: transport
  selector:
    app: elasticsearch
    release: {{ .Release.Name }}
EOF

cat > bank-chart/charts/elasticsearch/templates/pvc.yaml << 'EOF'
{{- if .Values.persistence.enabled }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .Release.Name }}-elasticsearch-pvc
  labels:
    app: elasticsearch
    release: {{ .Release.Name }}
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: {{ .Values.persistence.size }}
{{- end }}
EOF

# kibana
cat > bank-chart/charts/kibana/Chart.yaml << 'EOF'
apiVersion: v2
name: kibana
description: Kibana log viewer
type: application
version: 0.1.0
appVersion: 1.0.0
EOF

cat > bank-chart/charts/kibana/values.yaml << 'EOF'
replicaCount: 1
image:
  repository: bank-kibana
  tag: latest
  pullPolicy: IfNotPresent
service:
  port: 5601
  targetPort: 5601
  name: bank-kibana-service
resources:
  requests:
    memory: "256Mi"
    cpu: "100m"
  limits:
    memory: "768Mi"
    cpu: "500m"
probe:
  initialDelaySeconds: 60
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 20
EOF

cat > bank-chart/charts/kibana/templates/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-kibana
  labels:
    app: kibana
    release: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: kibana
      release: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: kibana
        release: {{ .Release.Name }}
    spec:
      containers:
      - name: kibana
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: {{ .Values.service.targetPort }}
        resources:
{{ toYaml .Values.resources | indent 10 }}
        livenessProbe:
          httpGet:
            path: /api/status
            port: {{ .Values.service.targetPort }}
          initialDelaySeconds: {{ .Values.probe.initialDelaySeconds }}
          periodSeconds: {{ .Values.probe.periodSeconds }}
          timeoutSeconds: {{ .Values.probe.timeoutSeconds }}
          failureThreshold: {{ .Values.probe.failureThreshold }}
        readinessProbe:
          httpGet:
            path: /api/status
            port: {{ .Values.service.targetPort }}
          initialDelaySeconds: {{ .Values.probe.initialDelaySeconds }}
          periodSeconds: {{ .Values.probe.periodSeconds }}
          timeoutSeconds: {{ .Values.probe.timeoutSeconds }}
          failureThreshold: {{ .Values.probe.failureThreshold }}
      restartPolicy: Always
EOF

cat > bank-chart/charts/kibana/templates/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.service.name }}
  labels:
    app: kibana
    release: {{ .Release.Name }}
spec:
  type: {{ .Values.global.exposure.kibana.type }}
  ports:
  - port: {{ .Values.service.port }}
    targetPort: {{ .Values.service.targetPort }}
    protocol: TCP
    name: http
    {{- if eq .Values.global.exposure.kibana.type "NodePort" }}
    nodePort: {{ .Values.global.exposure.kibana.nodePort }}
    {{- end }}
  selector:
    app: kibana
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
echo "   - bank-kafka-service"
echo "   - bank-zipkin-service"
echo "   - bank-logstash-service"
echo "   - bank-elasticsearch-service"
echo "   - bank-kibana-service"
echo ""
echo "📦 Для установки выполните:"
echo "  cd bank-chart"
echo "  helm dependency update"
echo "  helm install bank-app ."
echo ""
echo "🌐 После установки сервисы будут доступны:"
echo "  - Keycloak: http://localhost:30080"
echo "  - Front-UI: http://localhost:30005"
echo "  - Zipkin: http://localhost:30411"
echo "  - Kibana: http://localhost:30601"
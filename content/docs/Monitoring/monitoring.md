# Monitoring

## Monitorización y observabilidad

En sistemas de Big Data y arquitecturas distribuidas, entender qué
ocurre dentro de los sistemas es fundamental. Aquí es donde entran dos
conceptos clave: monitorización y observabilidad.

La monitorización consiste en recoger métricas conocidas como uso de
CPU, memoria, latencia o número de peticiones. Es útil para saber si
todo funciona dentro de unos valores esperados.

La observabilidad va más allá. Permite entender el comportamiento
interno del sistema incluso cuando no sabemos qué problema buscar. Se
basa en tres pilares: - Métricas - Logs - Trazas

Mientras que la monitorización responde a "qué está pasando", la
observabilidad responde a "por qué está pasando".

------------------------------------------------------------------------

## Prometheus

Prometheus es una herramienta de monitorización basada en métricas y
orientada a sistemas distribuidos.

Funciona con un modelo pull: en lugar de que los sistemas envíen datos,
Prometheus los consulta periódicamente.

### Componentes clave

-   Servidor Prometheus
-   Base de datos de series temporales
-   Lenguaje de consulta (PromQL)

### prometheus.yml

Este archivo define: - Cada cuánto se recogen métricas - Qué servicios
se monitorizan - Dónde están las reglas - Cómo se conectan las alertas

### Plantilla comentada

``` yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']

rule_files:
  - "rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - 'localhost:9093'
```

------------------------------------------------------------------------

## Node Exporter

Node Exporter es un agente que recoge métricas del sistema operativo.

### Qué mide

-   CPU
-   RAM
-   Disco
-   Red

### Cómo funciona

1.  Se instala en la máquina
2.  Expone métricas en /metrics
3.  Prometheus las consulta

Es la pieza que conecta el sistema físico con Prometheus.

------------------------------------------------------------------------

## Grafana

Grafana es la herramienta que permite visualizar los datos recogidos.

### Qué permite

-   Crear dashboards
-   Visualizar métricas en tiempo real
-   Crear alertas visuales

### grafana.ini

Archivo de configuración principal.

``` ini
[server]
http_port = 3000

[security]
admin_user = admin
admin_password = admin

[auth.anonymous]
enabled = true
org_role = Viewer

[database]
type = sqlite3
path = grafana.db
```

### Configuración básica

1.  Arrancar Grafana
2.  Acceder a localhost:3000
3.  Añadir Prometheus como Data Source
4.  Crear dashboard

------------------------------------------------------------------------

## Alertmanager

Gestiona las alertas generadas por Prometheus.

### Funciones

-   Agrupar alertas
-   Evitar duplicados
-   Enviar notificaciones

### alertmanager.yml

``` yaml
global:
  resolve_timeout: 5m

route:
  receiver: 'default'

receivers:
  - name: 'default'
    email_configs:
      - to: 'admin@example.com'
        from: 'alertmanager@example.com'
        smarthost: 'smtp.example.com:587'
        auth_username: 'user'
        auth_password: 'password'
```

------------------------------------------------------------------------

## Rules (reglas)

Las reglas permiten definir cuándo se genera una alerta.

### Dónde se configuran

En prometheus.yml → rule_files

### Ejemplo

``` yaml
groups:
  - name: cpu_rules
    rules:
      - alert: HighCPU
        expr: 100 - (avg by(instance)(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "CPU alta"
          description: "Uso de CPU mayor al 80%"
```

------------------------------------------------------------------------

## Flujo completo

1.  Node Exporter genera métricas
2.  Prometheus las recoge
3.  Prometheus evalúa reglas
4.  Se genera alerta
5.  Alertmanager la gestiona
6.  Grafana muestra los datos

------------------------------------------------------------------------

## Conclusión conceptual

Este stack forma una arquitectura estándar de observabilidad en Big Data
y cloud: - Prometheus = recoge datos - Node Exporter = fuente de
métricas - Grafana = visualización - Alertmanager = gestión de alertas

# Proyecto 10: Observabilidad de un clúster Spark con Docker, Prometheus, Grafana y Ganglia

En este proyecto desplegarás un clúster Spark con 1 nodo master y 3 nodos worker usando Docker Compose.  
Añadirás monitorización con Prometheus, Grafana y Alertmanager, y luego un contenedor extra con Ganglia para comparar interfaces.  
Finalmente, ejecutarás pequeños jobs de Spark SQL y verás cómo cambian las métricas en las gráficas.

---

## 1. Objetivos del proyecto

En este apartado definimos qué se quiere conseguir en el proyecto.

- Desplegar un clúster Spark con 1 master y 3 workers usando Docker Compose.
- Añadir un Prometheus + Grafana + Alertmanager para monitorizar el clúster.
- Visualizar métricas de CPU, memoria y uso de recursos de Spark.
- Configurar una alerta simple con Alertmanager (por ejemplo, uso de CPU > 80%).
- Añadir un contenedor con Ganglia para visualizar el clúster.
- Ejecutar un pequeño job de Spark SQL y ver cómo cambian las gráficas en Grafana.

---

## 2. Estructura del proyecto en Docker

Organizaremos el proyecto en carpetas y archivos Docker Compose.

**Estructura sugerida:**

```bash
proyecto_observabilidad/
├── docker-compose.yml          # Clúster Spark + Prometheus + Grafana + Alertmanager
├── spark/                      # Configuración específica de Spark
│   └── docker-compose.spark.yml
├── monitoring/
│   ├── prometheus.yml          # Configuración de Prometheus
│   ├── grafana.ini             # Configuración de Grafana
│   └── docker-compose.monitoring.yml
├── ganglia/                    # Opcional: contenedor Ganglia
│   └── docker-compose.ganglia.yml
└── scripts/
    └── start.sh                # Script para levantar todo
```

**Solución breve:**

1. Crea la estructura de carpetas con:
   ```bash
   mkdir -p proyecto_observabilidad/{spark,monitoring,ganglia,scripts}
   ```
2. Este apartado solo define la estructura; luego en los siguientes apartados redactarás los `docker-compose.yml` correspondientes.

---

## 3. Desplegar clúster Spark (1 master, 3 workers) con Docker

Vamos a crear un archivo `docker-compose.spark.yml` que levante 1 nodo master Spark y 3 nodos worker Spark.

**Ejemplo de `docker-compose.spark.yml` (solo Spark):**

```yaml
version: "3.8"

services:
  spark-master:
    image: bde2020/spark-master:3.5.0-hadoop3.3
    container_name: spark-master
    ports:
      - "8080:8080"   # Web UI Master
      - "7077:7077"   # Spark master port
    environment:
      - INIT_DAEMON_STEP=setup_spark
    networks:
      - spark-net

  spark-worker-1:
    image: bde2020/spark-worker:3.5.0-hadoop3.3
    container_name: spark-worker-1
    depends_on:
      - spark-master
    environment:
      - SPARK_MASTER=spark://spark-master:7077
    networks:
      - spark-net

  spark-worker-2:
    image: bde2020/spark-worker:3.5.0-hadoop3.3
    container_name: spark-worker-2
    depends_on:
      - spark-master
    environment:
      - SPARK_MASTER=spark://spark-master:7077
    networks:
      - spark-net

  spark-worker-3:
    image: bde2020/spark-worker:3.5.0-hadoop3.3
    container_name: spark-worker-3
    depends_on:
      - spark-master
    environment:
      - SPARK_MASTER=spark://spark-master:7077
    networks:
      - spark-net

networks:
  spark-net:
    driver: bridge
```

**Solución:**

1. Guarda este contenido en `spark/docker-compose.spark.yml`.
2. Lanza el clúster con:
   ```bash
   cd spark
   docker-compose up -d
   ```
3. Verifica el clúster en `http://localhost:8080` (UI de Spark Master).

---

## 4. Añadir Prometheus para recolectar métricas del clúster

Ahora configuraremos Prometheus para recolectar métricas de los nodos (incluyendo los contenedores Spark).

**1. Crear `monitoring/prometheus.yml`:**

```yaml
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: "node"
    static_configs:
      - targets: ["node-exporter:9100"]
        labels:
          group: "nodes"

  - job_name: "spark"
    static_configs:
      - targets: ["spark-master:8080"]
        labels:
          group: "spark"
      - targets: ["spark-worker-1:8080"]
      - targets: ["spark-worker-2:8080"]
      - targets: ["spark-worker-3:8080"]
```

**2. Crear `monitoring/docker-compose.monitoring.yml`:**

```yaml
version: "3.8"

services:
  node-exporter:
    image: prom/node-exporter:v1.7.0
    container_name: node-exporter
    ports:
      - "9100:9100"
    restart: unless-stopped
    networks:
      - monitoring-net

  prometheus:
    image: prom/prometheus:v2.48.0
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    depends_on:
      - node-exporter
    networks:
      - monitoring-net

  grafana:
    image: grafana/grafana:10.3.0
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - ./grafana.ini:/etc/grafana/grafana.ini
    depends_on:
      - prometheus
    networks:
      - monitoring-net

  alertmanager:
    image: prom/alertmanager:v0.26.0
    container_name: alertmanager
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml
    depends_on:
      - prometheus
    networks:
      - monitoring-net

networks:
  monitoring-net:
    driver: bridge
```

**Solución:**

1. Guarda `prometheus.yml` en `monitoring/`.
2. Ejecuta `docker-compose up -d` dentro de `monitoring/`.
3. Prometheus escaneará `node-exporter` y los puertos de Spark.

---

## 5. Configurar Grafana y conectar con Prometheus

Ahora configuraremos Grafana para mostrar las métricas de Prometheus.

**1. Accede a Grafana:**

Abre `http://localhost:3000` y entra con usuario `admin` / contraseña `admin` (o según tu `grafana.ini`).

**2. Añadir origen de datos Prometheus:**

- En Grafana: **Configuration → Data sources → Add data source → Prometheus**.
- URL: `http://prometheus:9090` (si estás dentro de Docker) o `http://host.docker.internal:9090` si estás en host.
- Haz clic en **Save & test**.

**Solución:**

1. Crea un dashboard llamado **Spark Cluster Monitoring**.
2. Añade paneles de tipo **Time series** con consultas como:
   - Node CPU: `node_cpu_seconds_total{mode="idle"}`
   - Node memoria: `node_memory_MemAvailable_bytes`
   - Métricas de Spark: `spark_*` (si las exportas)

> En un entorno real, puedes usar un `jmx-exporter` en los nodos Spark para exportar métricas a Prometheus.

---

## 6. Configurar una alerta simple con Alertmanager

Vamos a crear una alerta básica en Prometheus y verla en Alertmanager.

**1. Añadir reglas en Prometheus (`prometheus.yml`):**

```yaml
rule_files:
  - "rules.yml"
# Añade este bloque al final de prometheus.yml (mismo nivel que global)
```

**2. Crear `monitoring/rules.yml`:**

```yaml
groups:
  - name: example
    rules:
      - alert: HighNodeCPU
        expr: (100 - avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[1m]) * 100)) > 80
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage is above 80% on {{ $labels.instance }}"
```

**3. Configurar `monitoring/alertmanager.yml` (simple):**

```yaml
route:
  receiver: default-receiver

receivers:
  - name: default-receiver
    webhook_configs:
      - url: 'http://localhost:1234/'   # O puedes usar un webhook externo
```

**Solución:**

1. Guarda `rules.yml` en `monitoring/` y asegúrate de que `prometheus.yml` lo referencia.
2. Reinicia Prometheus: `docker-compose restart prometheus`.
3. En Alertmanager (`http://localhost:9093`) verás las alertas activas cuando la CPU supere el 80%.

---

## 7. Ejecutar un pequeño job de Spark SQL y ver las gráficas

Ahora ejecutaremos un job de Spark SQL y observaremos cómo cambian las métricas.

**1. Ejecutar un job desde el contenedor master:**

```bash
docker exec -it spark-master bash
```

**2. Ejemplo con `spark-sql`:**

```sql
spark-sql
> CREATE TEMPORARY VIEW foo AS SELECT * FROM json.`/path/to/mock-data.json`;
> SELECT count(*) FROM foo;
```

**3. Alternativa con `spark-submit` (ejemplo en Python):**

```python
# Guarda como /tmp/job.py dentro de spark-master
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("JobSQL") \
    .getOrCreate()

df = spark.range(1000000)
df.write.mode("overwrite").parquet("/tmp/test")

df = spark.read.parquet("/tmp/test")
df.select("id").show()
spark.stop()
```

Luego ejecútalo con:

```bash
spark-submit /tmp/job.py
```

**Solución:**

1. Mientras el job se ejecuta, observa en Grafana cómo cambian las métricas (CPU, memoria, duración de jobs).
2. Registra la duración del job y compárala con métricas de Prometheus.

---

## 8. Añadir contenedor Ganglia para visualizar el clúster

Ahora añadiremos un contenedor Ganglia para visualizar el clúster (aunque será más limitado que Prometheus‑Grafana).

**1. Crear `ganglia/docker-compose.ganglia.yml`:**

```yaml
version: "3.8"

services:
  ganglia-web:
    image: dorowu/ganglia-web
    container_name: ganglia-web
    ports:
      - "8081:80"
    environment:
      - GANGLIA_HOST=ganglia-gmetad
      - GANGLIA_PORT=8649
    networks:
      - ganglia-net

  ganglia-gmetad:
    image: dorowu/ganglia-gmetad
    container_name: ganglia-gmetad
    networks:
      - ganglia-net

  ganglia-gmond:
    image: dorowu/ganglia-gmond
    container_name: ganglia-gmond
    network_mode: host
    environment:
      - GANGLIA_HOST=ganglia-gmetad
    networks:
      - ganglia-net

networks:
  ganglia-net:
    driver: bridge
```

**Solución:**

1. Guarda como `ganglia/docker-compose.ganglia.yml`.
2. Lanza con `docker-compose up -d`.
3. Accede a `http://localhost:8081` para ver la interfaz de Ganglia.
4. Configura para que monitorice los nodos (esto suele requerir más ajustes; en clase, puedes mostrarlo como ejemplo "histórico" comparado con Grafana).

---

## 9. Integrar todo en un único docker-compose.yml principal

Para que todo se levante en un solo comando, puedes integrar los servicios en un único `docker-compose.yml` raíz.

**Ejemplo de `docker-compose.yml` (`proyecto_observabilidad/`):**

```yaml
version: "3.8"

services:
  # --- Spark Cluster ---
  spark-master:
    image: bde2020/spark-master:3.5.0-hadoop3.3
    container_name: spark-master
    ports:
      - "8080:8080"
      - "7077:7077"
    environment:
      - INIT_DAEMON_STEP=setup_spark
    networks:
      - observability-net

  spark-worker-1:
    image: bde2020/spark-worker:3.5.0-hadoop3.3
    container_name: spark-worker-1
    depends_on:
      - spark-master
    environment:
      - SPARK_MASTER=spark://spark-master:7077
    networks:
      - observability-net

  spark-worker-2:
    image: bde2020/spark-worker:3.5.0-hadoop3.3
    container_name: spark-worker-2
    depends_on:
      - spark-master
    environment:
      - SPARK_MASTER=spark://spark-master:7077
    networks:
      - observability-net

  spark-worker-3:
    image: bde2020/spark-worker:3.5.0-hadoop3.3
    container_name: spark-worker-3
    depends_on:
      - spark-master
    environment:
      - SPARK_MASTER=spark://spark-master:7077
    networks:
      - observability-net

  # --- Prometheus + Grafana + Alertmanager ---
  node-exporter:
    image: prom/node-exporter:v1.7.0
    container_name: node-exporter
    ports:
      - "9100:9100"
    networks:
      - observability-net

  prometheus:
    image: prom/prometheus:v2.48.0
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
    depends_on:
      - node-exporter
    networks:
      - observability-net

  grafana:
    image: grafana/grafana:10.3.0
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    depends_on:
      - prometheus
    networks:
      - observability-net

  alertmanager:
    image: prom/alertmanager:v0.26.0
    container_name: alertmanager
    ports:
      - "9093:9093"
    volumes:
      - ./monitoring/alertmanager.yml:/etc/alertmanager/alertmanager.yml
    depends_on:
      - prometheus
    networks:
      - observability-net

  # --- Ganglia (opcional) ---
  ganglia-web:
    image: dorowu/ganglia-web
    container_name: ganglia-web
    ports:
      - "8081:80"
    environment:
      - GANGLIA_HOST=ganglia-gmetad
      - GANGLIA_PORT=8649
    networks:
      - observability-net

  ganglia-gmetad:
    image: dorowu/ganglia-gmetad
    container_name: ganglia-gmetad
    networks:
      - observability-net

  ganglia-gmond:
    image: dorowu/ganglia-gmond
    container_name: ganglia-gmond
    network_mode: host
    environment:
      - GANGLIA_HOST=ganglia-gmetad
    networks:
      - observability-net

networks:
  observability-net:
    driver: bridge
```

**Solución:**

1. Copia este archivo en la raíz `proyecto_observabilidad/docker-compose.yml`.
2. Asegúrate de tener tus ficheros en `monitoring/` (`prometheus.yml`, `rules.yml`, `alertmanager.yml`).
3. Ejecuta desde la raíz:
   ```bash
   docker-compose up -d
   ```

---

## 10. Resumen de observabilidad y evaluación de los criterios RA4

En este último apartado relacionamos el proyecto con los criterios de evaluación de la unidad 04.

**a) Aplicar herramientas de monitorización eficientes:**  
Has usado Prometheus + Grafana + Alertmanager para monitorizar el clúster Spark desplegado en Docker.

**b) Recoger métricas, procesar y visualizar:**  
Has configurado `node-exporter` para exponer métricas del sistema y Prometheus para recolectarlas. Grafana las visualiza en dashboards con paneles de series temporales.

**c) Configurar alertas:**  
Has definido reglas de alerta en `rules.yml` y configurado Alertmanager para notificar cuando la CPU supere el 80%.

**d) Comparar herramientas de observabilidad:**  
Has añadido Ganglia como herramienta alternativa e histórica, comparando su interfaz y capacidades con el stack moderno Prometheus‑Grafana.

**e) Ejecutar y observar workloads reales:**  
Has lanzado jobs de Spark SQL y `spark-submit` para generar carga real y verificar que las métricas cambian correctamente en los dashboards de Grafana.

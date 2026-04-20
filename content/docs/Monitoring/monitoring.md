---
title: "Monitorización"
weight: 6
---

# Monitorización y Observabilidad en Sistemas

## Introducción
En el contexto de sistemas modernos —especialmente en entornos de **Big Data, microservicios y cloud**— ya no es suficiente con que una aplicación “funcione”. Necesitamos saber **cómo funciona, qué está pasando en cada momento y por qué ocurre un problema** cuando aparece.

Aquí es donde entran dos conceptos clave: **monitorización** y **observabilidad**. Aunque muchas veces se utilizan como sinónimos, no significan exactamente lo mismo y entender su diferencia es fundamental para trabajar con sistemas distribuidos.

### **Monitorización**
---
Consiste en **recoger, visualizar y alertar sobre métricas conocidas de un sistema**. 
Es decir, definimos de antemano qué queremos medir:
- Uso de CPU
- Memoria
- Latencia de una API
- Número de peticiones
- Estado de servicios (up/down)

Estas métricas se recogen de forma continua y permiten:
- Detectar problemas rápidamente  
- Generar alertas (por ejemplo, si la CPU supera el 90%)  
- Visualizar el estado general del sistema  

>👉 La monitorización responde principalmente a la pregunta: **“¿Está funcionando el sistema correctamente?”**, detecta que algo va mal.

### **Observabilidad**
---
Va un paso más allá. No solo mide lo que ya conocemos, sino que permite **entender el comportamiento interno del sistema incluso ante situaciones desconocidas**. Se basa en tres pilares fundamentales:
- **Métricas** → valores numéricos (CPU, latencia, etc.)
- **Logs** → registros detallados de eventos
- **Trazas (tracing)** → seguimiento de una petición a través de múltiples servicios

La observabilidad permite:
- Investigar problemas complejos  
- Analizar comportamientos inesperados  
- Entender sistemas distribuidos donde intervienen múltiples componentes  


>👉 La observabilidad responde a la pregunta:  **“¿Por qué está ocurriendo esto?”**, ayuda a encontrar la causa.

## **Node Exporter**
---
Componente diseñado para **exponer métricas del sistema operativo** de un servidor de forma que puedan ser recogidas por herramientas como Prometheus. No almacena datos ni los analiza. Su única función es: > **leer el estado del sistema y publicarlo como métricas accesibles vía HTTP**

Sirve para obtener información detallada del estado de una máquina en tiempo real, como por ejemplo:
- Uso de CPU  
- Consumo de memoria  
- Espacio en disco  
- Actividad de red  
- Estadísticas del sistema operativo  

Node Exporter se ejecuta como un servicio en el sistema y permite tener una visión clara del estado de la infraestructura. Los pasos son:
1. Recoge métricas del sistema operativo  
2. Las transforma a un formato compatible con Prometheus  
3. Las expone en una URL accesible  

## **Prometheus**
---
Suele trabajar junto a componentes como **Node Exporter**, ambos forman una base fundamental en muchos sistemas reales, especialmente en entornos **cloud, contenedores y microservicios**, es un sistema de monitorización y alerta diseñado para **recoger métricas de sistemas y aplicaciones en tiempo real**. Su funcionamiento se basa en un modelo muy importante, **Pull (extracción)** va a buscar las métricas a los sistemas en lugar de esperar a que se las envíen.

**CARACTERÍSTICAS:**
- Base de datos propia de series temporales  
- Lenguaje de consulta: **PromQL**  
- Sistema de alertas integrado  
- Descubrimiento de servicios (especialmente en entornos dinámicos como Kubernetes)  
- Muy eficiente para métricas numéricas  

**FUNCIONAMIENTO**:
1. Tiene una lista de objetivos (``targets``)
2. Periódicamente accede a ellos (``scraping`` técnica para extraer información de sitios web, convirtiendo datos no estructurados (HTML) en datos estructurados)
3. Recoge métricas en formato HTTP
4. Las almacena en su base de datos
5. Permite consultarlas y generar alertas

### ``prometheus.yml``
Archivo de configuración principal y el "corazón" de todo el sistema; sin él, ni siquiera sabe qué debe vigilar. Conecta todas las piezas del rompecabezas, dirección IP del Alertmanager para que sepa a dónde enviar los avisos y también donde le das la ruta del archivo ``rules.yml``para que pueda leer las reglas que creaste. Básicamente, es el centro de mando que define cómo se comporta el software, a quién debe espiar para obtener métricas y cómo debe comunicarse con los demás componentes de tu infraestructura.
``` yaml
# Plantilla
global:
  scrape_interval: 15s    # Cada cuánto tiempo recoge métricas
  evaluation_interval: 15s

scrape_configs:  # Qué servicios se monitorizan
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']   # Node Exporter

rule_files:
  - "rules.yml" # Dónde están las reglas

alerting:   #Cómo se conectan las alertas
  alertmanagers:
    - static_configs:
        - targets:
          - 'localhost:9093'
```
### ``rules.yml``
Archivo donde escribes las "instrucciones" para que Prometheus sepa cuándo enviarte un aviso. Imagina que es un manual de condiciones: tú le dices que si el uso de memoria supera el 90% durante más de cinco minutos, debe marcar esa situación como una alerta. Sin este archivo, Prometheus simplemente guardaría datos y gráficas, pero nunca te avisaría de forma automática si algo se rompe o funciona mal.
``` yaml
# rules.yml
groups:
  - name: infraestructura                    # nombre del grupo de reglas
    interval: 1m                             # cada cuánto evalúa este grupo (por defecto hereda de Prometheus)
    rules:
 
      - alert: NodoSinDatos                  # nombre de la alerta (aparece en Alertmanager)
        expr: up == 0                        # expresión PromQL — se dispara cuando es verdadera
        for: 2m                              # debe cumplirse durante 2m antes de disparar
        labels:
          severity: critical                 # etiquetas usadas por Alertmanager para enrutar
        annotations:
          summary: "Nodo {{ $labels.instance }} sin datos"         # mensaje corto
          description: "El exporter de {{ $labels.job }} no responde desde hace 2 minutos."
 
      - alert: CPUAlta
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "CPU alta en {{ $labels.instance }}"
          description: "Uso de CPU por encima del 85% durante 5 minutos."
```

## **Grafana**
---
Grafana es una plataforma interactiva y **open source** de visualización de datos. Dicha plataforma permite a los usuarios ver sus datos a través de tablas y gráficos que se unifican en un panel de control (o en varios) para facilitar la interpretación y la comprensión. También permite realizar consultas y configurar avisos sobre la información y los indicadores desde el lugar en el que se almacena dicha información, ya sea en entornos de servidores tradicionales, clústeres de Kubernetes y varios servicios de nube, entre otros. De esta forma, podrá analizar los datos e identificar las tendencias y las inconsistencias con mayor facilidad, por lo que sus procesos serán más eficientes. 

**CARACTERÍSTICAS**

- **Paneles**: visualice sus datos de la forma que desee mediante histogramas, gráficos, mapas geográficos, mapas de calor, etc.
- **Plugins**: procéselos de forma inmediata en una API fácil de usar a través de plugins en los paneles que se conectan a las fuentes de datos sin necesidad de trasladarlos. También puede crear plugins de fuentes de datos para obtener indicadores de cualquier API personalizada.
- **Alertas**: puede crear, consolidar y controlar todas sus alertas en una única interfaz.
- **Transformaciones**: realice cambios de nombre, resúmenes, combinaciones y cálculos en todas las fuentes de datos y consultas.
- **Anotaciones**: utilice eventos completos de diferentes fuentes de datos para hacer anotaciones en los gráficos.
- **Editor de paneles**: le brinda una interfaz de usuario uniforme para configurar y personalizar sus paneles.


**CONFIGURACIÓN**
1.  Arrancar Grafana
2.  Acceder a localhost:3000
3.  Añadir Prometheus como Data Source
4.  Crear dashboard

### ``grafana.ini``
Archivo de configuración principal de Grafana, controla absolutamente todo: el servidor HTTP, la base de datos interna, la autenticación, el correo, la seguridad, los plugins y mucho más.
``` ini
# grafana.ini — Configuración básica de Grafana
[paths]  # [paths] — Rutas del sistema de archivos

[server]    # [server] — Configuración del servidor HTTP
http_port = 3000

[database]    # [database] — Base de datos interna de Grafana
type = sqlite3
path = grafana.db

[security]    # [security] — Seguridad general
admin_user = admin
admin_password = admin

[users]   # [users] — Gestión de usuarios

[auth]    # [auth] — Autenticación general

[auth.anonymous]  # [auth.anonymous] — Acceso anónimo (sin login)
enabled = true
org_role = Viewer
```

## **Alertmanager**
---
Prometheus es capaz de generar alertas en base a la evaluación de una expresión **PromQL**, que en caso de cumplirse durante un valor determinado (mientras no ha pasado suficiente tiempo, se mantendrán en estado Pending), las enviará a un AlertManager, para que se procesen y se notifique al personal adecuado.

El **AlertManager** es el servidor de alertas del stack de Prometheus, que utiliza su propio fichero de configuración y se ejecuta como un proceso independiente del propio Prometheus Server, que se encarga de la gestión de las notificaciones de las alertas, que podemos instalar en el mismo o en diferente servidor. De hecho, podemos tener varios Prometheus Server enviando alertas a un mismo AlertManager, para que las gestione y notifique.

**FUNCIONAMIENTO**
1. Prometheus recolecta la información (métricas) de los diferentes recursos monitorizados, así como define la alertas (alert rules) como una expresión PromQL que se mantiene durante un determinado periodo de tiempo, y se las envía al AlertManager. 
2. AlertManager gestiona las notificaciones de las alertas.

Cuando la expresión PromQL de una alerta no se cumple, está en estado Inactive. Cuando comienza a cumplirse su expresión PromQL, pasa a estado Pending, en el que se mantendrá durante el periodo de tiempo que definamos para la alerta, pasado el cual, pasará a estado Firing.

### ``alertmanager.yml``
``` yaml
global:
  resolve_timeout: 5m
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: 'alertas@miempresa.com'
  smtp_auth_password: 'TU_PASSWORD'
route:
  receiver: 'email-ops'
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h          # cada cuánto se repite si sigue sin resolverse
  routes:
    - matchers: [alertname = "Watchdog"]
      receiver: 'null'         # alerta de test de Prometheus, se descarta
receivers:
  - name: 'null'
  - name: 'email-ops'
    email_configs:
      - to: 'ops@miempresa.com'
        send_resolved: true    # notifica también cuando se resuelve
```
Los principales conceptos de AlertManager son los siguientes:
- **Rutas (routes) y Receptores (receivers)**. Son el corazón de la configuración de AlertManager. Determinan los caminos que pueden seguir las alertas y las acciones asociadas, pudiendo crear una jerarquía de rutas y sub-rutas. Cada ruta está asociada a receptores (receivers), que son los destinatarios de las notificaciones (ej: un canal de Slack, una dirección de correo electrónico, etc). Se configura en el fichero de configuración de AlertManager.
- **Agrupamiento (grouping)**. Permite agrupar alertar similares en una única notificación, útil en una gran indisponibilidad afectando múltiples dispositivos, evitando spam.
- **Inhibición (Inhibition).** Permite definir dependencias entre servicios, de tal modo que sea posible eliminar notificaciones de alertas dependientes, si la alerta de la cual depende se ha producido. Por ejemplo, si una base de datos está indisponible, no sería necesario notificar también por las alertas de las aplicaciones dependientes de la misma. Se configura en el fichero de configuración de AlertManager.
- **Silenciamiento (Silences).** Permite deshabilitar notificaciones temporalmente para un determinado conjunto de alerts, mediante su configuración desde la interfaz Web de AlertManager. Resulta de gran utilidad. Por ejemplo, si estamos realizando una intervención planificada en Producción, podemos sinlenciar las alertas relacionadas con dicha intervención durante la duración de la misma (ventana de mantenimiento).


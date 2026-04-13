---
title: "Docker: Guía"
weight: 2
---
# 🐳 Docker: Guía Completa de Contenedores

## ¿Qué es un contenedor?
---
No todos los programas son compatibles con todos los sistemas operativos. Cada vez que un programa es compilado, se hace para un sistema determinado (Windows, Linux, Mac, etc.), lo que genera el clásico problema de **incompatibilidad de entornos**.

Para los desarrolladores esto supone un problema constante: en un equipo de trabajo con sistemas heterogéneos, cada uno necesita las mismas dependencias instaladas, con las mismas versiones, lo que desemboca en el conocido problema de **"en mi máquina funciona"**.

Un contenedor es una **unidad ligera y portátil** que permite empaquetar una aplicación junto con todas sus dependencias (bibliotecas, configuraciones y binarios) en un entorno aislado.

A diferencia de las máquinas virtuales, los contenedores **no incluyen un sistema operativo completo**: comparten el núcleo (kernel) del sistema operativo del anfitrión, lo que los hace más eficientes en consumo de recursos (memoria y CPU).

#### ``Beneficios de los contenedores``
- **Portabilidad:** Al empaquetar la aplicación con todas sus dependencias, se elimina la posibilidad de problemas relacionados con configuraciones del SO, bibliotecas o versiones de software. Un contenedor funciona igual en local, en staging y en producción.
- **Eficiencia:** Comparten el núcleo del SO anfitrión en lugar de requerir un sistema operativo completo para cada instancia. El tiempo de arranque es casi instantáneo y el consumo de CPU/memoria/almacenamiento es mínimo comparado con las VMs.
- **Escalabilidad:** Ideales para arquitecturas de microservicios. Cada servicio se ejecuta en su propio contenedor y se puede escalar de forma independiente. Combinados con orquestadores como Kubernetes, permiten la gestión automatizada de la escalabilidad horizontal y vertical.

#### ``Breve historia``
| Año | Hito |
|---|---|
| ~1970s | `chroot` en UNIX: primer concepto de aislamiento de procesos |
| 2000s | FreeBSD Jails y tecnologías avanzadas en el kernel de Linux |
| 2013 | Nace **Docker**: democratiza los contenedores con herramientas fáciles de usar y Docker Hub |
| 2014 | Google lanza Kubernetes para orquestación de contenedores |
| 2020+ | Alternativas como **Podman** emergen: sin daemon, ejecución rootless |
| Actualidad | Componente esencial de la infraestructura moderna, microservicios y DevOps |

### **Contenedor vs. Máquina Virtual**
| Característica | Contenedor | Máquina Virtual |
|---|---|---|
| Virtualización | Nivel de SO (kernel compartido) | Hardware completo |
| SO propio | No (comparte el kernel) | Sí, uno por instancia |
| Peso | Ligero (MB) | Pesado (GB) |
| Tiempo de inicio | Casi instantáneo | Minutos |
| Aislamiento | Proceso/aplicación | Sistema completo |
| Eficiencia de recursos | Alta | Menor |

## Docker
---
Docker es la **plataforma de contenedores más popular del mundo**. Facilita la creación, distribución y ejecución de aplicaciones en contenedores. Ha contado con el apoyo de grandes empresas como Red Hat, Google, IBM y Microsoft. Docker sigue una arquitectura **cliente-servidor**:

**Componentes principales**

**Docker Engine** es el núcleo de la plataforma y está compuesto por:
- **Daemon de Docker (`dockerd`):** servicio en segundo plano que gestiona imágenes, contenedores, redes y volúmenes. Responde a las solicitudes del cliente.
- **CLI de Docker:** interfaz de línea de comandos para interactuar con Docker (`docker run`, `docker build`, `docker ps`, etc.).
- **API REST de Docker:** interfaz programática para comunicarse con el daemon, utilizada tanto por la CLI como por aplicaciones externas.

### **Herramientas del ecosistema Docker**

| Herramienta | Descripción |
|---|---|
| **Docker Desktop** | Aplicación de escritorio para Mac, Windows y Linux con GUI integrada |
| **Docker Engine** | Motor de ejecución de contenedores (daemon + CLI + API) |
| **Docker Compose** | Define y ejecuta aplicaciones multi-contenedor con un archivo YAML |
| **Docker Hub** | Registro público y privado de imágenes de contenedores |
| **Docker Swarm** | Orquestación nativa de clústeres de Docker |
| **Docker CLI** | Interfaz de línea de comandos |
| **Docker Volume** | Gestión de almacenamiento persistente |

### **Comandos generales esenciales**

```bash
docker version              # Muestra la versión de Docker
docker info                 # Información del sistema Docker
docker help                 # Ayuda general
docker login                # Inicia sesión en Docker Hub
docker logout               # Cierra sesión
```

## Imágenes
---
Una imagen Docker es un **paquete inmutable de solo lectura** que contiene todo lo necesario para ejecutar una aplicación: código, ejecutables, librerías, configuraciones, variables de entorno y el sistema de archivos que usarán los contenedores.

**Conceptos clave**: 
- **Plantilla de solo lectura:** Las imágenes no se modifican. A partir de una imagen se crean los contenedores (instancias en ejecución).
- **Sistema de capas (layers):** Las imágenes se construyen en capas apiladas, como una cebolla. Cada instrucción del Dockerfile genera una nueva capa. Las capas son inmutables y se pueden compartir entre imágenes, lo que ahorra espacio y acelera las descargas.
- **Tags (etiquetas):** Identifican versiones de una imagen. Por ejemplo, `ubuntu:22.04` o `nginx:latest`.
- **Imagen base:** Toda imagen parte de otra imagen (`FROM`). Las imágenes base suelen ser distribuciones Linux minimalistas como Alpine (~5 MB), Debian slim, o imágenes oficiales de servicios.

>**Analogía imagen / contenedor**
La imagen es el **ejecutable** (binario); el contenedor es la **instancia en ejecución** (proceso). De la misma imagen puedes lanzar múltiples contenedores simultáneamente.

### **Comandos de imágenes**

| Comando | Descripción |
|---|---|
| `docker image ls` | Lista todas las imágenes locales |
| `docker image pull` | Descarga una imagen de un repositorio |
| `docker image build` | Construye una imagen desde un Dockerfile |
| `docker image push` | Sube una imagen a un repositorio |
| `docker image inspect` | Información detallada de una imagen |
| `docker image tag` | Asigna nombre/etiqueta a una imagen |
| `docker image history` | Historial de capas de una imagen |
| `docker image rm` | Elimina una imagen |
| `docker image prune` | Elimina imágenes no utilizadas |

```bash
# Comandos más utilizados

docker image ls                    # Listar imágenes locales
docker images                      # equivalente

docker image build -t mi-app:1.0 . # Construir una imagen desde un Dockerfile
docker build -t mi-app:1.0 .       # equivalente

docker image inspect ubuntu        # Ver detalles de una imagen
docker image history ubuntu        # Historial de capas de una imagen

docker image rm ubuntu             # Eliminar una imagen
docker rmi ubuntu                  # equivalente
docker image prune                 # Eliminar imágenes no utilizadas (dangling)
docker image prune -a              # Eliminar TODAS las imágenes no utilizadas
```

### **Registros de imágenes**

**Docker Hub** (`hub.docker.com`) es el registro público oficial. Contiene:
- Imágenes **oficiales** (mantenidas por Docker y los propios proyectos): `nginx`, `postgres`, `python`, `node`, `ubuntu`...
- Imágenes de **la comunidad**: `usuario/imagen`
- Repositorios **privados** (con plan de suscripción)

Otros registros populares: GitHub Container Registry (`ghcr.io`), Google Container Registry (`gcr.io`), Amazon ECR, Azure Container Registry.

```bash
docker search nginx                                 # Buscar imágenes en Docker Hub

docker image pull ubuntu                            # Descargar una imagen desde Docker Hub
docker pull ubuntu                                  # equivalente
docker pull ubuntu:22.04                            # versión específica
docker pull ubuntu:latest                           # última versión (por defecto)

docker image tag mi-app:1.0 mi-usuario/mi-app:1.0   # Etiquetar una imagen
docker image push mi-usuario/mi-app:1.0             # Subir una imagen a Docker Hub
docker push mi-usuario/mi-app:1.0                   # equivalente
```

## Contenedores
---
Un contenedor es una **instancia ejecutable de una imagen**. Se crea a partir de ella y representa el proceso en ejecución de la aplicación con su entorno aislado.
**Características:**
- Puede tener **más de un proceso** en ejecución, aunque la buena práctica es **un proceso por contenedor**.
- Está **aislado** de otros contenedores y del host (red, sistema de archivos, procesos).
- Cuando se elimina un contenedor, **se pierden los datos** que no estén en un volumen persistente.
- Se puede conectar a redes, adjuntar volúmenes y publicar puertos.

### **Comandos de contenedores**

| Comando | Descripción |
|---|---|
| `docker container run` | Crea y ejecuta un contenedor desde una imagen |
| `docker container ls` | Lista contenedores en ejecución |
| `docker container ls -a` | Lista todos los contenedores |
| `docker container start` | Inicia un contenedor parado |
| `docker container stop` | Detiene un contenedor en ejecución |
| `docker container restart` | Reinicia un contenedor |
| `docker container rm` | Elimina un contenedor |
| `docker container exec` | Ejecuta un comando en un contenedor activo |
| `docker container logs` | Muestra los logs del contenedor |
| `docker container inspect` | Información detallada del contenedor |
| `docker container cp` | Copia archivos entre host y contenedor |
| `docker container prune` | Elimina todos los contenedores parados |
| `docker stats` | Estadísticas de recursos en tiempo real |

```bash

docker container run nginx # Crear y ejecutar un contenedor
docker run nginx                   # equivalente

# Opciones comunes de docker run:
docker run -d nginx                    # -d: segundo plano (detached)
docker run -it ubuntu bash             # -it: modo interactivo + terminal
docker run --name mi-nginx nginx       # --name: asignar nombre
docker run -p 8080:80 nginx            # -p: mapear puertos host:contenedor
docker run -e VAR=valor nginx          # -e: variable de entorno
docker run -v /host:/contenedor nginx  # -v: montar volumen
docker run --rm nginx                  # --rm: eliminar al parar
docker run --network mi-red nginx      # --network: conectar a red

docker container ls # Listar contenedores en ejecución
docker ps                          # equivalente

docker container ls -a # Listar TODOS los contenedores (incluidos parados)
docker ps -a                       # equivalente

# Iniciar/detener/reiniciar un contenedor
docker container start mi-nginx
docker container stop mi-nginx
docker container restart mi-nginx

# Pausar/reanudar
docker container pause mi-nginx
docker container unpause mi-nginx

docker container rm mi-nginx # Eliminar un contenedor (debe estar parado)
docker rm mi-nginx                 # equivalente
docker rm -f mi-nginx              # forzar eliminación aunque esté activo

docker container logs mi-nginx # Ver logs de un contenedor
docker logs -f mi-nginx            # seguir logs en tiempo real
docker logs --tail 100 mi-nginx    # últimas 100 líneas

docker container exec mi-nginx ls /etc/nginx  # Ejecutar un comando en un contenedor en ejecución
docker exec -it mi-nginx bash      # abrir terminal interactivo

docker container inspect mi-nginx  # Información detallada del contenedor

docker stats mi-nginx  # Estadísticas de uso de recursos

# Copiar archivos entre host y contenedor
docker container cp mi-nginx:/etc/nginx/nginx.conf ./nginx.conf
docker cp ./index.html mi-nginx:/usr/share/nginx/html/

docker container prune  # Eliminar todos los contenedores parados
```

### **Comando `docker ps`**

Columnas que muestra `docker ps -a`:

| Columna | Descripción |
|---|---|
| `CONTAINER ID` | Identificador único del contenedor |
| `IMAGE` | Imagen desde la que se creó |
| `COMMAND` | Proceso que se está ejecutando dentro |
| `CREATED` | Tiempo desde que se creó |
| `STATUS` | Estado actual y tiempo en ese estado |
| `PORTS` | Mapeo de puertos |
| `NAMES` | Nombre del contenedor (aleatorio si no se especifica) |

## Redes
---
Las redes Docker permiten definir **cómo se comunican los contenedores** entre sí y con el exterior. El componente principal que gestiona la conectividad es **libnetwork**.

### **Tipos de redes en Docker**

#### ``1. Bridge (por defecto)``
Red puente, es la red predeterminada para los contenedores. Proporciona aislamiento básico y permite la comunicación entre contenedores en el mismo host. Los contenedores pueden referenciarse por nombre y se pueden exponer puertos al host.

```bash
docker run -d --name web --network bridge -p 8080:80 nginx
```

#### ``2. Host``
Elimina el aislamiento de red entre el contenedor y el host. El contenedor comparte directamente la interfaz de red del sistema, usando la misma IP. Mejor rendimiento pero mayor riesgo de conflicto de puertos.

```bash
docker run -d --network host nginx
```

#### ``3. Overlay``
Utilizada para contenedores distribuidos en **diferentes hosts**. Es la red usada en entornos de **Docker Swarm** para comunicar servicios entre nodos.

#### ``4. Macvlan``
Asigna una dirección MAC propia a cada contenedor, haciéndolos aparecer como dispositivos físicos en la red. Útil para aplicaciones que necesitan estar directamente en la red LAN.

#### ``5. None``
Desactiva completamente la conectividad de red del contenedor. Útil para tareas de procesamiento aislado sin necesidad de red.

#### ``6. Redes personalizadas (recomendado)``
Las redes bridge personalizadas son **la práctica recomendada** ya que ofrecen:
- **Resolución DNS automática** entre contenedores por nombre.
- Mejor aislamiento que la red bridge por defecto.
- Mayor control sobre la subnet y el gateway.

```bash
docker network create mi-red  # Crear una red personalizada

docker network create --driver bridge --subnet 172.20.0.0/16 mi-red # Crear red con subnet específica

# Conectar contenedores a la red personalizada
docker run -d --name app --network mi-red mi-app
docker run -d --name db --network mi-red postgres

# Ahora 'app' puede llegar a 'db' usando su nombre como hostname
```

### **Comandos de redes**
| Comando | Descripción |
|---|---|
| `docker network ls` | Lista todas las redes |
| `docker network create` | Crea una nueva red |
| `docker network inspect` | Información detallada de una red |
| `docker network connect` | Conecta un contenedor a una red |
| `docker network disconnect` | Desconecta un contenedor de una red |
| `docker network rm` | Elimina una red |
| `docker network prune` | Elimina redes no utilizadas |


```bash
docker network ls # Listar todas las redes

docker network create mi-red  # Crear una red
docker network create --driver overlay mi-overlay   # tipo overlay

docker network inspect mi-red # Información detallada de una red
docker network inspect bridge                       # red por defecto

docker network connect mi-red mi-contenedor # Conectar un contenedor a una red (en caliente)

docker network disconnect mi-red mi-contenedor  # Desconectar un contenedor de una red

docker network rm mi-red  # Eliminar una red

docker network prune  # Eliminar todas las redes no utilizadas
```

### **Publicación de puertos**

```bash
# Mapear puerto del host al contenedor
docker run -p 8080:80 nginx           # host:contenedor
docker run -p 127.0.0.1:8080:80 nginx # solo desde localhost
docker run -P nginx                   # mapeo automático de todos los puertos expuestos
```


## Volúmenes
---
Un volumen Docker permite **conservar los datos más allá del ciclo de vida de un contenedor**. Sin volúmenes, todos los datos generados dentro de un contenedor se pierden cuando este se elimina.
**Casos de uso:**
- **Transferir datos** a un contenedor.
- **Guardar datos persistentes** (bases de datos, logs, configuraciones).
- **Compartir datos** entre múltiples contenedores.

### **Tipos de almacenamiento en Docker**

#### ``1. Volumes (volúmenes gestionados por Docker)``
Son la opción **recomendada**. Docker gestiona su ubicación en el sistema de archivos del host (`/var/lib/docker/volumes/`). Son independientes del contenedor.

```bash
docker run -d -v mi-volumen:/var/lib/postgresql/data postgres
```

#### ``2. Bind Mounts (montajes de enlace)``
Montan un directorio o archivo específico del host dentro del contenedor. Útiles en desarrollo para reflejar cambios del código fuente en tiempo real.

```bash
docker run -d -v /ruta/en/host:/ruta/en/contenedor nginx
docker run -d -v $(pwd)/html:/usr/share/nginx/html nginx
```

#### ``3. tmpfs Mounts``
Almacenamiento temporal en memoria RAM. Los datos no se persisten y desaparecen cuando el contenedor para. Útil para datos sensibles que no deben persistir en disco.

```bash
docker run -d --tmpfs /tmp nginx
```

### **Características de los volúmenes**

- **Persistencia de datos:** Los datos sobreviven a la eliminación del contenedor.
- **Compartir datos entre contenedores:** Varios contenedores pueden montar el mismo volumen simultáneamente.
- **Desacoplamiento datos/contenedor:** Se puede actualizar o reemplazar el contenedor sin perder datos.
- **Integración con el host:** Los datos son accesibles desde fuera del contenedor.
- **Flexibilidad:** Volúmenes con nombre, anónimos o gestionados externamente (NFS, cloud storage...).
- **Escalabilidad:** Facilitan la distribución de datos en entornos orquestados.

### **Comandos de volúmenes**
| Comando | Descripción |
|---|---|
| `docker volume create` | Crea un nuevo volumen |
| `docker volume ls` | Lista todos los volúmenes |
| `docker volume inspect` | Información detallada del volumen |
| `docker volume rm` | Elimina un volumen |
| `docker volume prune` | Elimina volúmenes no utilizados |

```bash
docker volume create mi-volumen # Crear un volumen

docker volume ls  # Listar volúmenes

docker volume inspect mi-volumen  # Información detallada de un volumen

docker volume rm mi-volumen # Eliminar un volumen

docker volume prune # Eliminar todos los volúmenes no utilizados

docker run -d -v mi-volumen:/datos mi-app # Usar un volumen al crear un contenedor (sintaxis -v)

docker run -d --mount source=mi-volumen,target=/datos mi-app  # Usar un volumen al crear un contenedor (sintaxis --mount, más explícita)

docker run -d -v mi-volumen:/datos:ro mi-app  # Contenedor de solo lectura
```


## Dockerfile
---
Un **Dockerfile** es un archivo de texto con una serie de instrucciones que Docker utiliza para construir una imagen de forma automatizada y reproducible. Cada instrucción genera una nueva **capa** en la imagen.

### **Instrucciones del Dockerfile**

| Instrucción | Descripción |
|---|---|
| `FROM` | **Obligatoria.** Indica la imagen base. Siempre es la primera instrucción. |
| `RUN` | Ejecuta un comando durante la construcción y guarda el resultado como capa. |
| `CMD` | Comando por defecto al iniciar el contenedor (puede ser sobreescrito). |
| `ENTRYPOINT` | Comando principal que se ejecuta siempre al arrancar el contenedor. |
| `COPY` | Copia archivos/directorios del host a la imagen. |
| `ADD` | Como COPY pero también soporta URLs y descomprime archivos tar. |
| `EXPOSE` | Documenta el puerto que escuchará el contenedor (no lo publica). |
| `ENV` | Declara variables de entorno disponibles en la imagen y el contenedor. |
| `ARG` | Define variables disponibles solo durante el proceso de construcción. |
| `WORKDIR` | Establece el directorio de trabajo para RUN, CMD, COPY, ADD, ENTRYPOINT. |
| `USER` | Define el usuario con el que se ejecutarán las instrucciones posteriores. |
| `VOLUME` | Declara un punto de montaje de volumen. |
| `LABEL` | Añade metadatos a la imagen (autor, versión, descripción...). |
| `MAINTAINER` | (Obsoleto) Indica el mantenedor del Dockerfile. Usar LABEL. |
| `ONBUILD` | Instrucción que se ejecuta cuando la imagen es usada como base de otra. |
| `HEALTHCHECK` | Define un comando para comprobar el estado de salud del contenedor. |
| `STOPSIGNAL` | Define la señal de sistema para detener el contenedor. |

### **Ejemplos**

#### ``Ejemplo 1: Aplicación Python simple``

```dockerfile
# Imagen base oficial de Python
FROM python:3.11-slim

# Metadatos
LABEL maintainer="tu@email.com"
LABEL version="1.0"

# Variables de entorno
ENV APP_HOME=/app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Directorio de trabajo
WORKDIR $APP_HOME

# Copiar e instalar dependencias primero (aprovecha caché de capas)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el código fuente
COPY . .

# Exponer el puerto
EXPOSE 8000

# Usuario no root (buena práctica de seguridad)
RUN adduser --disabled-password --gecos '' appuser
USER appuser

# Comando por defecto
CMD ["python", "app.py"]
```

#### ``Ejemplo 2: Servidor web Nginx con contenido personalizado``

```dockerfile
FROM nginx:alpine

# Copiar configuración personalizada
COPY nginx.conf /etc/nginx/nginx.conf

# Copiar contenido web
COPY html/ /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

#### ``Ejemplo 3: Imagen con Alpine y Python (ejemplo del temario)``

```dockerfile
FROM alpine:latest

RUN apk update && apk add python3

RUN ln -sf python3 /usr/bin/python

CMD ["python3"]
```

#### ``Ejemplo 4: Multi-stage build (construcción en múltiples etapas)``

Técnica avanzada para reducir el tamaño de la imagen final:

```dockerfile
# Etapa de construcción
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Etapa de producción (imagen final ligera)
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### **Comandos para construir imágenes**

```bash
# Construir imagen desde el directorio actual (busca Dockerfile)
docker build -t mi-app:1.0 .

# Especificar ubicación del Dockerfile
docker build -f ruta/al/Dockerfile -t mi-app:1.0 .

# Pasar argumentos de construcción
docker build --build-arg VERSION=2.0 -t mi-app:2.0 .

# Sin usar caché
docker build --no-cache -t mi-app:1.0 .

# Ver las capas generadas
docker history mi-app:1.0
```
**Buenas prácticas en Dockerfile**
1. **Usar imágenes base oficiales y ligeras** (alpine, slim).
2. **Ordenar las instrucciones por frecuencia de cambio** (lo que menos cambia, al principio) para aprovechar la caché.
3. **Minimizar el número de capas** combinando comandos RUN con `&&`.
4. **No ejecutar como root**: crear un usuario no privilegiado con `USER`.
5. **Usar `.dockerignore`** para excluir archivos innecesarios (como `node_modules`, `.git`).
6. **Un proceso por contenedor**: simplifica el escalado y los logs.
7. **Usar multi-stage builds** para reducir el tamaño de la imagen final.
8. **Usar variables ARG y ENV** para hacer el Dockerfile configurable.

```dockerfile
# Combinar comandos RUN para reducir capas
RUN apt-get update && \
    apt-get install -y curl git && \
    rm -rf /var/lib/apt/lists/*
```

> 📖 Documentación oficial de referencia: https://docs.docker.com/engine/reference/builder/


## Docker Compose
---
**Docker Compose** es una herramienta para **definir y ejecutar aplicaciones Docker multi-contenedor** mediante un archivo YAML (`docker-compose.yml`). Con un solo comando se crean e inician todos los servicios de la aplicación.
**Casos de uso**
- Aplicaciones con varios servicios (frontend + backend + base de datos + cache...).
- Entornos de desarrollo reproducibles.
- Testing e integración continua.
- Despliegues en entornos sencillos (staging, desarrollo).

### **Estructura del archivo**
**Opciones más usadas en un servicio**
| Opción | Descripción |
|---|---|
| `image` | Imagen Docker a usar |
| `build` | Directorio o config para construir la imagen |
| `container_name` | Nombre del contenedor |
| `ports` | Mapeo de puertos (`host:contenedor`) |
| `volumes` | Montaje de volúmenes o bind mounts |
| `environment` | Variables de entorno |
| `env_file` | Archivo `.env` con variables de entorno |
| `depends_on` | Orden de inicio (espera a que otro servicio esté listo) |
| `networks` | Redes a las que se conecta |
| `restart` | Política de reinicio (`no`, `always`, `unless-stopped`, `on-failure`) |
| `command` | Sobreescribe el CMD de la imagen |
| `entrypoint` | Sobreescribe el ENTRYPOINT de la imagen |
| `healthcheck` | Comando para verificar el estado del servicio |

```yaml
services:              # Definición de los contenedores
  nombre-servicio:
    image: ...
    build: ...
    ports: ...
    volumes: ...
    environment: ...
    networks: ...
    depends_on: ...

volumes:               # Definición de volúmenes
  nombre-volumen:

networks:              # Definición de redes
  nombre-red:
```

### **Ejemplos**
```yaml
# Aplicación web + Base de datos (con un Dockerfile)
services:
  web:
    build: .                # Construye desde el Dockerfile del directorio actual
    image: mi-app:latest
    container_name: mi-web
    ports:
      - "8080:80"           # host:contenedor
    environment:
      - DATABASE_URL=postgres://user:pass@db:5432/midb
      - DEBUG=false
    volumes:
      - ./static:/app/static
    depends_on:
      - db
    networks:
      - app-network
    restart: unless-stopped

  db:
    image: postgres:15-alpine
    container_name: mi-db
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: midb
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - app-network
    restart: unless-stopped

  cache:
    image: redis:7-alpine
    container_name: mi-cache
    networks:
      - app-network

volumes:
  postgres-data:          # Volumen persistente para la base de datos

networks:
  app-network:
    driver: bridge
```

```yaml
# Nginx + PHP-FPM + MySQL
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./src:/var/www/html
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - php

  php:
    image: php:8.2-fpm
    volumes:
      - ./src:/var/www/html

  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: app
    volumes:
      - mysql-data:/var/lib/mysql

volumes:
  mysql-data:
```

### **Comandos de Docker Compose**
| Comando | Descripción |
|---|---|
| `docker compose up` | Crea e inicia todos los servicios |
| `docker compose down` | Para y elimina contenedores y redes |
| `docker compose ps` | Lista los servicios en ejecución |
| `docker compose logs` | Muestra los logs de los servicios |
| `docker compose build` | Construye o reconstruye las imágenes |
| `docker compose start` | Inicia servicios parados |
| `docker compose stop` | Para servicios sin eliminarlos |
| `docker compose restart` | Reinicia los servicios |
| `docker compose exec` | Ejecuta un comando en un servicio activo |
| `docker compose pull` | Descarga las imágenes de los servicios |
| `docker compose config` | Valida y muestra la configuración |
| `docker compose scale` | Escala el número de instancias de un servicio |


```bash
docker compose up -d          # Iniciar todos los servicios (en segundo plano)
docker compose up -d --build  # Iniciar y reconstruir imágenes si hay cambios
docker compose ps             # Ver servicios en ejecución
# ----------
docker compose logs           # Ver logs de todos los servicios
docker compose logs -f        # seguir en tiempo real
docker compose logs web       # solo del servicio 'web'
# ----------
docker compose stop           # Detener servicios (sin eliminar)
docker compose restart web    # Reiniciar un servicio
docker compose exec web bash  # Ejecutar un comando en un servicio
# ----------
docker compose down               # Detener y eliminar contenedores y redes
docker compose down -v            # también elimina volúmenes
docker compose down --rmi all -v  # Eliminar todo (container, redes, imágenes y volúmenes)
```

**Buenas prácticas con Docker Compose**
1. **Usar archivos `.env`** para las variables sensibles (contraseñas, claves API).
2. **Definir políticas de reinicio** (`restart: unless-stopped`) en producción.
3. **Usar `healthcheck`** para que `depends_on` espere a que el servicio esté realmente listo.
4. **Separar configuraciones por entorno**: `docker-compose.yml` (base) + `docker-compose.override.yml` (desarrollo) + `docker-compose.prod.yml` (producción).
5. **Definir redes explícitas** en lugar de usar la red por defecto.
6. **Nombrar los volúmenes** para facilitar su gestión e identificación.

## Resumen de comandos esenciales
---
```bash
# ── IMÁGENES ──────────────────────────────────────
docker pull nginx:alpine            # Descargar imagen
docker images                       # Listar imágenes
docker rmi nginx:alpine             # Eliminar imagen
docker build -t mi-app .            # Construir imagen

# ── CONTENEDORES ──────────────────────────────────
docker run -d -p 8080:80 --name web nginx   # Crear y ejecutar
docker ps                           # Listar activos
docker ps -a                        # Listar todos
docker stop web                     # Parar
docker start web                    # Iniciar
docker rm web                       # Eliminar
docker exec -it web bash            # Terminal interactivo
docker logs -f web                  # Ver logs

# ── REDES ─────────────────────────────────────────
docker network ls                   # Listar redes
docker network create mi-red        # Crear red
docker network inspect mi-red       # Inspeccionar
docker network connect mi-red web   # Conectar contenedor

# ── VOLÚMENES ─────────────────────────────────────
docker volume create mis-datos      # Crear volumen
docker volume ls                    # Listar volúmenes
docker volume inspect mis-datos     # Inspeccionar
docker run -v mis-datos:/data nginx # Usar volumen

# ── DOCKER COMPOSE ────────────────────────────────
docker compose up -d                # Iniciar servicios
docker compose down                 # Parar y eliminar
docker compose ps                   # Ver estado
docker compose logs -f              # Ver logs
docker compose exec web bash        # Terminal en servicio
```

## Referencias
---
> 📚 **Documentación oficial:** https://docs.docker.com  
> 🐳 **Docker Hub:** https://hub.docker.com  
> 🔧 **Referencia Dockerfile:** https://docs.docker.com/engine/reference/builder/  
> ⚙️ **Referencia Compose:** https://docs.docker.com/compose/compose-file/

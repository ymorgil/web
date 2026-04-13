---
title: "Docker: Guía Completa de Contenedores"
weight: 3
---
# Ejercicio: Programar en Contenedores Docker con VS Code

**🎬 Enlace al video original:** [https://youtu.be/9_WkqhLMUZA](https://youtu.be/9_WkqhLMUZA)

Este ejercicio te guiará a través de las tres formas de programar directamente dentro de contenedores Docker utilizando Visual Studio Code para aislar dependencias.

---

## Requisitos Previos

1. **Docker Desktop:** Instalado y en ejecución.
2. **Visual Studio Code:** Con las extensiones:
   - `Docker` (de Microsoft)
   - `Dev Containers` (de Microsoft)

---

## Paso 1: Configuración del Proyecto Base (FastAPI)

Crea una carpeta para tu proyecto y añade los siguientes archivos básicos:

### 1.1. `main.py`

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World desde Docker"}

@app.get("/items/{item_id}")
def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "q": q}
```

### 1.2. `requirements.txt`

```
fastapi
uvicorn
```

---

## Paso 2: Método Manual (Docker Puro)

Este método consiste en construir la imagen y correr el contenedor manualmente enlazando carpetas.

### 2.1. Crear el `Dockerfile`

```dockerfile
FROM python:3.11-slim
WORKDIR /code
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
```

### 2.2. Construir la imagen

```powershell
docker build -t imagen-fastapi .
```

### 2.3. Ejecutar el contenedor con volumen (sincronización de código)

```powershell
# PowerShell (Windows)
docker run -d -p 8000:8000 -v ${PWD}:/code imagen-fastapi

# Linux / Mac
docker run -d -p 8000:8000 -v $(pwd):/code imagen-fastapi
```

> **Nota:** El flag `-v` monta tu carpeta local dentro del contenedor, por lo que cualquier cambio en el código se refleja en tiempo real sin reconstruir la imagen.

---

## Paso 3: Conexión mediante la Extensión "Dev Containers"

Este método permite usar todas las ayudas de VS Code (IntelliSense, autocompletado) directamente dentro del contenedor.

1. Con el contenedor del paso anterior en ejecución, haz clic en el botón **azul** (`><`) de la esquina inferior izquierda de VS Code.
2. Selecciona **"Attach to Running Container"**.
3. Elige el contenedor `imagen-fastapi` de la lista.
4. Se abrirá una nueva ventana de VS Code conectada al contenedor. Abre la carpeta `/code`.
5. **Tip:** Instala la extensión de Python *dentro del contenedor* para tener autocompletado y análisis de errores.

---

## Paso 4: Configuración de Ambiente Nativo (Dev Container Config)

Para proyectos nuevos donde quieres que VS Code configure todo el ambiente automáticamente.

1. Crea una carpeta vacía y ábrela en VS Code.
2. Presiona `Ctrl + Shift + P` y busca:
   ```
   Dev Containers: Add Dev Container Configuration File...
   ```
3. Selecciona **Python 3** (versión 3.11 o similar) de la lista de plantillas.
4. VS Code creará automáticamente una carpeta `.devcontainer/` con un archivo `devcontainer.json`.
5. Haz clic en el botón azul inferior (`><`) y selecciona **"Reopen in Container"**.
6. VS Code construirá la imagen y reabrirá el proyecto ya dentro del contenedor.

---

## Resumen de Comandos Útiles

| Comando | Descripción |
|---|---|
| `docker ps` | Ver contenedores activos |
| `docker stop <ID>` | Detener un contenedor |
| `docker rm <ID>` | Eliminar un contenedor |
| `docker images` | Ver imágenes creadas |
| `docker build -t <nombre> .` | Construir una imagen desde un Dockerfile |
| `docker run -d -p <host>:<cont> <imagen>` | Ejecutar un contenedor en segundo plano |

---

> Tutorial basado en el canal **Píldoras de Programación**.

































# Visual Studio Code usando WSL y Docker

Una vez instalado **WSL**, configurado **Ubuntu** y teniendo **Docker Desktop** integrado con **Visual Studio Code**, el siguiente paso es trabajar directamente desde el entorno Linux y comenzar a ejecutar contenedores.

Este documento describe cómo utilizar Visual Studio Code dentro de Ubuntu y cómo crear y ejecutar un contenedor sencillo con Python, que servirá como base para proyectos más complejos.

## Extensiones necesarias en Visual Studio Code para trabajar con Docker y WSL
Instalar [Visual Studio Code](https://code.visualstudio.com/). Se recomienda instalar las siguientes extensiones:
- Python
- Jupyter
- WSL (si usáis WSL2)
- GitHub Copilot

- **Remote - WSL**  
Permite abrir y trabajar en el entorno Linux (Ubuntu) desde Visual Studio Code utilizando WSL.

- **Docker**  
Permite crear, ejecutar y gestionar contenedores e imágenes Docker directamente desde Visual Studio Code.

- **Python**  
Proporciona soporte para desarrollar, ejecutar y depurar scripts Python dentro del editor.

- **Dev Containers**  
Permite abrir proyectos directamente dentro de contenedores Docker para trabajar en entornos aislados y reproducibles.

- **YAML**  
Facilita la edición y validación de archivos de configuración como `docker-compose.yml`.

- **GitHub Pull Requests and Issues**  
Permite gestionar repositorios, cambios y revisiones de código desde Visual Studio Code.

- **Markdown All in One**  
Mejora la edición de archivos Markdown con herramientas de formato, tablas y atajos de escritura.

# 1. Ejecutar Visual Studio Code en Ubuntu (WSL)

Trabajar desde Ubuntu dentro de WSL permite utilizar herramientas Linux
reales, gestionar dependencias de forma más sencilla y ejecutar
contenedores Docker en un entorno similar a producción.

## 1.1 Abrir Ubuntu (WSL)

``` bash
wsl
```

o bien:

``` bash
ubuntu
```

------------------------------------------------------------------------

## 1.2 Ir al directorio de trabajo

``` bash
cd ~
mkdir proyectos
cd proyectos
```

------------------------------------------------------------------------

## 1.3 Abrir Visual Studio Code desde Ubuntu

``` bash
code .
```

Esto:

-   Abre Visual Studio Code
-   Conecta automáticamente con WSL
-   Permite trabajar como si estuvieras en Linux real

------------------------------------------------------------------------

## 1.4 Comprobar que Docker funciona

``` bash
docker --version
docker run hello-world
```

------------------------------------------------------------------------

# 2. Uso de contenedores Docker desde Visual Studio Code

Los contenedores permiten ejecutar aplicaciones en entornos aislados,
reproducibles y portables.

------------------------------------------------------------------------

## 2.1 Crear un proyecto Python

``` bash
mkdir python-docker
cd python-docker
```

------------------------------------------------------------------------

## 2.2 Crear un script Python

Archivo:

``` bash
nano app.py
```

Contenido:

``` python
print("Hola desde un contenedor Docker con Python")
```

------------------------------------------------------------------------

## 2.3 Crear un Dockerfile

Archivo:

``` bash
nano Dockerfile
```

Contenido:

``` dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY app.py .

CMD ["python", "app.py"]
```

------------------------------------------------------------------------

## 2.4 Construir la imagen

``` bash
docker build -t mi-python .
```

------------------------------------------------------------------------

## 2.5 Ejecutar el contenedor

``` bash
docker run mi-python
```

Salida esperada:

    Hola desde un contenedor Docker con Python

------------------------------------------------------------------------

# Resumen

Se ha aprendido a:

-   Ejecutar VS Code en Ubuntu
-   Crear un script Python
-   Crear un Dockerfile
-   Construir una imagen
-   Ejecutar un contenedor

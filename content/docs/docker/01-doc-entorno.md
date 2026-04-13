---
title: "Entorno (WSL y Docker)"
weight: 1
---

#  🐳 Entorno (WSL y Docker)

## WSL (Windows Subsystem for Linux)
---
WSL es una característica de Windows que permite ejecutar un entorno Linux directamente sobre Windows, sin necesidad de una máquina virtual ni de arranque dual. Gracias a WSL es posible usar herramientas de línea de comandos de Linux, ejecutar scripts Bash y trabajar con aplicaciones Linux integradas en el flujo de trabajo de Windows.

### **Activación y puesta en marcha**

#### ``👉 Paso 1 — Activar características de Windows``

Abrir **Características de Windows** y activar:
- Plataforma de máquina virtual
- Subsistema de Windows para Linux
![Activación de características de Windows](/web/docker/img/docker01.png)

#### ``👉 Paso 2 — Instalación de WSL + Ubuntu 24.04``
 
Abrir **PowerShell** como administrador y ejecutar:
 
```powershell
winget install Microsoft.WSL  # Instalar WSL con winget
wsl --version  # Comprobar la instalación
wsl --install -d Ubuntu-24.04  # Instalar Ubuntu 24.04
wsl --list --online # Si no aparece esa versión, listar las disponibles
```

La primera vez que arranque Ubuntu, el sistema solicitará crear:
- **Usuario** → nombre de usuario Linux
- **Contraseña** → se usará para `sudo`

### **Terminal de Windows**
 
La **Terminal de Windows** es una herramienta «todo en uno» disponible de forma gratuita en la Microsoft Store. Una vez instalada, basta con buscarla en el menú Inicio para ejecutarla.
 
Su principal ventaja es que permite abrir múltiples pestañas con diferentes entornos (PowerShell, CMD, Ubuntu...) en una sola ventana, con personalización completa de colores y fuentes.

![terminal](/web/docker/img/docker02.png)

Una vez dentro de Ubuntu, actualizar los paquetes:
```bash
sudo apt update && sudo apt upgrade -y && apt autoremove
```

## Docker
---
Docker es una plataforma de contenedores que permite empaquetar aplicaciones junto con todas sus dependencias en unidades aisladas y portables llamadas **contenedores**. A diferencia de las máquinas virtuales, los contenedores comparten el kernel del sistema operativo, lo que los hace mucho más ligeros y rápidos de arrancar.
 
### **Instalación de Docker Desktop e integración con WSL**
 
#### ``👉 Instalar Docker Desktop con winget``
 
```powershell
winget install Docker.DockerDesktop
```
 
#### ``👉 Configurar la integración con WSL``
 
1. Iniciar **Docker Desktop** desde el menú de inicio.
2. Esperar a que termine la configuración inicial.
3. Ir a: **Settings → Resources → WSL Integration**
4. Activar: **Ubuntu-24.04**
 
##### ``👉Comprobar Docker desde Ubuntu``
 
```bash
docker --version # Verificar la versión instalada
docker run hello-world # Ejecutar un contenedor de prueba
```
 
## Portainer
--- 
**Portainer** es una interfaz gráfica web para gestionar entornos Docker. Sustituye los comandos de terminal por un panel visual desde el que se pueden administrar contenedores, imágenes, redes y volúmenes de forma intuitiva. Es especialmente útil en entornos de desarrollo y aprendizaje, ya que permite ver el estado del sistema en tiempo real sin necesidad de recordar comandos.
 
### **Instalación**
 
La forma más sencilla de instalar Portainer en Docker Desktop es a través de las extensiones. Hay que abrir Docker Desktop, ir a la sección **Extensions** en el menú lateral izquierdo y buscar «Portainer» en el buscador. Al hacer clic en instalar, la aplicación descarga la imagen necesaria y configura el contenedor de gestión automáticamente.
 
Una vez instalado, aparecerá el icono de Portainer en la barra lateral. Al acceder por primera vez, el sistema solicitará crear una contraseña de administrador de al menos 12 caracteres. A continuación, hay que seleccionar el entorno **local** para conectar Portainer al motor de Docker del equipo.
 
### **Funcionalidades principales**
 
Portainer ofrece una interfaz muy intuitiva: desde el panel de control se puede monitorizar el consumo de CPU y RAM de cada contenedor, revisar los logs en tiempo real y acceder directamente a la consola de un servicio con un solo clic. También permite gestionar redes y volúmenes de forma visual, lo que resulta muy práctico frente a la interfaz más limitada de Docker Desktop.
 
Una de sus funciones más potentes son los **Stacks**, que permiten desplegar aplicaciones completas copiando y pegando el contenido de un archivo `docker-compose.yml` directamente en el navegador. Esto simplifica enormemente el despliegue de proyectos complejos sin necesidad de gestionar archivos locales de forma constante.











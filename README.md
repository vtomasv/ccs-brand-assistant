# CCS Brand Assistant

**Plugin de Pinokio para gestión de ADN de marca y campañas digitales con IA local para PYMEs**

> Desarrollado para la **Cámara de Comercio de Santiago (CCS)**

CCS Brand Assistant es un plugin para [Pinokio](https://pinokio.computer) que permite a las pequeñas y medianas empresas construir una identidad de marca estructurada —denominada **ADN empresarial**— y utilizarla como base para planificar y generar campañas de marketing digital multicanal, todo con inteligencia artificial ejecutándose localmente en la computadora del usuario, sin dependencia de servicios en la nube.

---

## Características principales

**Módulo de Marcas.** Permite registrar y gestionar múltiples marcas con sus datos básicos: nombre, sitio web, sector, mercados objetivo e idioma. Cada marca tiene su propio espacio de trabajo semiaislado con historial, ADN y campañas independientes.

**Análisis automático de sitio web.** A partir de la URL de la marca, el agente analizador extrae señales de identidad: propuesta de valor, tono comunicacional, paleta de colores, estilo visual, productos y servicios, y público objetivo.

**Entrevista guiada por agente.** Un agente especializado en marketing conduce una conversación de descubrimiento para refinar el ADN. Las preguntas son contextuales, progresivas y ancladas en lo que el sistema ya sabe de la marca.

**ADN empresarial versionado.** El ADN es un objeto semiestructurado con campos claros: propuesta de valor, tono, personalidad, paleta, tipografía, público objetivo, diferenciadores, restricciones y más.

**Generación de campañas con IA.** El agente estratega toma el ADN y los objetivos de negocio para construir una planificación temporal con etapas narrativas y publicaciones concretas por canal.

**Generación de imágenes con IA local.** Motor embebido (HuggingFace Diffusers) compatible con Windows, macOS y Linux. Soporta LCM Dreamshaper v7, SD Turbo y SDXL Turbo.

---

## Arquitectura

```
ccs-brand-assistant/
├── pinokio.js          # Configuración y menú dinámico del plugin
├── install.json        # Instalación con 1 click (Ollama + venv + deps)
├── start.json          # Inicio del servidor como daemon
├── stop.json           # Parada del servidor
├── reset.json          # Desinstalación (conserva datos)
├── requirements.txt    # Dependencias Python
├── scripts/            # Scripts PowerShell para Windows
│   ├── install_ollama.ps1   # Instala Ollama automáticamente
│   ├── start_ollama.ps1     # Inicia el servidor Ollama
│   ├── pull_model.ps1       # Descarga el modelo según RAM
│   ├── setup_venv.ps1       # Crea el entorno virtual Python
│   └── diagnose.ps1         # Diagnóstico de entorno (manual)
├── app/
│   ├── index.html      # Frontend SPA (HTML + CSS + JS vanilla)
│   ├── logo-ccs.svg    # Logo de la Cámara de Comercio de Santiago
│   └── fonts/          # Fuentes DM Sans, Feeling Passionate, Brushwell
├── server/
│   ├── app.py          # Backend FastAPI con todos los módulos
│   └── image_engine.py # Motor de generación de imágenes (Diffusers)
├── defaults/
│   ├── agents.json
│   └── prompts/
└── data/               # Datos del usuario (persistentes)
```

---

## Requisitos del sistema

| Componente | Mínimo | Recomendado |
|-----------|--------|-------------|
| RAM | 4 GB | 8 GB o más |
| Almacenamiento | 5 GB libres | 10 GB libres |
| Python | 3.9+ | 3.11+ |
| Pinokio | Última versión | Última versión |
| Ollama | Opcional | Recomendado |

El modelo de texto se selecciona automáticamente según la RAM disponible:

| RAM disponible | Modelo instalado |
|---------------|-----------------|
| Menos de 6 GB | `llama3.2:1b` |
| 6 a 12 GB | `llama3.2:3b` |
| Más de 12 GB | `llama3.1:8b` |

---

## Instalación

### Opción 1: Instalación desde Pinokio (recomendada)

1. Abre Pinokio en tu computadora.
2. Ve a **Discover** o **Install from URL**.
3. Ingresa la URL del repositorio: `https://github.com/vtomasv/ccs-brand-assistant`
4. Haz clic en **Instalar** y espera a que el proceso termine automáticamente.

### Opción 2: Instalación manual (Windows)

```powershell
# En una terminal PowerShell dentro del directorio de Pinokio
cd "$env:USERPROFILE\pinokio\api"
git clone https://github.com/vtomasv/ccs-brand-assistant
```

---

## Solución de problemas en Windows

### Error: "The argument 'scripts\start_ollama.ps1' does not exist"

Este error ocurre si el repositorio fue clonado sin la carpeta `scripts/`. Solución:

```powershell
# Dentro del directorio del plugin
git pull origin main
```

### Diagnóstico del entorno

Si hay problemas de instalación, ejecuta el script de diagnóstico:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\diagnose.ps1
```

Este script verifica: Python, entorno virtual, Ollama, dependencias y puertos.

### Ollama no inicia automáticamente

El plugin funciona **sin Ollama** usando el motor de imágenes embebido (Diffusers). Si necesitas modelos de texto:

1. Descarga Ollama desde [https://ollama.com/download](https://ollama.com/download)
2. Instálalo manualmente
3. Reinicia Pinokio

### Error de política de ejecución de PowerShell

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## Uso básico

**Paso 1 — Crear la marca.** Ve a la sección Marcas y haz clic en "Nueva Marca".

**Paso 2 — Analizar el sitio web.** Desde la tarjeta de la marca, haz clic en "Analizar web".

**Paso 3 — Entrevista de descubrimiento.** Ve a "Entrevista IA" y responde las preguntas del agente.

**Paso 4 — Aprobar el ADN.** Ve a "ADN de Marca" y haz clic en "Aprobar ADN".

**Paso 5 — Crear una campaña.** Ve a "Campañas" y haz clic en "Nueva Campaña".

**Paso 6 — Revisar y publicar.** Abre el calendario para ver y editar las publicaciones.

---

## Licencia

MIT License

---

*Desarrollado como parte del proyecto CCS — Plugins de IA local para PYMEs.*

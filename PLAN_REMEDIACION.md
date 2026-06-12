# Plan de Remediación y Mejoras de Seguridad: CCS Brand Assistant

Este documento categoriza y prioriza las falencias reportadas en el *Análisis de código y seguridad (v0.3.0)*, ajustadas al contexto de ejecución on-premise (localhost, single-user) a través de Pinokio.

## Criterio de Priorización (Contexto Pinokio)

Varias vulnerabilidades clásicas (ej. falta de autenticación, TLS local, CORS estricto) se consideran de **bajo riesgo** o **riesgo aceptado** dado que el plugin corre localmente en la máquina del usuario.
La priorización se centra en:
1. **Corrupción de datos:** Errores que puedan sobrescribir, mezclar o destruir información local del usuario (concurrencia, IDOR local).
2. **Estabilidad y Disponibilidad:** Errores silenciosos, consumo desmedido de RAM/disco, payloads excesivos.
3. **Ejecución de código arbitrario:** XSS vía archivos subidos, SSRF, inyección de prompts.
4. **Mantenibilidad:** Limpieza de dependencias, logs, constantes mágicas.

---

## Sprint 1: Correcciones Críticas (Estabilidad y Corrupción de Datos)

**Objetivo:** Asegurar que los datos locales del usuario no se corrompan y que el sistema no colapse por errores básicos de concurrencia o validación.

| ID | Hallazgo | Ubicación | Remediación Propuesta |
|:---|:---|:---|:---|
| **S1-01** | Búsqueda de campaña por substring (IDOR local) | `server/app.py:3370`, `3382`, `3424`, `4021`, `4356` | Cambiar `if campaign_id in camp_dir.name` por igualdad estricta (`==`). |
| **S1-02** | Importación de JSON sin esquema ni límite | `server/app.py:5136` (`/api/import`) | Implementar Pydantic schema validation estricta para la importación y validar tamaño del payload. |
| **S1-03** | Escritura de `plan.json` sin file-lock | `server/app.py:3283-3364` | Usar `save_json_safe` (con `asyncio.Lock`) para escribir `plan.json` durante la generación paralela. |
| **S1-04** | Variables globales concurrentes sin lock seguro | `server/app.py:121-132` | Proteger `_pull_status` y `_analyze_progress` con locks explícitos en lectura y escritura, unificando `threading.Lock` vs `asyncio.Lock`. |
| **S1-05** | Upload de imagen: consumo de RAM antes de validar | `server/app.py:4322-4327` | Validar el header `Content-Length` o leer en chunks (streaming) para rechazar archivos >10MB sin saturar RAM. |
| **S1-06** | Sanitización de SVG (XSS local) | `server/app.py:4295+` | Rechazar SVG en upload de imágenes, o forzar conversión a PNG usando Pillow antes de guardar. |

---

## Sprint 2: Mejoras Importantes (Resiliencia y Control de Flujo)

**Objetivo:** Mejorar la observabilidad de errores, evitar fallos silenciosos y proteger contra abusos locales (ej. consumo desmedido).

| ID | Hallazgo | Ubicación | Remediación Propuesta |
|:---|:---|:---|:---|
| **S2-01** | Eliminación de `except Exception: pass` | Múltiples (ej. `server/app.py:1140`, `2839`, `4166`) | Reemplazar capturas silenciosas por logs explícitos (`logger.error`) y respuestas diferenciadas. |
| **S2-02** | Fuga de threads y Timer | `server/app.py:41`, `154-159` | Añadir `shutdown(wait=False)` al ThreadPoolExecutor en el evento de shutdown de FastAPI. Asegurar que el `Timer` del TTL se cancele correctamente. |
| **S2-03** | Permisos de archivo sensibles | `server/app.py` (`save_json`, etc) | Asegurar que `mkdir()` y `write_text()` usen modos explícitos (`0o700` y `0o600`) para proteger `data/` en entornos multiusuario. |
| **S2-04** | Logs con datos sensibles (LLM Reasoning) | `server/app.py:528-547` | Implementar política de retención para `audit/` y evitar loguear prompts completos o redactar PII. |
| **S2-05** | Mitigación SSRF residual | `server/web_scraper.py:160,236` | Configurar `requests.get` con `allow_redirects=False` o re-validar el host destino tras redirección. |

---

## Sprint 3: Mejoras Menores, Optimizaciones y Deuda Técnica

**Objetivo:** Limpiar código muerto, centralizar configuraciones y mejorar la mantenibilidad a largo plazo.

| ID | Hallazgo | Ubicación | Remediación Propuesta |
|:---|:---|:---|:---|
| **S3-01** | Centralización de Constantes Mágicas | `server/app.py` | Unificar timeouts (`OLLAMA_TIMEOUT_DEFAULT`, etc.) y URLs hardcodeadas en una sección de configuración. |
| **S3-02** | Dependencias sin pin exacto | `requirements.txt` | Fijar versiones exactas de dependencias críticas (ej. `fastapi==0.110.0`) para evitar roturas por supply chain. |
| **S3-03** | Parseo de JSON del LLM | `server/app.py:4388-4405` | Mejorar `_extract_json_from_llm` o usar Pydantic para validar la salida estructurada del modelo. |
| **S3-04** | TOCTOU en `image_engine.py` | `server/image_engine.py:71-120` | Proteger lectura de `_pipeline` con lock. |
| **S3-05** | Regex débil en URLs frontend | `app/index.html` | Mejorar validación de URLs en creación de marca. |

---

## Estrategia de Pruebas

Para cada Sprint, se crearán/actualizarán tests en el directorio `tests/` para validar:
1. **Pruebas de Unidad:** Comprobar la lógica de validación de esquemas (Pydantic) y sanitización.
2. **Pruebas de Integración:** Verificar la correcta escritura/lectura bajo concurrencia simulada.
3. **Pruebas de Seguridad:** Confirmar que intentos de inyección (ej. SVG malicioso, IDOR) sean rechazados.

El trabajo comenzará inmediatamente con el **Sprint 1**.

# Plan de Reparación - CCS Brand Assistant

## Estado: ✅ COMPLETADO

Fecha: 2026-05-20

---

## Issues Corregidos

| # | Issue | Estado | Archivos Modificados |
|---|-------|--------|---------------------|
| 1 | Dashboard muestra 0 Marcas y 0 ADN | ✅ | `app/index.html` (loadDashboardStats sincroniza con backend, se llama después de crear marca) |
| 2 | Notificaciones repetidas al terminar proceso | ✅ | `app/index.html` (flag `notified` en pollBrandStatus y _pollCampaignProgress) |
| 3 | Sin límite de días en campañas | ✅ | `app/index.html` + `server/app.py` (validación frontend y backend: máx 30 días) |
| 4 | Skills son solo system prompts, no agentes reales | ✅ | `defaults/prompts/skills/*.md` (8 skills reales), `server/app.py` (log_reasoning, endpoint /api/reasoning, /api/skills) |
| 5 | Click en card campaña navega incorrectamente | ✅ | `app/index.html` (solo botón "Ver" navega, card no es clickeable) |
| 6 | Idiomas innecesarios (inglés, portugués) | ✅ | `app/index.html` (solo opción Español para Chile) |
| 7 | No se puede borrar una marca | ✅ | `app/index.html` (botón eliminar con confirmación, función deleteBrand) |
| 8 | Sin validación de URL en website | ✅ | `app/index.html` (regex de validación HTTP/HTTPS) |
| 9 | Backend bloqueante (no soporta concurrencia) | ✅ | `server/app.py` (ThreadPoolExecutor para todas las llamadas a call_ollama) |
| 10 | "Sin ADN todavía" después de entrevista | ✅ | `server/app.py` (crear estructura mínima de adn_draft si no existe en finish_interview) |
| 11 | Sin indicador de carga en chat | ✅ | `app/index.html` (typing indicator con animación durante respuesta del agente) |
| 12 | Botón "Aprobar ADN" no funciona después de v2.0 | ✅ | `app/index.html` + `server/app.py` (crear directorio adn_versions, actualizar state en frontend) |
| 13 | Campañas no filtran por fechas futuras | ✅ | `app/index.html` + `server/app.py` (validación de fecha inicio >= hoy) |
| 14 | "Ver calendario" y "Ver publicaciones" van a misma pantalla | ✅ | `app/index.html` (vista calendario vs vista lista de publicaciones con _renderPublicationsList) |
| 15 | Campañas no se pueden eliminar | ✅ | `app/index.html` + `server/app.py` (botón eliminar + endpoint DELETE /api/campaigns/{id}) |
| 16 | Fecha inicio puede ser posterior a fecha fin | ✅ | `app/index.html` + `server/app.py` (validación frontend y backend) |
| 17 | Sin indicador de progreso durante generación | ✅ | `app/index.html` (polling con barra de progreso %, reanuda al recargar via renderCampaigns) |
| 18 | Valores de última campaña quedan grabados al cambiar marca | ✅ | `app/index.html` (función _resetCampaignForm limpia formulario) |

---

## Detalle de Cambios

### Backend (`server/app.py`)

1. **ThreadPoolExecutor** (`_thread_pool`): Todas las llamadas a `call_ollama` ahora se ejecutan en un pool de threads (`loop.run_in_executor`) para no bloquear el event loop de FastAPI, permitiendo concurrencia real.
2. **Endpoint DELETE /api/campaigns/{campaign_id}**: Nuevo endpoint para eliminar campañas con limpieza de archivos.
3. **Validación de fechas en create_campaign**: Verifica inicio < fin, máximo 30 días, y fecha futura.
4. **fix finish_interview**: Crea estructura mínima de `adn_draft.json` si no existe antes de procesar.
5. **fix approve_adn**: Crea directorio `adn_versions` si no existe antes de contar versiones.
6. **log_reasoning()**: Nueva función para registrar pasos de razonamiento de agentes en logs.
7. **Endpoint GET /api/reasoning**: Expone el log de razonamiento para la UI.
8. **Endpoint GET /api/skills**: Lista todos los skills disponibles con su contenido.
9. **Startup**: Copia skills por defecto al directorio de datos (`prompts/skills/`).

### Frontend (`app/index.html`)

1. **Issue 1**: `loadDashboardStats` se llama después de crear marca para actualizar contadores.
2. **Issue 2**: Flags `notified` en polling para evitar notificaciones duplicadas.
3. **Issue 3**: Validación de máximo 30 días con mensaje claro al usuario.
4. **Issue 5**: Cards de campaña reciente no son clickeables, solo el botón "Ver".
5. **Issue 6**: Solo opción "Español" en selector de idioma (producto para Chile).
6. **Issue 7**: Botón eliminar marca con `confirm()` de confirmación.
7. **Issue 8**: Validación regex de URL (http/https obligatorio).
8. **Issue 11**: Typing indicator (animación de 3 puntos) durante respuesta del agente.
9. **Issue 13/16**: Validación de fechas futuras y inicio < fin en frontend.
10. **Issue 14**: Vista lista diferenciada para "Ver publicaciones" con `_renderPublicationsList`.
11. **Issue 15**: Botón eliminar campaña con confirmación.
12. **Issue 18**: `_resetCampaignForm` limpia formulario al crear campaña exitosamente.

### Skills (`defaults/prompts/skills/`)

Archivos `.md` creados con instrucciones reales y modificables:
- `web_scraping.md` - Extracción y análisis de contenido web
- `brand_analysis.md` - Análisis estructurado de identidad de marca
- `conversation.md` - Conversación guiada de descubrimiento
- `brand_discovery.md` - Descubrimiento profundo de marca
- `campaign_planning.md` - Planificación estratégica de campañas
- `content_strategy.md` - Estrategia de contenido multicanal
- `copywriting.md` - Redacción persuasiva para redes sociales
- `social_media.md` - Gestión y optimización de redes sociales

### Instalación (`install.json`)

- Agregado paso de copia de skills durante instalación (Windows y Linux/Mac).

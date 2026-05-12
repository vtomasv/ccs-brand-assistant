/**
 * CCS Brand Assistant — Configuración de Plugin Pinokio
 *
 * Menú dinámico según estado del plugin:
 *   - No instalado: botón de instalación
 *   - Instalado y corriendo: estado activo + botón abrir UI + detener
 *   - Instalado y detenido: botón iniciar
 *
 * Nota: La URL del servidor se captura dinámicamente en session.json
 * mediante self.set en start.json, siguiendo el patrón oficial de Pinokio.
 */
module.exports = {
  title: "CCS Brand Assistant",
  description: "Plataforma de ADN de marca y campañas digitales con IA local para PYMEs — Cámara de Comercio de Santiago",
  icon: "icon.png",

  menu: async (kernel, info) => {
    // Verificar si el plugin está instalado (venv creado)
    var installed = await kernel.exists(__dirname, "venv")

    if (!installed) {
      return [
        {
          default: true,
          icon: "fa-solid fa-download",
          text: "Instalar",
          href: "install.json",
        },
      ]
    }

    // Verificar si el servidor está corriendo
    var running = await kernel.script.running(__dirname, "start.json")

    if (running) {
      // Leer la URL capturada del servidor desde session.json
      var session = null
      try {
        session = await kernel.api.read(__dirname, "session.json")
      } catch(e) {
        session = null
      }
      var serverUrl = (session && session.url) ? session.url : null

      var menuItems = [
        {
          icon: "fa-solid fa-circle",
          text: "En ejecución",
          href: "start.json",
          style: "color: #3DAE2B",
        }
      ]

      // Solo mostrar "Abrir UI" si tenemos la URL del servidor
      if (serverUrl) {
        menuItems.push({
          icon: "fa-solid fa-arrow-up-right-from-square",
          text: "Abrir UI",
          href: serverUrl + "/ui/index.html",
        })
      }

      menuItems.push({
        icon: "fa-solid fa-stop",
        text: "Detener",
        href: "stop.json",
      })

      return menuItems
    }

    return [
      {
        default: true,
        icon: "fa-solid fa-play",
        text: "Iniciar",
        href: "start.json",
      },
      {
        icon: "fa-solid fa-trash",
        text: "Desinstalar",
        href: "reset.json",
      },
    ]
  },
}

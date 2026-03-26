# ============================================================
# pull_model.ps1 — Descarga el modelo de IA más adecuado
# según la RAM disponible del sistema.
# Compatible con entornos Pinokio (conda base).
# ============================================================

$ErrorActionPreference = "Continue"

Write-Host "=== Descargando modelo de IA ===" -ForegroundColor Cyan

# Función para encontrar el ejecutable de Ollama
function Find-Ollama {
    $cmd = Get-Command ollama -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $paths = @(
        "$env:LOCALAPPDATA\Programs\Ollama\ollama.exe",
        "$env:ProgramFiles\Ollama\ollama.exe",
        "C:\Ollama\ollama.exe",
        "$env:USERPROFILE\AppData\Local\Programs\Ollama\ollama.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

$ollamaExe = Find-Ollama

if (-not $ollamaExe) {
    Write-Host "AVISO: Ollama no disponible. Saltando descarga de modelo." -ForegroundColor Yellow
    Write-Host "Instala Ollama desde https://ollama.com/download y luego ejecuta 'ollama pull llama3.2:3b'" -ForegroundColor Yellow
    exit 0
}

# Verificar que Ollama está corriendo
$ollamaRunning = $false
try {
    $r = Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -TimeoutSec 5 -UseBasicParsing -ErrorAction SilentlyContinue
    if ($r.StatusCode -eq 200) { $ollamaRunning = $true }
} catch { }

if (-not $ollamaRunning) {
    Write-Host "AVISO: Ollama no esta corriendo. Saltando descarga de modelo." -ForegroundColor Yellow
    exit 0
}

# Detectar RAM total del sistema
$ramGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
Write-Host "RAM detectada: ${ramGB}GB" -ForegroundColor Cyan

# Seleccionar modelo según RAM disponible
if ($ramGB -lt 6) {
    $model = "llama3.2:1b"
    Write-Host "RAM < 6GB: usando modelo ligero $model" -ForegroundColor Yellow
} elseif ($ramGB -lt 12) {
    $model = "llama3.2:3b"
    Write-Host "RAM 6-12GB: usando modelo mediano $model" -ForegroundColor Green
} else {
    $model = "llama3.1:8b"
    Write-Host "RAM >= 12GB: usando modelo completo $model" -ForegroundColor Green
}

# Verificar si el modelo ya está descargado
Write-Host "Verificando si $model ya esta descargado..."
try {
    $tagsJson = Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -TimeoutSec 5 -UseBasicParsing
    $tags = ($tagsJson.Content | ConvertFrom-Json).models
    $modelExists = $tags | Where-Object { $_.name -like "$model*" }

    if ($modelExists) {
        Write-Host "OK: Modelo $model ya esta disponible localmente." -ForegroundColor Green
        exit 0
    }
} catch {
    Write-Host "No se pudo verificar modelos existentes. Intentando descarga de todas formas..."
}

# Descargar el modelo
Write-Host "Descargando $model (puede tardar varios minutos segun tu conexion)..." -ForegroundColor Yellow
Write-Host "Este proceso es necesario solo la primera vez." -ForegroundColor Cyan

try {
    & $ollamaExe pull $model
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK: Modelo $model descargado correctamente." -ForegroundColor Green
    } else {
        Write-Host "AVISO: La descarga del modelo puede haber fallado (codigo $LASTEXITCODE)." -ForegroundColor Yellow
        Write-Host "Puedes descargarlo manualmente con: ollama pull $model" -ForegroundColor Yellow
    }
} catch {
    Write-Host "ERROR al descargar modelo: $_" -ForegroundColor Red
    Write-Host "Ejecuta manualmente: ollama pull $model" -ForegroundColor Yellow
}

exit 0

# ============================================================
# setup_venv.ps1 — Crea el entorno virtual Python e instala
# las dependencias del proyecto.
# Compatible con entornos Pinokio (conda base).
# ============================================================

$ErrorActionPreference = "Stop"

Write-Host "=== Configurando entorno Python ===" -ForegroundColor Cyan

# Directorio de trabajo (donde está el script de Pinokio)
$projectDir = $PSScriptRoot | Split-Path -Parent
Set-Location $projectDir
Write-Host "Directorio del proyecto: $projectDir"

# ── Encontrar Python ──────────────────────────────────────────────────────────
function Find-Python {
    # 1. python en PATH
    $py = Get-Command python -ErrorAction SilentlyContinue
    if ($py) {
        $ver = & python --version 2>&1
        Write-Host "Python encontrado en PATH: $($py.Source) ($ver)"
        return "python"
    }
    # 2. python3 en PATH
    $py3 = Get-Command python3 -ErrorAction SilentlyContinue
    if ($py3) {
        $ver = & python3 --version 2>&1
        Write-Host "Python3 encontrado: $($py3.Source) ($ver)"
        return "python3"
    }
    # 3. Rutas comunes de conda/Python en Windows
    $paths = @(
        "$env:USERPROFILE\miniconda3\python.exe",
        "$env:USERPROFILE\anaconda3\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python311\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python310\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe",
        "C:\Python311\python.exe",
        "C:\Python310\python.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) {
            $ver = & $p --version 2>&1
            Write-Host "Python encontrado en: $p ($ver)"
            return $p
        }
    }
    return $null
}

$pythonCmd = Find-Python

if (-not $pythonCmd) {
    Write-Host "ERROR: No se encontro Python. Instala Python 3.10+ desde https://python.org" -ForegroundColor Red
    exit 1
}

# ── Crear entorno virtual ─────────────────────────────────────────────────────
$venvDir = Join-Path $projectDir "venv"

if (Test-Path (Join-Path $venvDir "Scripts\python.exe")) {
    Write-Host "OK: Entorno virtual ya existe en: $venvDir" -ForegroundColor Green
} else {
    Write-Host "Creando entorno virtual en: $venvDir"
    & $pythonCmd -m venv $venvDir
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: No se pudo crear el entorno virtual." -ForegroundColor Red
        exit 1
    }
    Write-Host "OK: Entorno virtual creado." -ForegroundColor Green
}

# ── Rutas del venv ────────────────────────────────────────────────────────────
$venvPython = Join-Path $venvDir "Scripts\python.exe"
$venvPip    = Join-Path $venvDir "Scripts\pip.exe"

# ── Actualizar pip ────────────────────────────────────────────────────────────
Write-Host "Actualizando pip..."
& $venvPython -m pip install --upgrade pip --quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "AVISO: No se pudo actualizar pip. Continuando..." -ForegroundColor Yellow
}

# ── Instalar dependencias ─────────────────────────────────────────────────────
$reqFile = Join-Path $projectDir "requirements.txt"

if (-not (Test-Path $reqFile)) {
    Write-Host "ERROR: No se encontro requirements.txt en $reqFile" -ForegroundColor Red
    exit 1
}

Write-Host "Instalando dependencias desde requirements.txt..."
& $venvPython -m pip install -r $reqFile --quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Fallo la instalacion de dependencias." -ForegroundColor Red
    exit 1
}

Write-Host "DEPS_OK" -ForegroundColor Green
Write-Host "=== Entorno Python configurado correctamente ===" -ForegroundColor Green
exit 0

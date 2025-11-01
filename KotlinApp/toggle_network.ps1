# Script para activar/desactivar WiFi y datos móviles en el emulador
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("enable", "disable", "status")]
    [string]$Action = "status"
)

$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"

if (-not (Test-Path $adbPath)) {
    Write-Host "ERROR: ADB no encontrado en $adbPath" -ForegroundColor Red
    Write-Host "Verifica que Android SDK esté instalado" -ForegroundColor Yellow
    exit 1
}

## Acciones inline (evita problemas de alcance de funciones en algunos entornos)

switch ($Action) {
    "enable" {
        Write-Host "Activando WiFi y datos móviles..." -ForegroundColor Green
        & $adbPath shell "svc wifi enable"
        & $adbPath shell "svc data enable"
        # Fallback WiFi
        & $adbPath shell "settings put global wifi_on 1" | Out-Null
        & $adbPath shell "cmd -w wifi set-wifi-enabled enabled" | Out-Null
        # Desactivar modo avión por si estaba activo
        & $adbPath shell "settings put global airplane_mode_on 0" | Out-Null
        & $adbPath shell "am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false" | Out-Null
        Write-Host "✓ WiFi y datos activados" -ForegroundColor Green
    }
    "disable" {
        Write-Host "Desactivando WiFi y datos móviles..." -ForegroundColor Yellow
        & $adbPath shell "svc wifi disable"
        & $adbPath shell "svc data disable"
        # Fallbacks
        & $adbPath shell "settings put global wifi_on 0" | Out-Null
        & $adbPath shell "cmd -w wifi set-wifi-enabled disabled" | Out-Null
        # Último recurso: modo avión
        & $adbPath shell "cmd connectivity airplane-mode enable" | Out-Null
        & $adbPath shell "settings put global airplane_mode_on 1" | Out-Null
        & $adbPath shell "am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true" | Out-Null
        Write-Host "✓ WiFi/datos desactivados (con fallbacks)" -ForegroundColor Yellow
    }
    "status" {
        Write-Host "Verificando estado de conexión..." -ForegroundColor Cyan
        Write-Host "`nWiFi (dumpsys wifi | head -5):" -ForegroundColor Cyan
        & $adbPath shell "sh -c 'dumpsys wifi | head -5'"
        Write-Host "`nConectividad (dumpsys connectivity | head -10):" -ForegroundColor Cyan
        & $adbPath shell "sh -c 'dumpsys connectivity | head -10'"
        Write-Host "`nModo avión:" -ForegroundColor Cyan
        & $adbPath shell "settings get global airplane_mode_on"
    }
}


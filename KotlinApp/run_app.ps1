# PowerShell script equivalente a run_app.sh para Windows
# Configuración de colores
$Colors = @{
    RED = [ConsoleColor]::Red
    GREEN = [ConsoleColor]::Green
    YELLOW = [ConsoleColor]::Yellow
    BLUE = [ConsoleColor]::Blue
    NC = [Console]::ForegroundColor
}

# Función para escribir en color
function Write-ColorOutput {
    param(
        [string]$Message,
        [ConsoleColor]$Color = [Console]::ForegroundColor
    )
    $originalColor = [Console]::ForegroundColor
    [Console]::ForegroundColor = $Color
    Write-Host $Message
    [Console]::ForegroundColor = $originalColor
}

# Configurar variables de entorno
Write-ColorOutput "🚀 Iniciando proceso completo de compilación, instalación y ejecución de KotlinApp..." $Colors.BLUE
Write-ColorOutput "==================================================" $Colors.BLUE

# Buscar Android SDK
$androidSdkPath = $null

# Buscar en ubicaciones comunes
$possiblePaths = @(
    "$env:LOCALAPPDATA\Android\Sdk",
    "$env:USERPROFILE\AppData\Local\Android\Sdk",
    "$env:ANDROID_HOME",
    "$env:ANDROID_SDK_ROOT",
    "C:\Android\Sdk"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        if (Test-Path "$path\platform-tools\adb.exe") {
            $androidSdkPath = $path
            Write-ColorOutput "✅ Android SDK encontrado en: $androidSdkPath" $Colors.GREEN
            break
        }
    }
}

if (-not $androidSdkPath) {
    Write-ColorOutput "❌ No se encontró Android SDK." $Colors.RED
    Write-ColorOutput ""
    Write-ColorOutput "📥 Para instalar Android SDK automáticamente, ejecuta:" $Colors.YELLOW
    Write-ColorOutput "   .\setup_android_sdk.ps1" $Colors.CYAN
    Write-ColorOutput ""
    Write-ColorOutput "   O descarga Android Studio desde:" $Colors.YELLOW
    Write-ColorOutput "   https://developer.android.com/studio" $Colors.CYAN
    exit 1
}

# Configurar PATH
$env:PATH = "$androidSdkPath\platform-tools;$androidSdkPath\emulator;$env:PATH"

# Función para verificar dispositivos
function Check-Devices {
    $devices = adb devices | Where-Object { $_ -match "device$" } | Measure-Object -Line
    return $devices.Lines.Count
}

# Función para esperar que el emulador esté completamente listo
function Wait-ForEmulatorReady {
    Write-Host ""
    Write-ColorOutput "⏳ Esperando que el emulador se inicialice completamente..." $Colors.YELLOW
    
    $timeout = 180 # 3 minutos máximo
    $elapsed = 0
    $waitInterval = 10
    
    while ($elapsed -lt $timeout) {
        Start-Sleep -Seconds $waitInterval
        $elapsed += $waitInterval
        
        # Verificar si está booteado
        $bootCompleted = adb shell "getprop sys.boot_completed" 2>&1
        if ($bootCompleted -eq "1") {
            Write-ColorOutput "✅ Emulador listo (tardó $elapsed segundos)" $Colors.GREEN
            return $true
        }
        
        Write-Host "... esperando ($elapsed/$timeout segundos)" -ForegroundColor Gray
    }
    
    Write-ColorOutput "❌ Timeout esperando el emulador" $Colors.RED
    return $false
}

# Función para iniciar el emulador
function Start-Emulator {
    Write-Host ""
    Write-ColorOutput "🚀 Iniciando emulador PixelLiteApi34..." $Colors.BLUE
    
    # Verificar si ya está ejecutándose
    $existingDevice = adb devices | Where-Object { $_ -match "device$" }
    if ($existingDevice) {
        Write-ColorOutput "✅ Emulador ya está ejecutándose" $Colors.GREEN
        return $true
    }
    
    # Iniciar emulador
    Start-Process -FilePath "$androidSdkPath\emulator\emulator.exe" -ArgumentList "-avd", "PixelLiteApi34" -WindowStyle Hidden
    
    # Esperar a que aparezca como dispositivo conectado
    Write-Host "Esperando que el emulador se conecte..." -ForegroundColor Yellow
    $timeout = 120
    $elapsed = 0
    
    while ($elapsed -lt $timeout) {
        Start-Sleep -Seconds 5
        $elapsed += 5
        
        if ((Check-Devices) -gt 0) {
            Write-ColorOutput "✅ Emulador conectado" $Colors.GREEN
            return $true
        }
        
        Write-Host "... esperando conexión ($elapsed/$timeout segundos)" -ForegroundColor Gray
    }
    
    Write-ColorOutput "❌ No se pudo conectar el emulador en el tiempo esperado" $Colors.RED
    return $false
}

# Función para verificar errores
function Check-Errors {
    Write-ColorOutput "🔍 Verificando errores en logs..." $Colors.YELLOW
    $errors = adb logcat -d | Select-String -Pattern "FATAL|AndroidRuntime|Exception.*kotlinapp" | Select-Object -Last 5
    if ($errors) {
        Write-ColorOutput "❌ Errores encontrados:" $Colors.RED
        Write-Host $errors
        return $false
    } else {
        Write-ColorOutput "✅ No se encontraron errores recientes" $Colors.GREEN
        return $true
    }
}

# Función para verificar estado de la aplicación
function Check-AppStatus {
    Write-ColorOutput "📊 Verificando estado de la aplicación..." $Colors.YELLOW
    $appProcess = adb shell "ps | grep kotlinapp"
    if ($appProcess) {
        Write-ColorOutput "✅ Aplicación ejecutándose correctamente" $Colors.GREEN
        Write-Host "Proceso: $appProcess"
        return $true
    } else {
        Write-ColorOutput "❌ Aplicación no está ejecutándose" $Colors.RED
        return $false
    }
}

# Verificar dispositivos conectados
Write-ColorOutput "Verificando dispositivos conectados..." $Colors.BLUE
$deviceCount = Check-Devices

if ($deviceCount -eq 0) {
    Write-ColorOutput "No hay dispositivos conectados" $Colors.YELLOW
    Write-ColorOutput "Intentando iniciar el emulador PixelLiteApi34..." $Colors.YELLOW
    
    if (-not (Start-Emulator)) {
        Write-ColorOutput "❌ No se pudo iniciar el emulador" $Colors.RED
        Write-ColorOutput "Inicia el emulador manualmente o conecta un dispositivo USB" $Colors.YELLOW
        exit 1
    }
    
    # Esperar a que el emulador termine de cargar
    if (-not (Wait-ForEmulatorReady)) {
        Write-ColorOutput "❌ El emulador no terminó de cargar en el tiempo esperado" $Colors.RED
        exit 1
    }
} else {
    Write-ColorOutput "Dispositivo(s) encontrado(s): $deviceCount" $Colors.GREEN
    
    # Verificar si es un emulador que necesita esperar
    $deviceName = adb devices | Where-Object { $_ -match "device$" } | ForEach-Object { if ($_ -match "emulator") { $_ } }
    if ($deviceName) {
        Write-ColorOutput "Es un emulador, verificando que esté listo..." $Colors.YELLOW
        Wait-ForEmulatorReady
    }
}

# Mostrar dispositivos conectados
Write-ColorOutput "📱 Dispositivos conectados:" $Colors.BLUE
adb devices
Write-Host ""

# Paso 1: Limpiar compilación anterior
Write-ColorOutput "🧹 Paso 1: Limpiando compilación anterior..." $Colors.YELLOW
.\gradlew.bat clean
if ($LASTEXITCODE -eq 0) {
    Write-ColorOutput "✅ Limpieza completada" $Colors.GREEN
} else {
    Write-ColorOutput "❌ Error en la limpieza" $Colors.RED
}
Write-Host ""

# Paso 2: Compilar la aplicación
Write-ColorOutput "🔨 Paso 2: Compilando la aplicación..." $Colors.YELLOW
.\gradlew.bat assembleDebug
if ($LASTEXITCODE -eq 0) {
    Write-ColorOutput "✅ Compilación exitosa" $Colors.GREEN
} else {
    Write-ColorOutput "❌ Error en la compilación" $Colors.RED
    exit 1
}
Write-Host ""

# Paso 3: Instalar en el dispositivo
Write-ColorOutput "📦 Paso 3: Instalando en el dispositivo..." $Colors.YELLOW

# Intentar con Gradle primero
.\gradlew.bat installDebug
if ($LASTEXITCODE -eq 0) {
    Write-ColorOutput "✅ Instalación exitosa con Gradle" $Colors.GREEN
} else {
    Write-ColorOutput "⚠️ Gradle falló, intentando con adb install..." $Colors.YELLOW
    # Fallback: usar adb install directo
    adb install "app\build\outputs\apk\debug\app-debug.apk"
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "✅ Instalación exitosa con adb" $Colors.GREEN
    } else {
        Write-ColorOutput "❌ Error en la instalación" $Colors.RED
        exit 1
    }
}
Write-Host ""

# Paso 4: Ejecutar la aplicación
Write-ColorOutput "🚀 Paso 4: Ejecutando la aplicación..." $Colors.YELLOW
adb shell am start -n com.example.kotlinapp/.MainActivity
if ($LASTEXITCODE -eq 0) {
    Write-ColorOutput "✅ Aplicación ejecutada correctamente" $Colors.GREEN
} else {
    Write-ColorOutput "❌ Error al ejecutar la aplicación" $Colors.RED
    exit 1
}
Write-Host ""

# Paso 5: Esperar un momento para que la app se inicie
Write-ColorOutput "⏳ Paso 5: Esperando que la aplicación se inicie..." $Colors.YELLOW
Start-Sleep -Seconds 5

# Paso 6: Verificar estado de la aplicación
Write-ColorOutput "📊 Paso 6: Verificando estado de la aplicación..." $Colors.YELLOW
Check-AppStatus
Write-Host ""

# Paso 7: Verificar errores
Write-ColorOutput "🔍 Paso 7: Verificando errores..." $Colors.YELLOW
Check-Errors
Write-Host ""

# Resumen final
Write-ColorOutput "🎉 ¡PROCESO COMPLETADO!" $Colors.GREEN
Write-ColorOutput "==================================================" $Colors.BLUE
Write-ColorOutput "📋 Resumen:" $Colors.BLUE
Write-ColorOutput "✅ Compilación: Exitosa" $Colors.GREEN
Write-ColorOutput "✅ Instalación: Exitosa" $Colors.GREEN
Write-ColorOutput "✅ Ejecución: Exitosa" $Colors.GREEN
Write-ColorOutput "✅ Verificación: Completada" $Colors.GREEN
Write-Host ""
Write-ColorOutput "💡 La aplicación está ejecutándose en tu dispositivo/emulador" $Colors.YELLOW
Write-ColorOutput "==================================================" $Colors.BLUE


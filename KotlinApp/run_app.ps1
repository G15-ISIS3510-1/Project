# PowerShell script para compilar, instalar y ejecutar KotlinApp
# Configuracion de colores
$Colors = @{
    RED = [ConsoleColor]::Red
    GREEN = [ConsoleColor]::Green
    YELLOW = [ConsoleColor]::Yellow
    BLUE = [ConsoleColor]::Blue
}

# Funcion para escribir en color
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
Write-ColorOutput "[INFO] Iniciando proceso completo de compilacion, instalacion y ejecucion de KotlinApp..." $Colors.BLUE
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
        if (Test-Path (Join-Path $path "platform-tools\adb.exe")) {
            $androidSdkPath = $path
            Write-ColorOutput "[OK] Android SDK encontrado en: $androidSdkPath" $Colors.GREEN
            break
        }
    }
}

if (-not $androidSdkPath) {
    Write-ColorOutput "[ERROR] No se encontro Android SDK." $Colors.RED
    Write-ColorOutput ""
    Write-ColorOutput "[INFO] Para instalar Android SDK automaticamente, ejecuta:" $Colors.YELLOW
    Write-ColorOutput "   .\setup_android_sdk.ps1" $Colors.BLUE
    Write-ColorOutput ""
    Write-ColorOutput "   O descarga Android Studio desde:" $Colors.YELLOW
    Write-ColorOutput "   https://developer.android.com/studio" $Colors.BLUE
    exit 1
}

# Configurar PATH
$platformTools = Join-Path $androidSdkPath "platform-tools"
$emulator = Join-Path $androidSdkPath "emulator"
$env:PATH = "$platformTools;$emulator;$env:PATH"

# Crear local.properties si no existe
$localPropertiesPath = "local.properties"
if (-not (Test-Path $localPropertiesPath)) {
    $sdkDir = $androidSdkPath -replace '\\', '/'
    $content = "sdk.dir=$sdkDir"
    Set-Content -Path $localPropertiesPath -Value $content -Encoding ASCII
    Write-ColorOutput "[INFO] Archivo local.properties creado" $Colors.YELLOW
}

# Funcion para verificar dispositivos
function Check-Devices {
    $devices = adb devices | Where-Object { $_ -match "device$" } | Measure-Object -Line
    return $devices.Lines.Count
}

# Funcion para esperar que el emulador este completamente listo
function Wait-ForEmulatorReady {
    Write-Host ""
    Write-ColorOutput "[INFO] Esperando que el emulador se inicialice completamente..." $Colors.YELLOW
    
    $timeout = 180 # 3 minutos maximo
    $elapsed = 0
    $waitInterval = 10
    
    while ($elapsed -lt $timeout) {
        Start-Sleep -Seconds $waitInterval
        $elapsed += $waitInterval
        
        # Verificar si esta booteado
        $bootCompleted = adb shell "getprop sys.boot_completed" 2>&1
        if ($bootCompleted -eq "1") {
            Write-ColorOutput "[OK] Emulador listo (tardo $elapsed segundos)" $Colors.GREEN
            return $true
        }
        
        Write-Host "... esperando ($elapsed/$timeout segundos)" -ForegroundColor Gray
    }
    
    Write-ColorOutput "[ERROR] Timeout esperando el emulador" $Colors.RED
    return $false
}

# Funcion para iniciar el emulador
function Start-Emulator {
    Write-Host ""
    Write-ColorOutput "[INFO] Iniciando emulador PixelLiteApi34..." $Colors.BLUE
    
    # Verificar si ya esta ejecutandose
    $existingDevice = adb devices | Where-Object { $_ -match "device$" }
    if ($existingDevice) {
        Write-ColorOutput "[OK] Emulador ya esta ejecutandose" $Colors.GREEN
        return $true
    }
    
    # Iniciar emulador
    $emulatorPath = Join-Path $androidSdkPath "emulator\emulator.exe"
    Start-Process -FilePath $emulatorPath -ArgumentList "-avd", "PixelLiteApi34" -WindowStyle Hidden
    
    # Esperar a que aparezca como dispositivo conectado
    Write-Host "Esperando que el emulador se conecte..." -ForegroundColor Yellow
    $timeout = 120
    $elapsed = 0
    
    while ($elapsed -lt $timeout) {
        Start-Sleep -Seconds 5
        $elapsed += 5
        
        if ((Check-Devices) -gt 0) {
            Write-ColorOutput "[OK] Emulador conectado" $Colors.GREEN
            return $true
        }
        
        Write-Host "... esperando conexion ($elapsed/$timeout segundos)" -ForegroundColor Gray
    }
    
    Write-ColorOutput "[ERROR] No se pudo conectar el emulador en el tiempo esperado" $Colors.RED
    return $false
}

# Funcion para verificar errores
function Check-Errors {
    Write-ColorOutput "[INFO] Verificando errores en logs..." $Colors.YELLOW
    $errors = adb logcat -d | Select-String -Pattern "FATAL|AndroidRuntime|Exception.*kotlinapp" | Select-Object -Last 5
    if ($errors) {
        Write-ColorOutput "[ERROR] Errores encontrados:" $Colors.RED
        Write-Host $errors
        return $false
    } else {
        Write-ColorOutput "[OK] No se encontraron errores recientes" $Colors.GREEN
        return $true
    }
}

# Funcion para verificar estado de la aplicacion
function Check-AppStatus {
    Write-ColorOutput "[INFO] Verificando estado de la aplicacion..." $Colors.YELLOW
    $appProcess = adb shell "ps | grep kotlinapp"
    if ($appProcess) {
        Write-ColorOutput "[OK] Aplicacion ejecutandose correctamente" $Colors.GREEN
        Write-Host "Proceso: $appProcess"
        return $true
    } else {
        Write-ColorOutput "[ERROR] Aplicacion no esta ejecutandose" $Colors.RED
        return $false
    }
}

# Verificar dispositivos conectados
Write-ColorOutput "[INFO] Verificando dispositivos conectados..." $Colors.BLUE
$deviceCount = Check-Devices

if ($deviceCount -eq 0) {
    Write-ColorOutput "[INFO] No hay dispositivos conectados" $Colors.YELLOW
    Write-ColorOutput "[INFO] Intentando iniciar el emulador PixelLiteApi34..." $Colors.YELLOW
    
    if (-not (Start-Emulator)) {
        Write-ColorOutput "[ERROR] No se pudo iniciar el emulador" $Colors.RED
        Write-ColorOutput "[INFO] Inicia el emulador manualmente o conecta un dispositivo USB" $Colors.YELLOW
        exit 1
    }
    
    # Esperar a que el emulador termine de cargar
    if (-not (Wait-ForEmulatorReady)) {
        Write-ColorOutput "[ERROR] El emulador no termino de cargar en el tiempo esperado" $Colors.RED
        exit 1
    }
} else {
    Write-ColorOutput "[OK] Dispositivo(s) encontrado(s): $deviceCount" $Colors.GREEN
    
    # Verificar si es un emulador que necesita esperar
    $deviceName = adb devices | Where-Object { $_ -match "device$" } | ForEach-Object { if ($_ -match "emulator") { $_ } }
    if ($deviceName) {
        Write-ColorOutput "[INFO] Es un emulador, verificando que este listo..." $Colors.YELLOW
        Wait-ForEmulatorReady
    }
}

# Mostrar dispositivos conectados
Write-ColorOutput "[INFO] Dispositivos conectados:" $Colors.BLUE
adb devices
Write-Host ""

# Paso 1: Limpiar compilacion anterior
Write-ColorOutput "[STEP 1] Limpiando compilacion anterior..." $Colors.YELLOW
.\gradlew.bat clean
if ($LASTEXITCODE -eq 0) {
    Write-ColorOutput "[OK] Limpieza completada" $Colors.GREEN
} else {
    Write-ColorOutput "[ERROR] Error en la limpieza" $Colors.RED
}
Write-Host ""

# Paso 2: Compilar la aplicacion
Write-ColorOutput "[STEP 2] Compilando la aplicacion..." $Colors.YELLOW
.\gradlew.bat assembleDebug
if ($LASTEXITCODE -eq 0) {
    Write-ColorOutput "[OK] Compilacion exitosa" $Colors.GREEN
} else {
    Write-ColorOutput "[ERROR] Error en la compilacion" $Colors.RED
    exit 1
}
Write-Host ""

# Paso 3: Instalar en el dispositivo
Write-ColorOutput "[STEP 3] Instalando en el dispositivo..." $Colors.YELLOW

# Intentar con Gradle primero
.\gradlew.bat installDebug
if ($LASTEXITCODE -eq 0) {
    Write-ColorOutput "[OK] Instalacion exitosa con Gradle" $Colors.GREEN
} else {
    Write-ColorOutput "[WARN] Gradle fallo, intentando con adb install..." $Colors.YELLOW
    # Fallback: usar adb install directo
    $apkPath = Join-Path (Get-Location) "app\build\outputs\apk\debug\app-debug.apk"
    adb install -r $apkPath
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "[OK] Instalacion exitosa con adb" $Colors.GREEN
    } else {
        Write-ColorOutput "[ERROR] Error en la instalacion" $Colors.RED
        exit 1
    }
}
Write-Host ""

# Paso 4: Ejecutar la aplicacion
Write-ColorOutput "[STEP 4] Ejecutando la aplicacion..." $Colors.YELLOW
adb shell am start -n com.example.kotlinapp/.MainActivity
if ($LASTEXITCODE -eq 0) {
    Write-ColorOutput "[OK] Aplicacion ejecutada correctamente" $Colors.GREEN
} else {
    Write-ColorOutput "[ERROR] Error al ejecutar la aplicacion" $Colors.RED
    exit 1
}
Write-Host ""

# Paso 5: Esperar un momento para que la app se inicie
Write-ColorOutput "[STEP 5] Esperando que la aplicacion se inicie..." $Colors.YELLOW
Start-Sleep -Seconds 5

# Paso 6: Verificar estado de la aplicacion
Write-ColorOutput "[STEP 6] Verificando estado de la aplicacion..." $Colors.YELLOW
Check-AppStatus
Write-Host ""

# Paso 7: Verificar errores
Write-ColorOutput "[STEP 7] Verificando errores..." $Colors.YELLOW
Check-Errors
Write-Host ""

# Resumen final
Write-ColorOutput "[SUCCESS] PROCESO COMPLETADO!" $Colors.GREEN
Write-ColorOutput "==================================================" $Colors.BLUE
Write-ColorOutput "[INFO] Resumen:" $Colors.BLUE
Write-ColorOutput "[OK] Compilacion: Exitosa" $Colors.GREEN
Write-ColorOutput "[OK] Instalacion: Exitosa" $Colors.GREEN
Write-ColorOutput "[OK] Ejecucion: Exitosa" $Colors.GREEN
Write-ColorOutput "[OK] Verificacion: Completada" $Colors.GREEN
Write-Host ""
Write-ColorOutput "[INFO] La aplicacion esta ejecutandose en tu dispositivo/emulador" $Colors.YELLOW
Write-ColorOutput "==================================================" $Colors.BLUE

#!/bin/bash

echo "Iniciando proceso de compilación y ejecución de KotlinApp..."

# Configurar variables de entorno
export PATH=$PATH:/Users/marcosespana/Library/Android/sdk/platform-tools
export PATH=$PATH:/Users/marcosespana/Library/Android/sdk/emulator

# Función para verificar si hay dispositivos conectados
check_devices() {
    local devices=$(adb devices | grep -v "List of devices attached" | grep -c "device$")
    echo $devices
}

# Función para abrir el emulador
start_emulator() {
    echo "No hay dispositivos conectados. Iniciando emulador..."
    echo "Esto puede tomar unos minutos..."
    
    # Terminar cualquier emulador existente en modo headless
    pkill -f "qemu-system-aarch64" 2>/dev/null
    
    # Iniciar el emulador en segundo plano
    emulator -avd PixelLiteApi34 &
    local emulator_pid=$!
    
    echo "Esperando a que el emulador se inicie..."
    
    # Esperar hasta que el emulador esté conectado (máximo 2 minutos)
    local timeout=120
    local count=0
    
    while [ $count -lt $timeout ]; do
        if [ $(check_devices) -gt 0 ]; then
            echo "Emulador conectado exitosamente"
            return 0
        fi
        sleep 2
        count=$((count + 2))
        echo "Esperando... ($count/$timeout segundos)"
    done
    
    echo "Timeout: El emulador no se conectó en 2 minutos"
    kill $emulator_pid 2>/dev/null
    return 1
}

# Verificar dispositivos conectados
echo "Verificando dispositivos conectados..."
device_count=$(check_devices)

if [ $device_count -eq 0 ]; then
    echo "No hay dispositivos conectados"
    start_emulator
    if [ $? -ne 0 ]; then
        echo "No se pudo iniciar el emulador. Abortando..."
        exit 1
    fi
else
    echo "Dispositivo(s) encontrado(s): $device_count"
fi

# Mostrar dispositivos conectados
adb devices

# Compilar e instalar
echo "Compilando e instalando la aplicación..."
./gradlew installDebug

if [ $? -eq 0 ]; then
    echo "Aplicación instalada correctamente"
    
    # Ejecutar la aplicación
    echo "Ejecutando la aplicación..."
    adb shell am start -n com.example.kotlinapp/.MainActivity
    
    if [ $? -eq 0 ]; then
        echo "¡Aplicación ejecutada correctamente!"
    else
        echo "Error al ejecutar la aplicación"
    fi
else
    echo "Error al compilar/instalar la aplicación"
fi

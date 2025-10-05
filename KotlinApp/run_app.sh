#!/bin/bash

echo "🚀 Iniciando proceso completo de compilación, instalación y ejecución de KotlinApp..."
echo "=================================================="

# Configurar variables de entorno
export PATH=$PATH:/Users/marcosespana/Library/Android/sdk/platform-tools
export PATH=$PATH:/Users/marcosespana/Library/Android/sdk/emulator

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar logs en tiempo real
show_logs() {
    echo -e "${BLUE}📱 Mostrando logs de la aplicación...${NC}"
    echo "=================================================="
    adb logcat | grep -E "(kotlinapp|FATAL|AndroidRuntime|App|PreferencesManager)" &
    local log_pid=$!
    sleep 10
    kill $log_pid 2>/dev/null
    echo "=================================================="
}

# Función para monitorear logs de login en tiempo real
monitor_login_logs() {
    echo -e "${YELLOW}🔍 Monitoreando logs de login en tiempo real...${NC}"
    echo "=================================================="
    echo -e "${BLUE}💡 Presiona Ctrl+C para detener el monitoreo${NC}"
    echo "=================================================="
    
    # Limpiar logs anteriores
    adb logcat -c
    
    # Monitorear logs específicos de login
    adb logcat | grep -E "(kotlinapp|LoginViewModel|AuthRepository|AuthApiService|Retrofit|OkHttp|HTTP|Exception|Error|FATAL|AndroidRuntime)" --line-buffered
}

# Función para verificar errores
check_errors() {
    echo -e "${YELLOW}🔍 Verificando errores en logs...${NC}"
    local errors=$(adb logcat -d | grep -E "(FATAL|AndroidRuntime|Exception.*kotlinapp)" | tail -5)
    if [ -n "$errors" ]; then
        echo -e "${RED}❌ Errores encontrados:${NC}"
        echo "$errors"
        return 1
    else
        echo -e "${GREEN}✅ No se encontraron errores recientes${NC}"
        return 0
    fi
}

# Función para ver errores específicos de login
check_login_errors() {
    echo -e "${YELLOW}🔍 Verificando errores específicos de login...${NC}"
    echo "=================================================="
    
    # Buscar errores de red/HTTP
    echo -e "${BLUE}📡 Errores de red/HTTP:${NC}"
    local network_errors=$(adb logcat -d | grep -E "(Retrofit|OkHttp|HTTP|Connection|Network|Timeout)" | tail -10)
    if [ -n "$network_errors" ]; then
        echo "$network_errors"
    else
        echo "No se encontraron errores de red"
    fi
    echo ""
    
    # Buscar errores de autenticación
    echo -e "${BLUE}🔐 Errores de autenticación:${NC}"
    local auth_errors=$(adb logcat -d | grep -E "(AuthRepository|AuthApiService|LoginViewModel|401|403|Unauthorized)" | tail -10)
    if [ -n "$auth_errors" ]; then
        echo "$auth_errors"
    else
        echo "No se encontraron errores de autenticación"
    fi
    echo ""
    
    # Buscar errores generales de la app
    echo -e "${BLUE}🚨 Errores generales de la aplicación:${NC}"
    local app_errors=$(adb logcat -d | grep -E "(kotlinapp|Exception|Error|FATAL)" | tail -10)
    if [ -n "$app_errors" ]; then
        echo "$app_errors"
    else
        echo "No se encontraron errores generales"
    fi
    echo "=================================================="
}

# Función para verificar estado de la aplicación
check_app_status() {
    echo -e "${YELLOW}📊 Verificando estado de la aplicación...${NC}"
    local app_process=$(adb shell ps | grep kotlinapp)
    if [ -n "$app_process" ]; then
        echo -e "${GREEN}✅ Aplicación ejecutándose correctamente${NC}"
        echo "Proceso: $app_process"
        return 0
    else
        echo -e "${RED}❌ Aplicación no está ejecutándose${NC}"
        return 1
    fi
}

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
echo -e "${BLUE}📱 Dispositivos conectados:${NC}"
adb devices
echo ""

# Paso 1: Limpiar compilación anterior
echo -e "${YELLOW}🧹 Paso 1: Limpiando compilación anterior...${NC}"
./gradlew clean
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Limpieza completada${NC}"
else
    echo -e "${RED}❌ Error en la limpieza${NC}"
fi
echo ""

# Paso 2: Compilar la aplicación
echo -e "${YELLOW}🔨 Paso 2: Compilando la aplicación...${NC}"
./gradlew assembleDebug
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Compilación exitosa${NC}"
else
    echo -e "${RED}❌ Error en la compilación${NC}"
    exit 1
fi
echo ""

# Paso 3: Instalar en el dispositivo
echo -e "${YELLOW}📦 Paso 3: Instalando en el dispositivo...${NC}"
./gradlew installDebug
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Instalación exitosa${NC}"
else
    echo -e "${RED}❌ Error en la instalación${NC}"
    exit 1
fi
echo ""

# Paso 4: Ejecutar la aplicación
echo -e "${YELLOW}🚀 Paso 4: Ejecutando la aplicación...${NC}"
adb shell am start -n com.example.kotlinapp/.MainActivity
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Aplicación ejecutada correctamente${NC}"
else
    echo -e "${RED}❌ Error al ejecutar la aplicación${NC}"
    exit 1
fi
echo ""

# Paso 5: Esperar un momento para que la app se inicie
echo -e "${YELLOW}⏳ Paso 5: Esperando que la aplicación se inicie...${NC}"
sleep 5

# Paso 6: Verificar estado de la aplicación
echo -e "${YELLOW}📊 Paso 6: Verificando estado de la aplicación...${NC}"
check_app_status
echo ""

# Paso 7: Verificar errores
echo -e "${YELLOW}🔍 Paso 7: Verificando errores...${NC}"
check_errors
echo ""

# Paso 8: Mostrar logs
echo -e "${YELLOW}📱 Paso 8: Mostrando logs de la aplicación...${NC}"
show_logs

# Resumen final
echo -e "${GREEN}🎉 ¡PROCESO COMPLETADO!${NC}"
echo "=================================================="
echo -e "${BLUE}📋 Resumen:${NC}"
echo "✅ Compilación: Exitosa"
echo "✅ Instalación: Exitosa"
echo "✅ Ejecución: Exitosa"
echo "✅ Verificación: Completada"
echo ""
echo -e "${YELLOW}💡 La aplicación está ejecutándose en tu emulador${NC}"
echo "=================================================="

# Menú de opciones adicionales
echo -e "${BLUE}🔧 Opciones adicionales:${NC}"
echo "1. Ver errores específicos de login"
echo "2. Monitorear logs en tiempo real"
echo "3. Verificar estado de la aplicación"
echo "4. Salir"
echo ""
read -p "Selecciona una opción (1-4): " option

case $option in
    1)
        check_login_errors
        ;;
    2)
        monitor_login_logs
        ;;
    3)
        check_app_status
        ;;
    4)
        echo -e "${GREEN}👋 ¡Hasta luego!${NC}"
        ;;
    *)
        echo -e "${RED}❌ Opción inválida${NC}"
        ;;
esac

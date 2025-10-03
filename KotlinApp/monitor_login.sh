#!/bin/bash

echo "🔍 Monitor de Logs de Login - KotlinApp"
echo "=================================================="

# Configurar variables de entorno
export PATH=$PATH:/Users/marcosespana/Library/Android/sdk/platform-tools

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para limpiar logs y empezar fresh
clear_logs() {
    echo -e "${YELLOW}🧹 Limpiando logs anteriores...${NC}"
    adb logcat -c
    echo -e "${GREEN}✅ Logs limpiados${NC}"
    echo ""
}

# Función para monitorear logs específicos de login
monitor_login() {
    echo -e "${BLUE}🔍 Monitoreando logs de login en tiempo real...${NC}"
    echo "=================================================="
    echo -e "${YELLOW}💡 Buscando: LoginViewModel, AuthRepository, Retrofit, HTTP, Errores${NC}"
    echo -e "${YELLOW}💡 Presiona Ctrl+C para detener${NC}"
    echo "=================================================="
    
    adb logcat | grep -E "(kotlinapp|LoginViewModel|AuthRepository|AuthApiService|Retrofit|OkHttp|HTTP|Exception|Error|FATAL|AndroidRuntime|401|403|500)" --line-buffered
}

# Función para ver errores recientes
show_recent_errors() {
    echo -e "${YELLOW}🔍 Mostrando errores recientes...${NC}"
    echo "=================================================="
    
    # Errores de red
    echo -e "${BLUE}📡 Errores de red/HTTP:${NC}"
    local network_errors=$(adb logcat -d | grep -E "(Retrofit|OkHttp|HTTP|Connection|Network|Timeout|500|502|503)" | tail -10)
    if [ -n "$network_errors" ]; then
        echo "$network_errors"
    else
        echo "No se encontraron errores de red"
    fi
    echo ""
    
    # Errores de autenticación
    echo -e "${BLUE}🔐 Errores de autenticación:${NC}"
    local auth_errors=$(adb logcat -d | grep -E "(AuthRepository|AuthApiService|LoginViewModel|401|403|Unauthorized|Login failed)" | tail -10)
    if [ -n "$auth_errors" ]; then
        echo "$auth_errors"
    else
        echo "No se encontraron errores de autenticación"
    fi
    echo ""
    
    # Errores generales
    echo -e "${BLUE}🚨 Errores generales:${NC}"
    local app_errors=$(adb logcat -d | grep -E "(kotlinapp|Exception|Error|FATAL)" | tail -10)
    if [ -n "$app_errors" ]; then
        echo "$app_errors"
    else
        echo "No se encontraron errores generales"
    fi
    echo "=================================================="
}

# Función para probar conexión con backend
test_backend() {
    echo -e "${YELLOW}🌐 Probando conexión con backend...${NC}"
    echo "=================================================="
    
    # Probar health endpoint
    echo -e "${BLUE}📡 Probando /health:${NC}"
    local health_response=$(curl -s -w "HTTP_CODE:%{http_code}" http://localhost:8000/health)
    echo "$health_response"
    echo ""
    
    # Probar login endpoint
    echo -e "${BLUE}🔐 Probando /api/auth/login:${NC}"
    local login_response=$(curl -s -w "HTTP_CODE:%{http_code}" -X POST "http://localhost:8000/api/auth/login" \
        -H "Content-Type: application/json" \
        -d '{"email": "test@example.com", "password": "password123"}')
    echo "$login_response"
    echo "=================================================="
}

# Menú principal
echo -e "${BLUE}🔧 Opciones disponibles:${NC}"
echo "1. Limpiar logs y monitorear login en tiempo real"
echo "2. Ver errores recientes"
echo "3. Probar conexión con backend"
echo "4. Solo monitorear (sin limpiar)"
echo "5. Salir"
echo ""
read -p "Selecciona una opción (1-5): " option

case $option in
    1)
        clear_logs
        monitor_login
        ;;
    2)
        show_recent_errors
        ;;
    3)
        test_backend
        ;;
    4)
        monitor_login
        ;;
    5)
        echo -e "${GREEN}👋 ¡Hasta luego!${NC}"
        ;;
    *)
        echo -e "${RED}❌ Opción inválida${NC}"
        ;;
esac

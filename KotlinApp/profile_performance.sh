#!/bin/bash

# Script dedicado para profiling y monitoreo de performance
# Uso: ./profile_performance.sh

echo "📊 Script de Profiling y Performance para KotlinApp"
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

# Función para obtener el PID de la aplicación
get_app_pid() {
    local pid=$(adb shell pidof com.example.kotlinapp)
    echo $pid
}

# Función para verificar que la app esté ejecutándose
check_app_running() {
    local pid=$(get_app_pid)
    if [ -z "$pid" ]; then
        echo -e "${RED}❌ La aplicación no está ejecutándose${NC}"
        echo -e "${YELLOW}💡 Ejecuta primero: ./run_app.sh${NC}"
        return 1
    fi
    echo -e "${GREEN}✅ Aplicación ejecutándose (PID: $pid)${NC}"
    return 0
}

# Función para monitorear CPU y memoria en tiempo real
monitor_performance() {
    echo -e "${BLUE}📊 Monitoreando performance en tiempo real...${NC}"
    echo -e "${YELLOW}💡 Presiona Ctrl+C para detener el monitoreo${NC}"
    echo "=================================================="
    
    if ! check_app_running; then
        return 1
    fi
    
    local pid=$(get_app_pid)
    echo ""
    
    while true; do
        clear
        echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
        echo -e "${BLUE}   MÉTRICAS DE PERFORMANCE - $(date +%H:%M:%S)${NC}"
        echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
        echo ""
        
        # CPU Usage
        echo -e "${YELLOW}🖥️  CPU Usage:${NC}"
        adb shell top -n 1 -d 1 | grep -E "(PID|kotlinapp)" | head -3
        echo ""
        
        # Memory Usage
        echo -e "${YELLOW}💾 Memory Usage:${NC}"
        adb shell dumpsys meminfo com.example.kotlinapp | grep -E "(TOTAL|Native Heap|Dalvik Heap|App Summary)" | head -10
        echo ""
        
        # Frame Performance (si está disponible)
        echo -e "${YELLOW}🎬 Frame Performance (últimos 120 frames):${NC}"
        adb shell dumpsys gfxinfo com.example.kotlinapp | grep -A 5 "Janky frames" | head -6
        echo ""
        
        # Network Stats
        echo -e "${YELLOW}📡 Network Stats:${NC}"
        local network_stats=$(adb shell cat /proc/net/xt_qtaguid/stats 2>/dev/null | grep "$pid" | head -1)
        if [ -n "$network_stats" ]; then
            echo "$network_stats" | awk '{print "RX: " $6 " bytes, TX: " $8 " bytes"}'
        else
            echo "No hay datos de red disponibles"
        fi
        echo ""
        
        # Process Stats
        echo -e "${YELLOW}⚙️  Process Stats:${NC}"
        adb shell dumpsys procstats --hours 1 | grep -A 10 "com.example.kotlinapp" | head -10
        echo ""
        
        echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
        echo -e "${YELLOW}Actualizando cada 2 segundos... (Ctrl+C para salir)${NC}"
        
        sleep 2
    done
}

# Función para mostrar métricas de memoria detalladas
show_memory_details() {
    echo -e "${BLUE}💾 Métricas de Memoria Detalladas${NC}"
    echo "=================================================="
    if ! check_app_running; then
        return 1
    fi
    adb shell dumpsys meminfo com.example.kotlinapp
    echo "=================================================="
}

# Función para mostrar métricas de CPU detalladas
show_cpu_details() {
    echo -e "${BLUE}🖥️  Métricas de CPU Detalladas${NC}"
    echo "=================================================="
    if ! check_app_running; then
        return 1
    fi
    echo -e "${YELLOW}Top procesos (actualizando cada 2 segundos, Ctrl+C para salir):${NC}"
    while true; do
        clear
        echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
        echo -e "${BLUE}   CPU USAGE - $(date +%H:%M:%S)${NC}"
        echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
        adb shell top -n 1 | head -20
        echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
        sleep 2
    done
}

# Función para mostrar métricas de frames/rendering
show_frame_stats() {
    echo -e "${BLUE}🎬 Métricas de Frame Rendering${NC}"
    echo "=================================================="
    if ! check_app_running; then
        return 1
    fi
    echo -e "${YELLOW}Reseteando estadísticas de frames...${NC}"
    adb shell dumpsys gfxinfo com.example.kotlinapp reset > /dev/null 2>&1
    echo ""
    echo -e "${YELLOW}Esperando 10 segundos para recopilar datos...${NC}"
    sleep 10
    echo ""
    echo -e "${GREEN}Estadísticas de frames:${NC}"
    adb shell dumpsys gfxinfo com.example.kotlinapp
    echo "=================================================="
}

# Función para monitorear frames en tiempo real
monitor_frames() {
    echo -e "${BLUE}🎬 Monitoreando Frame Performance en tiempo real...${NC}"
    echo -e "${YELLOW}💡 Presiona Ctrl+C para detener el monitoreo${NC}"
    echo "=================================================="
    
    if ! check_app_running; then
        return 1
    fi
    
    # Resetear estadísticas
    adb shell dumpsys gfxinfo com.example.kotlinapp reset > /dev/null 2>&1
    
    while true; do
        clear
        echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
        echo -e "${BLUE}   FRAME PERFORMANCE - $(date +%H:%M:%S)${NC}"
        echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
        echo ""
        
        # Obtener estadísticas de frames
        local frame_info=$(adb shell dumpsys gfxinfo com.example.kotlinapp)
        
        # Extraer información relevante
        echo "$frame_info" | grep -A 20 "Janky frames" | head -25
        echo ""
        
        # Mostrar resumen de frames
        echo -e "${YELLOW}📊 Resumen:${NC}"
        echo "$frame_info" | grep -E "(Total frames rendered|Janky frames|50th percentile|90th percentile|95th percentile|99th percentile)" | head -10
        echo ""
        
        echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
        echo -e "${YELLOW}Actualizando cada 3 segundos... (Ctrl+C para salir)${NC}"
        
        sleep 3
    done
}

# Función para mostrar estadísticas de batería
show_battery_stats() {
    echo -e "${BLUE}🔋 Estadísticas de Batería${NC}"
    echo "=================================================="
    if ! check_app_running; then
        return 1
    fi
    adb shell dumpsys batterystats | grep -A 30 "com.example.kotlinapp" | head -40
    echo "=================================================="
}

# Función para dashboard completo de performance
show_performance_dashboard() {
    if ! check_app_running; then
        return 1
    fi
    
    local pid=$(get_app_pid)
    
    clear
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo -e "${BLUE}   DASHBOARD DE PERFORMANCE${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo ""
    
    # CPU
    echo -e "${YELLOW}🖥️  CPU Usage:${NC}"
    adb shell top -n 1 -d 1 | grep kotlinapp | head -1
    echo ""
    
    # Memory
    echo -e "${YELLOW}💾 Memory (MB):${NC}"
    adb shell dumpsys meminfo com.example.kotlinapp | grep -E "TOTAL" | head -1
    echo ""
    
    # Frames
    echo -e "${YELLOW}🎬 Frame Performance:${NC}"
    adb shell dumpsys gfxinfo com.example.kotlinapp | grep -E "(Janky frames|Total frames)" | head -2
    echo ""
    
    # Process info
    echo -e "${YELLOW}⚙️  Process Info:${NC}"
    adb shell ps | grep kotlinapp
    echo ""
    
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
}

# Función para exportar métricas a archivo
export_metrics() {
    echo -e "${BLUE}💾 Exportando métricas a archivo...${NC}"
    if ! check_app_running; then
        return 1
    fi
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local output_file="performance_metrics_${timestamp}.txt"
    
    echo "Exportando métricas a: $output_file"
    {
        echo "=== PERFORMANCE METRICS - $(date) ==="
        echo ""
        echo "=== CPU ==="
        adb shell top -n 1 -d 1 | grep kotlinapp
        echo ""
        echo "=== MEMORY ==="
        adb shell dumpsys meminfo com.example.kotlinapp
        echo ""
        echo "=== FRAMES ==="
        adb shell dumpsys gfxinfo com.example.kotlinapp
        echo ""
        echo "=== BATTERY ==="
        adb shell dumpsys batterystats | grep -A 30 "com.example.kotlinapp"
    } > "$output_file"
    
    echo -e "${GREEN}✅ Métricas exportadas a: $output_file${NC}"
}

# Verificar que hay un dispositivo conectado
if [ $(adb devices | grep -v "List of devices attached" | grep -c "device$") -eq 0 ]; then
    echo -e "${RED}❌ No hay dispositivos conectados${NC}"
    echo -e "${YELLOW}💡 Conecta un dispositivo o inicia un emulador${NC}"
    exit 1
fi

# Menú principal
while true; do
    echo ""
    echo -e "${BLUE}🔧 Menú de Profiling y Performance:${NC}"
    echo "=================================================="
    echo -e "${YELLOW}📊 Monitoreo en Tiempo Real:${NC}"
    echo "  1. Monitorear performance completo (CPU, Memoria, Frames)"
    echo "  2. Monitorear frames en tiempo real"
    echo "  3. Monitorear CPU en tiempo real"
    echo ""
    echo -e "${YELLOW}📈 Métricas Detalladas:${NC}"
    echo "  4. Ver métricas de memoria detalladas"
    echo "  5. Ver estadísticas de frames"
    echo "  6. Ver estadísticas de batería"
    echo "  7. Dashboard completo de performance"
    echo ""
    echo -e "${YELLOW}💾 Exportar:${NC}"
    echo "  8. Exportar todas las métricas a archivo"
    echo ""
    echo -e "${YELLOW}🚪 Salir:${NC}"
    echo "  0. Salir"
    echo "=================================================="
    echo ""
    read -p "Selecciona una opción (0-8): " option
    
    case $option in
        1)
            monitor_performance
            ;;
        2)
            monitor_frames
            ;;
        3)
            show_cpu_details
            ;;
        4)
            show_memory_details
            ;;
        5)
            show_frame_stats
            ;;
        6)
            show_battery_stats
            ;;
        7)
            show_performance_dashboard
            read -p "Presiona Enter para continuar..."
            ;;
        8)
            export_metrics
            ;;
        0)
            echo -e "${GREEN}👋 ¡Hasta luego!${NC}"
            break
            ;;
        *)
            echo -e "${RED}❌ Opción inválida${NC}"
            ;;
    esac
done


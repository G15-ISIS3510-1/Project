#!/bin/bash

# Script para monitorear la sincronización de mensajes en tiempo real

# Configurar PATH para adb
export PATH=$PATH:$HOME/Library/Android/sdk/platform-tools
export PATH=$PATH:$HOME/Library/Android/sdk/emulator

echo "📱 Monitoreando sincronización de mensajes..."
echo "=================================================="
echo "Filtros aplicados: MessagesSyncWorker | MessagesSyncScheduler | NetworkMonitor"
echo "Presiona Ctrl+C para detener"
echo "=================================================="

# Verificar que adb esté disponible
if ! command -v adb &> /dev/null; then
    echo "❌ Error: adb no encontrado. Por favor instala Android SDK Platform Tools"
    echo "   O configura manualmente el PATH:"
    echo "   export PATH=\$PATH:\$HOME/Library/Android/sdk/platform-tools"
    exit 1
fi

# Verificar que hay un dispositivo conectado
if ! adb devices | grep -q "device$"; then
    echo "⚠️  No hay dispositivos Android conectados"
    echo "   Conecta un dispositivo o inicia un emulador"
    exit 1
fi

echo "✅ Dispositivo conectado"
echo ""

# Limpiar logs anteriores
adb logcat -c

# Monitorear logs específicos de sincronización
adb logcat | grep -E "(MessagesSyncWorker|MessagesSyncScheduler|NetworkMonitor|Internet disponible|Internet perdido|Sincronización)" --line-buffered


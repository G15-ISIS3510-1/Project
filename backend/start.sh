#!/bin/bash

echo "🚀 Iniciando Backend FastAPI para Aplicación Móvil"
echo "=================================================="

# Verificar si Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 no está instalado. Por favor instálalo primero."
    exit 1
fi

# Verificar si pip está instalado
if ! command -v pip3 &> /dev/null; then
    echo "❌ pip3 no está instalado. Por favor instálalo primero."
    exit 1
fi

# Crear entorno virtual si no existe
if [ ! -d "venv" ]; then
    echo "📦 Creando entorno virtual..."
    python3 -m venv venv
fi

# Activar entorno virtual
echo "🔧 Activando entorno virtual..."
source venv/bin/activate

# Instalar dependencias
echo "📚 Instalando dependencias..."
pip install -r requirements.txt

# Verificar si PostgreSQL está corriendo
echo "🗄️  Verificando conexión a PostgreSQL..."
if ! pg_isready -h localhost -p 5432 &> /dev/null; then
    echo "⚠️  PostgreSQL no está corriendo en localhost:5432"
    echo "   Por favor inicia PostgreSQL o actualiza la configuración en .env"
fi

# Generar migraciones de Alembic
echo "🔄 Generando migraciones de base de datos..."
alembic revision --autogenerate -m "Initial migration"

# Aplicar migraciones
echo "📊 Aplicando migraciones..."
alembic upgrade head

echo ""
echo "✅ Backend listo!"
echo "🌐 Servidor corriendo en: http://localhost:8000"
echo "📖 Documentación API: http://localhost:8000/docs"
echo "🔧 Para detener: Ctrl+C"
echo ""

# Iniciar servidor
echo "🚀 Iniciando servidor FastAPI..."
python main.py

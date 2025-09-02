# 🚗 Backend FastAPI para Aplicación Móvil

Backend moderno y rápido para aplicación móvil de alquiler de vehículos, construido con FastAPI, SQLAlchemy y PostgreSQL.

## 🏗️ Arquitectura

```
app/
├── core/           # Configuración y utilidades de seguridad
│   ├── config.py   # Variables de entorno y configuración
│   └── security.py # JWT y hashing de contraseñas
├── db/             # Base de datos
│   ├── base.py     # Engine y sesión SQLAlchemy async
│   └── models.py   # Modelos SQLAlchemy
├── schemas/        # Esquemas Pydantic
│   └── user.py     # Validación de request/response
└── routers/        # Endpoints de la API
    ├── auth.py     # Autenticación
    └── users.py    # Gestión de usuarios
```

## 🚀 Características

- **FastAPI**: API moderna y rápida con documentación automática
- **SQLAlchemy Async**: ORM asíncrono para PostgreSQL
- **Alembic**: Migraciones de base de datos
- **JWT**: Autenticación segura con tokens
- **Pydantic**: Validación de datos automática
- **CORS**: Soporte para aplicaciones móviles
- **PostgreSQL**: Base de datos robusta y escalable

## 📋 Requisitos

- Python 3.8+
- PostgreSQL 12+
- pip

## 🛠️ Instalación

### 1. Clonar el repositorio
```bash
git clone <tu-repositorio>
cd backend
```

### 2. Crear entorno virtual
```bash
python3 -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
```

### 3. Instalar dependencias
```bash
pip install -r requirements.txt
```

### 4. Configurar base de datos
```bash
# Crear archivo .env basado en env.example
cp env.example .env

# Editar .env con tus credenciales de PostgreSQL
DATABASE_URL=postgresql://usuario:contraseña@localhost:5432/nombre_db
DATABASE_URL_ASYNC=postgresql+asyncpg://usuario:contraseña@localhost:5432/nombre_db
```

### 5. Configurar base de datos
```bash
# Generar migración inicial
alembic revision --autogenerate -m "Initial migration"

# Aplicar migraciones
alembic upgrade head
```

## 🚀 Uso

### Inicio rápido
```bash
# Usar el script de inicio (recomendado)
chmod +x start.sh
./start.sh
```

### Inicio manual
```bash
# Activar entorno virtual
source venv/bin/activate

# Iniciar servidor
python main.py
```

### Inicio con uvicorn
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## 📚 Endpoints de la API

### Autenticación
- `POST /api/auth/register` - Registrar nuevo usuario
- `POST /api/auth/login` - Iniciar sesión
- `GET /api/auth/me` - Obtener usuario actual

### Usuarios
- `GET /api/users/` - Listar usuarios
- `GET /api/users/{user_id}` - Obtener usuario específico
- `PUT /api/users/{user_id}` - Actualizar usuario
- `DELETE /api/users/{user_id}` - Eliminar usuario

### Otros
- `GET /` - Información de la API
- `GET /health` - Health check
- `GET /docs` - Documentación interactiva (Swagger)
- `GET /redoc` - Documentación alternativa

## 🗄️ Base de Datos

### Modelos principales
- **User**: Usuarios del sistema (hosts y renters)
- **Vehicle**: Vehículos disponibles para alquiler
- **Booking**: Reservas de vehículos
- **Payment**: Pagos de reservas
- **InsurancePlan**: Planes de seguro

### Migraciones
```bash
# Crear nueva migración
alembic revision --autogenerate -m "Descripción del cambio"

# Aplicar migraciones pendientes
alembic upgrade head

# Revertir última migración
alembic downgrade -1
```

## 🔧 Desarrollo

### Estructura del proyecto
```
backend/
├── app/                    # Código de la aplicación
├── alembic/               # Migraciones de base de datos
├── requirements.txt        # Dependencias Python
├── alembic.ini           # Configuración de Alembic
├── main.py               # Punto de entrada
└── start.sh              # Script de inicio
```

### Variables de entorno
```bash
# Base de datos
DATABASE_URL=postgresql://usuario:contraseña@localhost:5432/nombre_db
DATABASE_URL_ASYNC=postgresql+asyncpg://usuario:contraseña@localhost:5432/nombre_db

# Seguridad
SECRET_KEY=tu-clave-secreta-aqui
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Aplicación
DEBUG=True
CORS_ORIGINS=["http://localhost:3000", "http://localhost:8080"]

# Servidor
HOST=0.0.0.0
PORT=8000
```

## 🧪 Testing

```bash
# Instalar dependencias de testing
pip install pytest pytest-asyncio httpx

# Ejecutar tests
pytest
```

## 📦 Despliegue

### Docker (recomendado)
```bash
# Construir imagen
docker build -t mobile-app-backend .

# Ejecutar contenedor
docker run -p 8000:8000 mobile-app-backend
```

### Producción
```bash
# Instalar dependencias de producción
pip install -r requirements.txt

# Configurar variables de entorno
export DEBUG=False
export SECRET_KEY=tu-clave-secreta-de-produccion

# Iniciar con gunicorn
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker
```

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 🆘 Soporte

Si tienes problemas o preguntas:

1. Revisa la documentación en `/docs`
2. Abre un issue en GitHub
3. Contacta al equipo de desarrollo

---

**¡Disfruta desarrollando tu aplicación móvil! 🚀📱**

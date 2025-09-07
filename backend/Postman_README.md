# 🚗 Car Sharing API - Postman Collection

Esta colección de Postman contiene todas las pruebas para la API de Car Sharing desarrollada con FastAPI.

## 📋 Contenido

### 🔧 Archivos incluidos:
- `Postman_Collection.json` - Colección principal con todos los endpoints
- `Postman_Environment.json` - Variables de entorno para desarrollo local
- `Postman_README.md` - Este archivo con instrucciones

## 🚀 Configuración

### 1. Importar en Postman:
1. Abre Postman
2. Click en "Import"
3. Selecciona los archivos:
   - `Postman_Collection.json`
   - `Postman_Environment.json`

### 2. Configurar el entorno:
1. Selecciona el entorno "Car Sharing API - Local Development"
2. Verifica que `base_url` esté configurado como `http://localhost:8000`

### 3. Iniciar el servidor:
```bash
cd backend
source venv/bin/activate
python main.py
```

## 📚 Estructura de la Colección

### 🏥 Health Check
- **GET /health** - Verificar estado del servidor

### 🔐 Authentication
- **POST /api/auth/register** - Registro de usuarios
- **POST /api/auth/login** - Login y obtención de token

### 👥 Users
- **GET /api/users/** - Listar usuarios
- **GET /api/users/{id}** - Obtener usuario específico
- **PUT /api/users/{id}** - Actualizar usuario
- **DELETE /api/users/{id}** - Eliminar usuario (soft delete)

### 🚗 Vehicles
- **GET /api/vehicles/** - Listar vehículos
- **POST /api/vehicles/** - Crear vehículo
- **GET /api/vehicles/{id}** - Obtener vehículo específico
- **GET /api/vehicles/owner/{id}** - Vehículos de un propietario
- **PUT /api/vehicles/{id}** - Actualizar vehículo
- **DELETE /api/vehicles/{id}** - Eliminar vehículo (soft delete)

### 💰 Pricing
- **GET /api/pricing/** - Listar precios
- **POST /api/pricing/** - Crear precio para vehículo
- **GET /api/pricing/{id}** - Obtener precio por ID
- **GET /api/pricing/vehicle/{id}** - Obtener precio por vehículo
- **PUT /api/pricing/{id}** - Actualizar precio
- **DELETE /api/pricing/{id}** - Eliminar precio

### 📅 Vehicle Availability
- **GET /api/vehicle-availability/** - Listar disponibilidades
- **POST /api/vehicle-availability/** - Crear disponibilidad
- **GET /api/vehicle-availability/{id}** - Obtener disponibilidad por ID
- **GET /api/vehicle-availability/vehicle/{id}** - Obtener disponibilidades por vehículo
- **GET /api/vehicle-availability/search/available** - Buscar vehículos disponibles
- **PUT /api/vehicle-availability/{id}** - Actualizar disponibilidad
- **DELETE /api/vehicle-availability/{id}** - Eliminar disponibilidad
- **DELETE /api/vehicle-availability/vehicle/{id}** - Eliminar todas las disponibilidades de un vehículo

### 🧪 Test Scenarios
- **Create Second Vehicle** - Crear segundo vehículo
- **Test Duplicate Plate** - Probar validación de placa duplicada
- **Test Invalid Data** - Probar validaciones de datos

## 🔄 Flujo de Pruebas Recomendado

### 1. Configuración inicial:
1. **Health Check** - Verificar que el servidor esté funcionando
2. **Register User** - Crear un usuario (se guarda automáticamente el user_id)
3. **Login User** - Obtener token (se guarda automáticamente el access_token)

### 2. Pruebas de vehículos:
1. **Create Vehicle** - Crear vehículo (se guarda automáticamente el vehicle_id)
2. **Get All Vehicles** - Verificar que aparezca en la lista
3. **Get Vehicle by ID** - Obtener el vehículo específico
4. **Get Vehicles by Owner** - Ver vehículos del propietario
5. **Update Vehicle** - Actualizar información
6. **Create Second Vehicle** - Crear otro vehículo

### 3. Pruebas de precios:
1. **Create Pricing** - Crear precio para el vehículo (se guarda automáticamente el pricing_id)
2. **Get All Pricings** - Verificar que aparezca en la lista
3. **Get Pricing by ID** - Obtener precio específico
4. **Get Pricing by Vehicle ID** - Obtener precio del vehículo
5. **Update Pricing** - Actualizar precio

### 4. Pruebas de disponibilidad:
1. **Create Availability** - Crear disponibilidad (se guarda automáticamente el availability_id)
2. **Get All Availabilities** - Verificar que aparezca en la lista
3. **Get Availability by ID** - Obtener disponibilidad específica
4. **Get Availabilities by Vehicle** - Ver disponibilidades del vehículo
5. **Search Available Vehicles** - Buscar vehículos disponibles en fechas específicas
6. **Update Availability** - Actualizar disponibilidad

### 5. Pruebas de validación:
1. **Test Duplicate Plate** - Debería fallar con error 400
2. **Test Invalid Data** - Debería fallar con errores de validación

### 6. Pruebas de usuarios:
1. **Get All Users** - Listar usuarios
2. **Get User by ID** - Obtener usuario específico
3. **Update User** - Actualizar información del usuario

## 🔑 Variables Automáticas

La colección incluye scripts que guardan automáticamente:
- `access_token` - Token JWT después del login
- `user_id` - ID del usuario después del registro
- `vehicle_id` - ID del vehículo después de crearlo
- `pricing_id` - ID del precio después de crearlo
- `availability_id` - ID de la disponibilidad después de crearla

## 📝 Ejemplos de Respuestas

### ✅ Registro exitoso:
```json
{
    "name": "Juan Pérez",
    "email": "juan@example.com",
    "phone": "1234567890",
    "role": "host",
    "user_id": "3023eb9e-9a7f-4380-b3cb-46a9f3969741",
    "driver_license_status": "pending",
    "status": "active",
    "created_at": "2025-09-02T20:30:18.490706Z"
}
```

### ✅ Login exitoso:
```json
{
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "bearer"
}
```

### ✅ Vehículo creado:
```json
{
    "make": "Toyota",
    "model": "Corolla",
    "year": 2020,
    "plate": "ABC123",
    "seats": 5,
    "transmission": "AT",
    "fuel_type": "gas",
    "mileage": 50000,
    "status": "active",
    "lat": 40.7128,
    "lng": -74.006,
    "vehicle_id": "52e91856-4bb1-44a4-bb72-319ceab66afc",
    "owner_id": "3023eb9e-9a7f-4380-b3cb-46a9f3969741",
    "created_at": "2025-09-02T20:31:38.616093Z"
}
```

### ✅ Precio creado:
```json
{
    "vehicle_id": "52e91856-4bb1-44a4-bb72-319ceab66afc",
    "daily_price": 50.0,
    "min_days": 1,
    "max_days": 30,
    "currency": "USD",
    "pricing_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "last_updated": "2025-09-02T20:32:00.000000Z"
}
```

### ✅ Disponibilidad creada:
```json
{
    "vehicle_id": "52e91856-4bb1-44a4-bb72-319ceab66afc",
    "start_ts": "2024-01-01T09:00:00Z",
    "end_ts": "2024-01-05T18:00:00Z",
    "type": "available",
    "notes": "Disponible para alquiler",
    "availability_id": "b2c3d4e5-f6g7-8901-bcde-f23456789012"
}
```

## ⚠️ Notas Importantes

1. **Autenticación**: Todos los endpoints (excepto auth y health) requieren token JWT
2. **Validaciones**: Los esquemas Pydantic validan automáticamente los datos
3. **Soft Delete**: Los usuarios y vehículos se marcan como inactivos, no se eliminan físicamente
4. **Placas únicas**: No se pueden crear vehículos con placas duplicadas
5. **Propiedad**: Solo puedes modificar/eliminar tus propios vehículos
6. **Relación 1:1**: Cada vehículo puede tener solo un precio
7. **Disponibilidad**: Los vehículos pueden tener múltiples períodos de disponibilidad
8. **Conflictos de horarios**: El sistema previene solapamientos en las disponibilidades
9. **Búsqueda inteligente**: Usa fechas ISO para buscar vehículos disponibles

## 🐛 Troubleshooting

### Error 401 (Unauthorized):
- Verificar que el token esté configurado correctamente
- Hacer login nuevamente para obtener un token fresco

### Error 400 (Bad Request):
- Verificar que los datos cumplan con las validaciones
- Revisar que los campos requeridos estén presentes

### Error 404 (Not Found):
- Verificar que el ID del recurso sea correcto
- Asegurarse de que el recurso exista en la base de datos

### Error 500 (Internal Server Error):
- Verificar que el servidor esté funcionando
- Revisar los logs del servidor para más detalles

## 📊 Documentación Adicional

- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`
- **Health Check**: `http://localhost:8000/health`

¡Disfruta probando la API! 🚀

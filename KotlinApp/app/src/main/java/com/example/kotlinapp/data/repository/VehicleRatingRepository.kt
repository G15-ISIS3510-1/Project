package com.example.kotlinapp.data.repository

import com.example.kotlinapp.data.api.VehicleRatingApi
import com.example.kotlinapp.data.cache.SimpleCacheManager
import com.example.kotlinapp.data.models.TopRatedVehicle
import com.example.kotlinapp.data.models.TopRatedVehicleSearch
import com.google.gson.reflect.TypeToken
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.lang.reflect.Type
import java.text.SimpleDateFormat
import java.util.*

class VehicleRatingRepository(
    private val api: VehicleRatingApi,
    private val cacheManager: SimpleCacheManager? = null
) {
    
    suspend fun getTopRatedVehicles(
        token: String,
        startDate: Date,
        endDate: Date,
        latitude: Double,
        longitude: Double,
        radiusKm: Double = 50.0,
        limit: Int = 3,
        useCache: Boolean = true,
        forceRefresh: Boolean = false
    ): Result<List<TopRatedVehicle>> = withContext(Dispatchers.IO) {
        try {
            // Generar clave única para la consulta
            val cacheKey = generateCacheKey(startDate, endDate, latitude, longitude, radiusKm, limit)
            
            // Si se fuerza refresh, limpiar el cache para esta clave
            if (forceRefresh && cacheManager != null) {
                cacheManager.clear(cacheKey)
                android.util.Log.d("VehicleRatingRepo", "Cache limpiado (forceRefresh=true)")
            }
            
            // PATRÓN CACHE-ASIDE: Paso 1 - Verificar cache
            if (useCache && cacheManager != null && !forceRefresh) {
                val listType: Type = object : TypeToken<List<TopRatedVehicle>>() {}.type
                val cachedData: List<TopRatedVehicle>? = cacheManager.get(cacheKey, listType)
                if (cachedData != null) {
                    android.util.Log.d("VehicleRatingRepo", " Cache HIT: ${cachedData.size} vehículos")
                    // Cache hit - Retornar inmediatamente
                    // NOTA: Si el cache tiene lista vacía de una búsqueda anterior, 
                    // se devolverá vacío. Limpiar cache si es necesario.
                    if (cachedData.isEmpty()) {
                        android.util.Log.w("VehicleRatingRepo", "  Cache contiene lista vacía - ignorando cache y consultando API")
                    } else {
                        return@withContext Result.success(cachedData)
                    }
                } else {
                    android.util.Log.d("VehicleRatingRepo", " Cache MISS - consultando API")
                }
            }
            
            // Cache miss - Llamar a API
            val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.getDefault())
            dateFormat.timeZone = TimeZone.getTimeZone("UTC")
            
            val startTs = dateFormat.format(startDate)
            val endTs = dateFormat.format(endDate)
            
            val searchParams = TopRatedVehicleSearch(
                startTs = startTs,
                endTs = endTs,
                latitude = latitude,
                longitude = longitude,
                radiusKm = radiusKm,
                limit = limit,
                minRating = 0.0  // Incluir todos los vehículos con ratings (promedio actual es 2.60)
            )
            
            android.util.Log.d("VehicleRatingRepo", "📤 Enviando request a API:")
            android.util.Log.d("VehicleRatingRepo", "   - start_ts: $startTs")
            android.util.Log.d("VehicleRatingRepo", "   - end_ts: $endTs")
            android.util.Log.d("VehicleRatingRepo", "   - lat: $latitude, lng: $longitude")
            android.util.Log.d("VehicleRatingRepo", "   - radius_km: $radiusKm, limit: $limit")
            android.util.Log.d("VehicleRatingRepo", "   - min_rating: ${searchParams.minRating}")
            
            val response = api.getTopRatedVehicles("Bearer $token", searchParams)
            
            android.util.Log.d("VehicleRatingRepo", "📥 Respuesta API recibida:")
            android.util.Log.d("VehicleRatingRepo", "   - Código: ${response.code()}")
            android.util.Log.d("VehicleRatingRepo", "   - Éxito: ${response.isSuccessful}")
            android.util.Log.d("VehicleRatingRepo", "   - Mensaje: ${response.message()}")
            
            if (response.isSuccessful) {
                val vehicles = response.body() ?: emptyList()
                
                android.util.Log.d("VehicleRatingRepo", "✅ Vehículos recibidos: ${vehicles.size}")
                if (vehicles.isNotEmpty()) {
                    android.util.Log.d("VehicleRatingRepo", "   Primeros vehículos:")
                    vehicles.take(3).forEach { vehicle ->
                        android.util.Log.d("VehicleRatingRepo", "     - ${vehicle.make} ${vehicle.model} (rating: ${vehicle.averageRating}, distancia: ${vehicle.distanceKm}km)")
                    }
                } else {
                    android.util.Log.w("VehicleRatingRepo", "⚠️ Lista vacía - verificar:")
                    android.util.Log.w("VehicleRatingRepo", "   1. Disponibilidad para las fechas")
                    android.util.Log.w("VehicleRatingRepo", "   2. Vehículos dentro del radio de 50km")
                    android.util.Log.w("VehicleRatingRepo", "   3. Vehículos con ratings >= min_rating (${searchParams.minRating})")
                }
                
                // PATRÓN CACHE-ASIDE: Paso 2 - Guardar en cache
                if (useCache && cacheManager != null) {
                    cacheManager.put(cacheKey, vehicles, 15) // 15 minutos TTL
                    android.util.Log.d("VehicleRatingRepo", "💾 Cache actualizado: ${vehicles.size} vehículos")
                }
                
                Result.success(vehicles)
            } else {
                // Log del error completo
                val errorCode = response.code()
                val errorBody = try {
                    response.errorBody()?.string() ?: "Sin detalles"
                } catch (e: Exception) {
                    "Error al leer errorBody: ${e.message}"
                }
                
                android.util.Log.e("VehicleRatingRepo", "❌ Error en API:")
                android.util.Log.e("VehicleRatingRepo", "   - Código: $errorCode")
                android.util.Log.e("VehicleRatingRepo", "   - Mensaje: ${response.message()}")
                android.util.Log.e("VehicleRatingRepo", "   - Body: $errorBody")
                
                // Si hay error de API, intentar devolver cache como fallback
                if (useCache && cacheManager != null) {
                    val listType: Type = object : TypeToken<List<TopRatedVehicle>>() {}.type
                    val cachedData: List<TopRatedVehicle>? = cacheManager.get(cacheKey, listType)
                    if (cachedData != null) {
                        android.util.Log.w("VehicleRatingRepo", "⚠️ Usando cache como fallback debido a error de API")
                        return@withContext Result.success(cachedData)
                    }
                }
                
                // Mensaje de error más descriptivo
                val errorMsg = when (errorCode) {
                    422 -> {
                        "Error de validación (422): $errorBody. Verifica que los parámetros sean correctos."
                    }
                    400 -> {
                        "Solicitud inválida (400): $errorBody"
                    }
                    401 -> {
                        "No autorizado (401). Por favor, inicia sesión nuevamente."
                    }
                    500 -> {
                        "Error del servidor (500): $errorBody"
                    }
                    else -> {
                        "Error: $errorCode - ${response.message()}. Detalles: $errorBody"
                    }
                }
                
                Result.failure(Exception(errorMsg))
            }
        } catch (e: Exception) {
            // Error de red - intentar devolver cache
            if (useCache && cacheManager != null) {
                val cacheKey = generateCacheKey(startDate, endDate, latitude, longitude, radiusKm, limit)
                val listType: Type = object : TypeToken<List<TopRatedVehicle>>() {}.type
                val cachedData: List<TopRatedVehicle>? = cacheManager.get(cacheKey, listType)
                if (cachedData != null) {
                    // Fallback: devolver cache aunque esté desactualizado
                    return@withContext Result.success(cachedData)
                }
            }
            
            Result.failure(e)
        }
    }
    
    /**
     * Generar clave única para el cache basada en parámetros de búsqueda
     */
    private fun generateCacheKey(
        startDate: Date,
        endDate: Date,
        latitude: Double,
        longitude: Double,
        radiusKm: Double,
        limit: Int
    ): String {
        val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        val start = dateFormat.format(startDate)
        val end = dateFormat.format(endDate)
        
        return "top_rated_${start}_${end}_${latitude}_${longitude}_${radiusKm}_${limit}"
    }
    
    suspend fun getVehicleRatings(
        token: String,
        vehicleId: String
    ): Result<List<com.example.kotlinapp.data.api.VehicleRating>> = withContext(Dispatchers.IO) {
        try {
            val response = api.getVehicleRatings("Bearer $token", vehicleId)
            
            if (response.isSuccessful) {
                Result.success(response.body() ?: emptyList())
            } else {
                Result.failure(Exception("Error: ${response.code()} - ${response.message()}"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}

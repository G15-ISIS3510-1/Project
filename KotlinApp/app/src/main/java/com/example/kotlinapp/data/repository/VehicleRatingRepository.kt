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
        useCache: Boolean = true
    ): Result<List<TopRatedVehicle>> = withContext(Dispatchers.IO) {
        try {
            // Generar clave única para la consulta
            val cacheKey = generateCacheKey(startDate, endDate, latitude, longitude, radiusKm, limit)
            
            // PATRÓN CACHE-ASIDE: Paso 1 - Verificar cache
            if (useCache && cacheManager != null) {
                val listType: Type = object : TypeToken<List<TopRatedVehicle>>() {}.type
                val cachedData: List<TopRatedVehicle>? = cacheManager.get(cacheKey, listType)
                if (cachedData != null) {
                    // Cache hit - Retornar inmediatamente
                    return@withContext Result.success(cachedData)
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
                limit = limit
            )
            
            val response = api.getTopRatedVehicles("Bearer $token", searchParams)
            
            if (response.isSuccessful) {
                val vehicles = response.body() ?: emptyList()
                
                // PATRÓN CACHE-ASIDE: Paso 2 - Guardar en cache
                if (useCache && cacheManager != null) {
                    cacheManager.put(cacheKey, vehicles, 15) // 15 minutos TTL
                }
                
                Result.success(vehicles)
            } else {
                // Si hay error de API, intentar devolver cache como fallback
                if (useCache && cacheManager != null) {
                    val listType: Type = object : TypeToken<List<TopRatedVehicle>>() {}.type
                    val cachedData: List<TopRatedVehicle>? = cacheManager.get(cacheKey, listType)
                    if (cachedData != null) {
                        return@withContext Result.success(cachedData)
                    }
                }
                
                val errorMsg = "Error: ${response.code()} - ${response.message()}"
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

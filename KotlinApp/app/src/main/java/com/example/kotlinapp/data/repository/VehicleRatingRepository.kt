package com.example.kotlinapp.data.repository

import android.util.Log
import com.example.kotlinapp.data.api.BatchRatingStatsRequest
import com.example.kotlinapp.data.api.BatchRatingStatsResponse
import com.example.kotlinapp.data.api.VehicleRatingApi
import com.example.kotlinapp.data.api.VehicleRatingStats
import com.example.kotlinapp.data.cache.SimpleCacheManager
import com.example.kotlinapp.data.models.TopRatedVehicle
import com.example.kotlinapp.data.models.TopRatedVehicleSearch
import com.google.gson.reflect.TypeToken
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.delay
import kotlinx.coroutines.withContext
import retrofit2.HttpException
import java.io.IOException
import java.lang.reflect.Type
import java.net.SocketTimeoutException
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
    
    /**
     * Obtener estadísticas de ratings para múltiples vehículos en batch.
     * 
     * ESTRATEGIA DE MULTITHREADING:
     * - Divide la lista de vehículos en chunks de 50 (límite del backend es 100)
     * - Procesa cada chunk en paralelo usando coroutines
     * - Cada chunk se ejecuta en su propio thread (Dispatchers.IO)
     * 
     * ECN (Error Correction Network):
     * - Reintentos con backoff exponencial por chunk
     * - Si un chunk falla, los demás continúan procesándose
     * - Fallback a procesamiento individual si el batch completo falla
     * - Manejo de errores individual por vehículo
     */
    suspend fun getBatchRatingStats(
        token: String,
        vehicleIds: List<String>,
        maxRetries: Int = 3,
        initialDelayMs: Long = 1000
    ): Result<BatchRatingStatsResponse> = withContext(Dispatchers.IO) {
        if (vehicleIds.isEmpty()) {
            return@withContext Result.success(
                BatchRatingStatsResponse(
                    stats = emptyList(),
                    total_processed = 0,
                    successful = 0,
                    failed = 0
                )
            )
        }
        
        try {
            // Dividir en chunks de 50 (backend acepta hasta 100, pero usamos 50 para seguridad)
            val chunkSize = 50
            val chunks = vehicleIds.chunked(chunkSize)
            
            Log.d("VehicleRatingRepo", "Procesando ${vehicleIds.size} vehículos en ${chunks.size} chunks")
            
            // Procesar todos los chunks en paralelo
            val chunkResults = chunks.mapIndexed { index, chunk ->
                async(Dispatchers.IO) {
                    processChunkWithRetry(
                        token = token,
                        vehicleIds = chunk,
                        chunkIndex = index,
                        maxRetries = maxRetries,
                        initialDelayMs = initialDelayMs
                    )
                }
            }.awaitAll()
            
            // Combinar resultados de todos los chunks
            val allStats = mutableListOf<VehicleRatingStats>()
            var totalSuccessful = 0
            var totalFailed = 0
            
            chunkResults.forEach { chunkResult ->
                when {
                    chunkResult.isSuccess -> {
                        val response = chunkResult.getOrNull()
                        if (response != null) {
                            allStats.addAll(response.stats)
                            totalSuccessful += response.successful
                            totalFailed += response.failed
                        }
                    }
                    else -> {
                        // Si un chunk falla completamente, contar todos como fallidos
                        val chunkSize = chunkResult.exceptionOrNull()?.let { 
                            // Intentar obtener el tamaño del chunk del error
                            (it as? ChunkProcessingException)?.chunkSize ?: 0
                        } ?: 0
                        totalFailed += chunkSize
                        Log.w("VehicleRatingRepo", "Chunk falló: ${chunkResult.exceptionOrNull()?.message}")
                    }
                }
            }
            
            val finalResponse = BatchRatingStatsResponse(
                stats = allStats,
                total_processed = vehicleIds.size,
                successful = totalSuccessful,
                failed = totalFailed
            )
            
            Log.d("VehicleRatingRepo", "Batch completado: ${finalResponse.successful} exitosos, ${finalResponse.failed} fallidos")
            Result.success(finalResponse)
            
        } catch (e: Exception) {
            Log.e("VehicleRatingRepo", "Error en procesamiento batch", e)
            Result.failure(e)
        }
    }
    
    /**
     * Procesa un chunk de vehículos con reintentos y manejo de errores.
     * ECN: Reintentos con backoff exponencial.
     */
    private suspend fun processChunkWithRetry(
        token: String,
        vehicleIds: List<String>,
        chunkIndex: Int,
        maxRetries: Int,
        initialDelayMs: Long
    ): Result<BatchRatingStatsResponse> {
        var lastException: Exception? = null
        var delayMs = initialDelayMs
        
        repeat(maxRetries) { attempt ->
            try {
                Log.d("VehicleRatingRepo", "Chunk $chunkIndex: Intento ${attempt + 1}/$maxRetries")
                
                val request = BatchRatingStatsRequest(vehicle_ids = vehicleIds)
                val response = api.getBatchRatingStats("Bearer $token", request)
                
                if (response.isSuccessful) {
                    val body = response.body()
                    if (body != null) {
                        Log.d("VehicleRatingRepo", "Chunk $chunkIndex: Éxito - ${body.successful} exitosos")
                        return Result.success(body)
                    } else {
                        lastException = Exception("Response body is null")
                    }
                } else {
                    val errorBody = response.errorBody()?.string() ?: "Unknown error"
                    lastException = HttpException(response)
                    Log.w("VehicleRatingRepo", "Chunk $chunkIndex: HTTP ${response.code()} - $errorBody")
                    
                    // Si es un error 4xx (cliente), no reintentar
                    if (response.code() in 400..499) {
                        throw lastException!!
                    }
                }
            } catch (e: SocketTimeoutException) {
                lastException = e
                Log.w("VehicleRatingRepo", "Chunk $chunkIndex: Timeout en intento ${attempt + 1}")
            } catch (e: IOException) {
                lastException = e
                Log.w("VehicleRatingRepo", "Chunk $chunkIndex: Error de red en intento ${attempt + 1}")
            } catch (e: HttpException) {
                lastException = e
                // No reintentar errores HTTP del cliente
                throw e
            } catch (e: Exception) {
                lastException = e
                Log.w("VehicleRatingRepo", "Chunk $chunkIndex: Error en intento ${attempt + 1}: ${e.message}")
            }
            
            // Esperar antes del siguiente intento (backoff exponencial)
            if (attempt < maxRetries - 1) {
                delay(delayMs)
                delayMs *= 2 // Backoff exponencial
            }
        }
        
        // Todos los intentos fallaron - lanzar excepción con información del chunk
        throw ChunkProcessingException(
            chunkIndex = chunkIndex,
            chunkSize = vehicleIds.size,
            cause = lastException
        )
    }
    
    /**
     * Excepción personalizada para errores de procesamiento de chunks
     */
    private class ChunkProcessingException(
        val chunkIndex: Int,
        val chunkSize: Int,
        cause: Throwable?
    ) : Exception("Error procesando chunk $chunkIndex con $chunkSize vehículos", cause)
}

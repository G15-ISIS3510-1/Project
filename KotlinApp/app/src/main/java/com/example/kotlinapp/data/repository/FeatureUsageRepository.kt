package com.example.kotlinapp.data.repository

import android.util.Log
import com.example.kotlinapp.data.api.AnalyticsApiService
import com.example.kotlinapp.data.api.BackendApis
import com.example.kotlinapp.data.remote.dto.FeatureUsageItemDto
import com.example.kotlinapp.data.remote.dto.FeatureUsageLogRequest
import com.example.kotlinapp.data.remote.dto.FeatureStatDto
import retrofit2.HttpException
import java.io.IOException
import java.net.SocketTimeoutException

class FeatureUsageRepository(
    private val api: AnalyticsApiService = BackendApis.analytics
) {
    private val TAG = "FeatureUsageRepository"
    
    suspend fun getLowUsageFeatures(
        weeks: Int = 4,
        threshold: Double = 2.0
    ): List<FeatureUsageItemDto> {
        return try {
            Log.d(TAG, "Fetching low usage features: weeks=$weeks, threshold=$threshold")
            val response = api.getLowUsageFeatures(weeks, threshold)
            
            if (!response.isSuccessful) {
                val errorBody = response.errorBody()?.string() ?: "Unknown error"
                Log.e(TAG, "HTTP ${response.code()}: $errorBody")
                throw Exception("Error del servidor: HTTP ${response.code()}")
            }
            
            val body = response.body()
            if (body == null) {
                Log.e(TAG, "Empty response body")
                throw Exception("Respuesta vacía del servidor")
            }
            
            Log.d(TAG, "Received ${body.features.size} low usage features")
            body.features
        } catch (e: SocketTimeoutException) {
            Log.e(TAG, "Timeout error: ${e.message}")
            throw Exception("Tiempo de espera agotado. Verifica tu conexión a internet.")
        } catch (e: IOException) {
            Log.e(TAG, "Network error: ${e.message}")
            throw Exception("Error de conexión. Verifica tu conexión a internet.")
        } catch (e: HttpException) {
            Log.e(TAG, "HTTP error: ${e.code()}, ${e.message()}")
            throw Exception("Error del servidor: HTTP ${e.code()}")
        } catch (e: Exception) {
            Log.e(TAG, "Unknown error: ${e.message}", e)
            throw Exception("Error al cargar métricas: ${e.message ?: "Error desconocido"}")
        }
    }
    
    suspend fun getFeatureUsageStats(
        featureName: String? = null,
        weeks: Int = 4
    ): List<FeatureStatDto> {
        return try {
            Log.d(TAG, "Fetching usage stats: featureName=$featureName, weeks=$weeks")
            val response = api.getFeatureUsageStats(featureName, weeks)
            
            if (!response.isSuccessful) {
                val errorBody = response.errorBody()?.string() ?: "Unknown error"
                Log.e(TAG, "HTTP ${response.code()}: $errorBody")
                throw Exception("Error del servidor: HTTP ${response.code()}")
            }
            
            val body = response.body()
            if (body == null) {
                Log.e(TAG, "Empty response body")
                throw Exception("Respuesta vacía del servidor")
            }
            
            Log.d(TAG, "Received ${body.stats.size} usage stats")
            body.stats
        } catch (e: SocketTimeoutException) {
            Log.e(TAG, "Timeout error: ${e.message}")
            throw Exception("Tiempo de espera agotado. Verifica tu conexión a internet.")
        } catch (e: IOException) {
            Log.e(TAG, "Network error: ${e.message}")
            throw Exception("Error de conexión. Verifica tu conexión a internet.")
        } catch (e: HttpException) {
            Log.e(TAG, "HTTP error: ${e.code()}, ${e.message()}")
            throw Exception("Error del servidor: HTTP ${e.code()}")
        } catch (e: Exception) {
            Log.e(TAG, "Unknown error: ${e.message}", e)
            throw Exception("Error al cargar métricas: ${e.message ?: "Error desconocido"}")
        }
    }

    suspend fun logFeatureUsage(
        featureName: String,
        durationSeconds: Double?,
        durationMs: Long?,
        originRoute: String?,
        destinationRoute: String?,
        metadata: Map<String, Any?>? = null
    ): Boolean {
        return try {
            Log.d(TAG, "📝 Creating feature usage log request: feature=$featureName, duration=${durationSeconds}s")
            val payload = FeatureUsageLogRequest(
                featureName = featureName,
                durationSeconds = durationSeconds,
                durationMs = durationMs,
                originRoute = originRoute,
                destinationRoute = destinationRoute,
                metadata = metadata?.takeIf { it.isNotEmpty() }
            )

            Log.d(TAG, "🌐 Calling API: POST /api/analytics/features/usage-log")
            val response = api.logFeatureUsage(payload)

            if (!response.isSuccessful) {
                val errorBody = response.errorBody()?.string()
                Log.e(TAG, "❌ Failed to log feature usage: HTTP ${response.code()} $errorBody")
                false
            } else {
                val responseBody = response.body()
                Log.d(TAG, "✅ Successfully logged feature usage. Response: $responseBody")
                true
            }
        } catch (e: SocketTimeoutException) {
            Log.e(TAG, "⏱️ Timeout error logging feature usage: ${e.message}", e)
            false
        } catch (e: IOException) {
            Log.e(TAG, "🔌 Network error logging feature usage: ${e.message}", e)
            false
        } catch (e: HttpException) {
            Log.e(TAG, "🚫 HTTP error logging feature usage: ${e.code()}, ${e.message()}", e)
            false
        } catch (e: Exception) {
            Log.e(TAG, "💥 Unexpected error logging feature usage", e)
            false
        }
    }
}


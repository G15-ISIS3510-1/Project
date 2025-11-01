package com.example.kotlinapp.data.repository

import android.util.Log
import com.example.kotlinapp.data.api.AnalyticsApiService
import com.example.kotlinapp.data.api.BackendApis
import com.example.kotlinapp.data.remote.dto.FeatureUsageItemDto
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
}


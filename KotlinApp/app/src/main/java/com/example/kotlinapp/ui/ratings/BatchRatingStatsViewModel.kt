package com.example.kotlinapp.ui.ratings

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.kotlinapp.data.api.BatchRatingStatsResponse
import com.example.kotlinapp.data.api.VehicleRatingStats
import com.example.kotlinapp.data.repository.AuthRepository
import com.example.kotlinapp.data.repository.VehicleRatingRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class BatchRatingStatsViewModel : ViewModel() {
    
    private val ratingRepository = VehicleRatingRepository(
        api = com.example.kotlinapp.data.api.ApiClient.vehicleRatingApi
    )
    
    private val authRepository = AuthRepository()
    
    private val _stats = MutableStateFlow<List<VehicleRatingStats>>(emptyList())
    val stats: StateFlow<List<VehicleRatingStats>> = _stats
    
    private val _aggregatedStats = MutableStateFlow<AggregatedStats?>(null)
    val aggregatedStats: StateFlow<AggregatedStats?> = _aggregatedStats
    
    private val _loading = MutableStateFlow(false)
    val loading: StateFlow<Boolean> = _loading
    
    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error
    
    data class AggregatedStats(
        val totalVehicles: Int,
        val averageRating: Double,
        val totalRatings: Int,
        val ratingDistribution: Map<Int, Int>,
        val vehiclesWithRatings: Int,
        val vehiclesWithoutRatings: Int
    )
    
    fun loadBatchStats(vehicleIds: List<String>) {
        if (vehicleIds.isEmpty()) {
            _error.value = "No se proporcionaron IDs de vehículos"
            return
        }
        
        viewModelScope.launch {
            _loading.value = true
            _error.value = null
            
            try {
                val token = authRepository.getAuthToken()
                if (token == null) {
                    _error.value = "Usuario no autenticado"
                    _loading.value = false
                    return@launch
                }
                
                Log.d("BatchRatingStatsVM", "Cargando estadísticas para ${vehicleIds.size} vehículos")
                
                val result = ratingRepository.getBatchRatingStats(token, vehicleIds)
                
                result.fold(
                    onSuccess = { response ->
                        Log.d("BatchRatingStatsVM", "Estadísticas cargadas: ${response.successful} exitosos, ${response.failed} fallidos")
                        _stats.value = response.stats
                        
                        // Calcular estadísticas agregadas
                        val aggregated = calculateAggregatedStats(response)
                        _aggregatedStats.value = aggregated
                    },
                    onFailure = { exception ->
                        Log.e("BatchRatingStatsVM", "Error cargando estadísticas", exception)
                        _error.value = exception.message ?: "Error desconocido"
                    }
                )
            } catch (e: Exception) {
                Log.e("BatchRatingStatsVM", "Excepción inesperada", e)
                _error.value = e.message ?: "Error inesperado"
            } finally {
                _loading.value = false
            }
        }
    }
    
    private fun calculateAggregatedStats(response: BatchRatingStatsResponse): AggregatedStats {
        val stats = response.stats
        
        // Filtrar vehículos con ratings
        val vehiclesWithRatings = stats.filter { it.total_ratings > 0 }
        val vehiclesWithoutRatings = stats.size - vehiclesWithRatings.size
        
        // Calcular promedio general
        val totalRatings = vehiclesWithRatings.sumOf { it.total_ratings }
        val averageRating = if (vehiclesWithRatings.isNotEmpty()) {
            vehiclesWithRatings.map { it.average_rating * it.total_ratings }.sum() / totalRatings
        } else {
            0.0
        }
        
        // Agregar distribución de ratings
        val ratingDistribution = mutableMapOf<Int, Int>()
        for (i in 1..5) {
            ratingDistribution[i] = vehiclesWithRatings.sumOf { 
                it.rating_distribution[i] ?: 0 
            }
        }
        
        return AggregatedStats(
            totalVehicles = stats.size,
            averageRating = averageRating,
            totalRatings = totalRatings,
            ratingDistribution = ratingDistribution,
            vehiclesWithRatings = vehiclesWithRatings.size,
            vehiclesWithoutRatings = vehiclesWithoutRatings
        )
    }
    
    fun refresh(vehicleIds: List<String>) {
        loadBatchStats(vehicleIds)
    }
}


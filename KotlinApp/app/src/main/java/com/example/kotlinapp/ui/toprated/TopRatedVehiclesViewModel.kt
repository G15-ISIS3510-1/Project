package com.example.kotlinapp.ui.toprated

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.kotlinapp.data.models.TopRatedVehicle
import com.example.kotlinapp.data.repository.VehicleRatingRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.*

data class TopRatedVehiclesUiState(
    val vehicles: List<TopRatedVehicle> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null,
    val searchParams: SearchParams = SearchParams()
)

data class SearchParams(
    val startDate: Date = Date(System.currentTimeMillis() + 24 * 60 * 60 * 1000), // Tomorrow
    val endDate: Date = Date(System.currentTimeMillis() + 4 * 24 * 60 * 60 * 1000), // 4 days from now
    val latitude: Double = 4.6097, // Bogotá coordinates
    val longitude: Double = -74.0817,
    val radiusKm: Double = 50.0,
    val limit: Int = 3
)

class TopRatedVehiclesViewModel(
    private val repository: VehicleRatingRepository
) : ViewModel() {
    
    private val _uiState = MutableStateFlow(TopRatedVehiclesUiState())
    val uiState: StateFlow<TopRatedVehiclesUiState> = _uiState.asStateFlow()
    
    fun searchTopRatedVehicles(token: String) {
        if (token.isEmpty()) {
            _uiState.value = _uiState.value.copy(
                isLoading = false,
                error = "Token de autenticación no válido. Por favor, inicia sesión nuevamente."
            )
            return
        }
        
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            
            val result = repository.getTopRatedVehicles(
                token = token,
                startDate = _uiState.value.searchParams.startDate,
                endDate = _uiState.value.searchParams.endDate,
                latitude = _uiState.value.searchParams.latitude,
                longitude = _uiState.value.searchParams.longitude,
                radiusKm = _uiState.value.searchParams.radiusKm,
                limit = _uiState.value.searchParams.limit
            )
            
            result.fold(
                onSuccess = { vehicles ->
                    _uiState.value = _uiState.value.copy(
                        vehicles = vehicles,
                        isLoading = false,
                        error = null
                    )
                },
                onFailure = { error ->
                    val errorMessage = when {
                        error.message?.contains("401") == true -> "Sesión expirada. Por favor, inicia sesión nuevamente."
                        error.message?.contains("403") == true -> "No tienes permisos para acceder a esta información."
                        error.message?.contains("404") == true -> "No se encontraron vehículos con los criterios especificados."
                        error.message?.contains("500") == true -> "Error del servidor. Intenta nuevamente más tarde."
                        error.message?.contains("timeout") == true -> "Tiempo de espera agotado. Verifica tu conexión a internet."
                        else -> error.message ?: "Error desconocido al cargar vehículos"
                    }
                    
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        error = errorMessage
                    )
                }
            )
        }
    }
    
    fun updateSearchParams(
        startDate: Date? = null,
        endDate: Date? = null,
        latitude: Double? = null,
        longitude: Double? = null,
        radiusKm: Double? = null,
        limit: Int? = null
    ) {
        val currentParams = _uiState.value.searchParams
        _uiState.value = _uiState.value.copy(
            searchParams = currentParams.copy(
                startDate = startDate ?: currentParams.startDate,
                endDate = endDate ?: currentParams.endDate,
                latitude = latitude ?: currentParams.latitude,
                longitude = longitude ?: currentParams.longitude,
                radiusKm = radiusKm ?: currentParams.radiusKm,
                limit = limit ?: currentParams.limit
            )
        )
    }
    
    fun clearError() {
        _uiState.value = _uiState.value.copy(error = null)
    }
}

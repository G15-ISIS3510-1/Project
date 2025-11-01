package com.example.kotlinapp.ui.analytics



import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.kotlinapp.data.models.PriceAnalytics
import com.example.kotlinapp.data.repository.AnalyticsRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class PriceAnalyticsViewModel(
    private val repository: AnalyticsRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<AnalyticsUiState>(AnalyticsUiState.Initial)
    val uiState: StateFlow<AnalyticsUiState> = _uiState.asStateFlow()

    fun analyzePrices(userLat: Double, userLng: Double, radiusKm: Double = 5.0) {
        viewModelScope.launch {
            _uiState.value = AnalyticsUiState.Loading

            repository.getPriceAnalytics(userLat, userLng, radiusKm)
                .onSuccess { analytics ->
                    _uiState.value = AnalyticsUiState.Success(analytics)
                }
                .onFailure { error ->
                    _uiState.value = AnalyticsUiState.Error(
                        error.message ?: "Error desconocido"
                    )
                }
        }
    }
}

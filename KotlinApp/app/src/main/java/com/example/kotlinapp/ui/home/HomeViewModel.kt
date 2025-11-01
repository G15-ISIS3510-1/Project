
package com.example.kotlinapp.ui.home


import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.kotlinapp.data.api.ApiClient
import com.example.kotlinapp.data.remote.dto.VehicleWithPricingResponse
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay

data class HomeUiState(
    val vehicles: List<VehicleWithPricingResponse> = emptyList(),
    val loading: Boolean = false,
    val error: String? = null,
    val searchQuery: String = "",
    val selectedCategory: String? = null
)

class HomeViewModel : ViewModel() {
    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState: StateFlow<HomeUiState> = _uiState

    private var searchJob: Job? = null

    init {
        loadVehicles()
    }

    fun onSearchQueryChange(query: String) {
        _uiState.value = _uiState.value.copy(searchQuery = query)


        searchJob?.cancel()
        searchJob = viewModelScope.launch {
            delay(500)
            loadVehicles()
        }
    }

    fun onCategorySelected(category: String) {
        val newCategory = if (_uiState.value.selectedCategory == category) {
            null
        } else {
            category
        }
        _uiState.value = _uiState.value.copy(selectedCategory = newCategory)
        loadVehicles()
    }

    fun loadVehicles() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(loading = true, error = null)
            try {
                val search = _uiState.value.searchQuery.takeIf { it.isNotBlank() }
                val category = _uiState.value.selectedCategory

                println("Buscando: query='$search', category='$category'")

                val vehicles = ApiClient.vehiclesApi.getActiveVehiclesWithPricing(
                    search = search,
                    category = category
                )

                println("ehículos encontrados: ${vehicles.items.size}")

                _uiState.value = _uiState.value.copy(
                    vehicles = vehicles.items,
                    loading = false
                )
            } catch (e: Exception) {
                println("Error: ${e.message}")
                e.printStackTrace()
                _uiState.value = _uiState.value.copy(
                    loading = false,
                    error = "Error loading vehicles: ${e.message}"
                )
            }
        }
    }

    fun retry() {
        loadVehicles()
    }

    fun clearFilters() {
        _uiState.value = _uiState.value.copy(
            searchQuery = "",
            selectedCategory = null
        )
        loadVehicles()
    }
}

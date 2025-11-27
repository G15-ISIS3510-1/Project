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
    val selectedCategory: String? = null,
    val isLoadingMore: Boolean = false,
    val hasMorePages: Boolean = true,
    val currentPage: Int = 0,
    val totalVehicles: Int = 0
)

class HomeViewModel : ViewModel() {
    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState: StateFlow<HomeUiState> = _uiState

    private var searchJob: Job? = null
    private val pageSize = 20

    init {
        loadVehicles(reset = true)
    }

    fun onSearchQueryChange(query: String) {
        _uiState.value = _uiState.value.copy(searchQuery = query)

        searchJob?.cancel()
        searchJob = viewModelScope.launch {
            delay(500) // Debounce
            loadVehicles(reset = true)
        }
    }

    fun onCategorySelected(category: String) {
        val newCategory = if (_uiState.value.selectedCategory == category) {
            null
        } else {
            category
        }
        _uiState.value = _uiState.value.copy(selectedCategory = newCategory)
        loadVehicles(reset = true)
    }


    fun loadMoreVehicles() {
        val currentState = _uiState.value

        // No cargar si ya está cargando o no hay más páginas
        if (currentState.isLoadingMore || currentState.loading || !currentState.hasMorePages) {
            return
        }

        println("Cargando siguiente página...")
        loadVehicles(reset = false)
    }

    private fun loadVehicles(reset: Boolean = false) {
        viewModelScope.launch {
            val currentState = _uiState.value

            // Si es reset, volver a página 0
            val page = if (reset) 0 else currentState.currentPage
            val skip = page * pageSize

            // Actualizar estado según si es carga inicial o más páginas
            _uiState.value = currentState.copy(
                loading = reset,
                isLoadingMore = !reset,
                error = null
            )

            try {
                val search = currentState.searchQuery.takeIf { it.isNotBlank() }
                val category = currentState.selectedCategory

                println("Cargando vehículos: página=$page, skip=$skip, limit=$pageSize")
                println("Filtros: query='$search', category='$category'")

                val response = ApiClient.vehiclesApi.getActiveVehiclesWithPricing(
                    search = search,
                    category = category,
                    skip = skip,
                    limit = pageSize
                )

                println("Vehículos recibidos: ${response.items.size} de ${response.total} totales")

                // Determinar si hay más páginas
                val hasMore = (skip + response.items.size) < response.total

                // Actualizar estado
                _uiState.value = currentState.copy(
                    vehicles = if (reset) response.items else currentState.vehicles + response.items,
                    loading = false,
                    isLoadingMore = false,
                    currentPage = page + 1,
                    hasMorePages = hasMore,
                    totalVehicles = response.total
                )

                println("Estado actualizado: ${_uiState.value.vehicles.size} vehículos en UI")

            } catch (e: Exception) {
                println("Error cargando vehículos: ${e.message}")
                e.printStackTrace()

                _uiState.value = currentState.copy(
                    loading = false,
                    isLoadingMore = false,
                    error = "Error loading vehicles: ${e.message}"
                )
            }
        }
    }

    fun retry() {
        println("Reintentando cargar vehículos...")
        loadVehicles(reset = true)
    }

    fun clearFilters() {
        println("Limpiando filtros...")
        _uiState.value = _uiState.value.copy(
            searchQuery = "",
            selectedCategory = null
        )
        loadVehicles(reset = true)
    }
}
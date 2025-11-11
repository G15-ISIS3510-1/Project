package com.example.kotlinapp.ui.home

import android.app.Application
import android.util.Log
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.kotlinapp.data.remote.dto.VehicleWithPricingResponse
import com.example.kotlinapp.data.repository.HomeRepository
import com.example.kotlinapp.data.utils.NetworkMonitor
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

data class HomeUiState(
    val vehicles: List<VehicleWithPricingResponse> = emptyList(),
    val loading: Boolean = false,
    val error: String? = null,
    val searchQuery: String = "",
    val selectedCategory: String? = null,
    val showCacheBanner: Boolean = false,
    val isOffline: Boolean = false
)

class HomeViewModel(application: Application) : AndroidViewModel(application) {

    private val repo = HomeRepository(application.applicationContext)
    private val networkMonitor = NetworkMonitor(application)

    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState: StateFlow<HomeUiState> = _uiState

    private var searchJob: Job? = null

    init {

        viewModelScope.launch {
            networkMonitor.isConnected.collect { connected ->
                _uiState.value = _uiState.value.copy(isOffline = !connected)

                if (connected) {

                    loadVehicles()
                } else {

                    if (_uiState.value.vehicles.isNotEmpty()) {
                        _uiState.value = _uiState.value.copy(showCacheBanner = true)
                    }
                }
            }
        }


        observeVehicles()


        loadVehicles()
    }

    private fun observeVehicles() {
        viewModelScope.launch {
            repo.observeVehicles(
                searchQuery = _uiState.value.searchQuery.takeIf { it.isNotBlank() },
                category = _uiState.value.selectedCategory
            ).collect { vehicles ->
                Log.d("HomeVM", "Cache actualizado: ${vehicles.size} vehículos")
                _uiState.value = _uiState.value.copy(vehicles = vehicles)
            }
        }
    }

    fun onSearchQueryChange(query: String) {
        _uiState.value = _uiState.value.copy(searchQuery = query)


        searchJob?.cancel()
        searchJob = viewModelScope.launch {
            delay(500)
            observeVehicles()
            loadVehicles()
        }
    }

    fun onCategorySelected(category: String) {
        val newCategory = if (_uiState.value.selectedCategory == category) null else category
        _uiState.value = _uiState.value.copy(selectedCategory = newCategory)
        observeVehicles()
        loadVehicles()
    }

    fun loadVehicles() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(loading = true, error = null)

            val result = repo.syncVehicles(
                searchQuery = _uiState.value.searchQuery.takeIf { it.isNotBlank() },
                category = _uiState.value.selectedCategory
            )

            result.fold(
                onSuccess = {
                    _uiState.value = _uiState.value.copy(
                        showCacheBanner = false,
                        error = null,
                        loading = false
                    )
                    Log.d("HomeVM", "Datos frescos cargados")
                },
                onFailure = { e ->
                    if (_uiState.value.vehicles.isNotEmpty()) {
                        _uiState.value = _uiState.value.copy(
                            showCacheBanner = true,
                            error = null,
                            loading = false
                        )
                        Log.d("HomeVM", "Usando cache (${_uiState.value.vehicles.size} vehículos)")
                    } else {
                        _uiState.value = _uiState.value.copy(
                            showCacheBanner = false,
                            error = e.message ?: "No internet connection",
                            loading = false
                        )
                        Log.e("HomeVM", "Error: ${e.message}")
                    }
                }
            )
        }
    }

    fun retry() = loadVehicles()

    fun clearFilters() {
        _uiState.value = _uiState.value.copy(searchQuery = "", selectedCategory = null)
        observeVehicles()
        loadVehicles()
    }
}
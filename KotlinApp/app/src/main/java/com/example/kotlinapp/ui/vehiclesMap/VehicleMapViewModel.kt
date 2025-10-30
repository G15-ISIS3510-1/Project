package com.example.kotlinapp.ui.vehiclesMap

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.kotlinapp.data.repository.VehicleRepository
import com.example.kotlinapp.data.repository.VehicleMapItem
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.delay

class VehicleMapViewModel(
    application: Application
) : AndroidViewModel(application) {

    private val repo = VehicleRepository(context = application)

    private val _vehicles = MutableStateFlow<List<VehicleMapItem>>(emptyList())
    val vehicles: StateFlow<List<VehicleMapItem>> = _vehicles.asStateFlow()

    private val _isRefreshing = MutableStateFlow(false)
    val isRefreshing: StateFlow<Boolean> = _isRefreshing.asStateFlow()

    private val _showCacheBanner = MutableStateFlow(false)
    val showCacheBanner: StateFlow<Boolean> = _showCacheBanner.asStateFlow()

    init {
        loadVehicles()
    }

    private fun loadVehicles() {
        // Suscribirse al Flow de Room
        viewModelScope.launch {
            repo.getActiveVehiclesFlow().collect { cachedVehicles ->
                _vehicles.value = cachedVehicles
            }
        }

        // Revalidar en segundo plano
        revalidate()
    }

    fun revalidate() {
        viewModelScope.launch {
            _isRefreshing.value = true

            val startTime = System.currentTimeMillis()

            val result = repo.revalidateVehicles()

            val elapsed = System.currentTimeMillis() - startTime
            if (elapsed < 800) {
                delay(800 - elapsed)
            }

            _showCacheBanner.value = result.isFailure
            _isRefreshing.value = false
        }
    }
}
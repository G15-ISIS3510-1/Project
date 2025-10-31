package com.example.kotlinapp.ui.addCar

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.kotlinapp.data.remote.dto.PricingCreate
import com.example.kotlinapp.data.remote.dto.VehicleCreate
import com.example.kotlinapp.data.repository.VehicleRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.io.File
import com.example.kotlinapp.data.local.LocationKVStore

class AddCarViewModel(application: Application) : AndroidViewModel(application) {

    private val repo = VehicleRepository(context = application)
    private val locationKV = LocationKVStore()

    private val _ui = MutableStateFlow(UiState())
    val ui: StateFlow<UiState> = _ui.asStateFlow()

    private val _pendingCount = MutableStateFlow(0)
    val pendingCount: StateFlow<Int> = _pendingCount.asStateFlow()

    private val _isOffline = MutableStateFlow(false)
    val isOffline: StateFlow<Boolean> = _isOffline.asStateFlow()

    private val _hasRecentLocation = MutableStateFlow(false)
    val hasRecentLocation: StateFlow<Boolean> = _hasRecentLocation.asStateFlow()

    private var waitingForSync = false

    init {

        val isRecent = locationKV.isLocationRecent()
        _hasRecentLocation.value = isRecent

        viewModelScope.launch {
            repo.getPendingCount().collect { count ->
                val previousCount = _pendingCount.value
                _pendingCount.value = count

                android.util.Log.d("AddCarVM", "📊 Vehículos pendientes: $count")

                if (waitingForSync && previousCount > 0 && count == 0) {
                    android.util.Log.d("AddCarVM", "🎉 Sincronización automática completada")
                    _ui.value = _ui.value.copy(
                        loading = false,
                        success = true,
                        message = "Vehicle synced successfully!"
                    )
                    waitingForSync = false
                }
            }
        }

        // ← NUEVO: Observar cambios de conectividad
        viewModelScope.launch {
            repo.observeConnectivity().collect { isConnected ->
                _isOffline.value = !isConnected
                android.util.Log.d("AddCarVM", "📡 Conectividad cambió: ${if (isConnected) "ONLINE" else "OFFLINE"}")
            }
        }
    }

    fun submit(vehicle: VehicleCreate, pricing: PricingCreate, photoFile: File?) {
        viewModelScope.launch {
            _ui.value = _ui.value.copy(loading = true, error = null, success = false)

            val hasInternet = repo.isConnected()
            _isOffline.value = !hasInternet

            android.util.Log.d("AddCarVM", "📝 Creando vehículo (Internet: $hasInternet)")

            try {
                val result = repo.createVehicleWithRetry(vehicle, pricing, photoFile)

                if (result.isSuccess) {
                    val localId = result.getOrNull()
                    locationKV.saveLastLocation(vehicle.lat, vehicle.lng)
                    _hasRecentLocation.value = true

                    if (hasInternet) {
                        android.util.Log.d("AddCarVM", "✅ Vehículo creado con internet")
                        _ui.value = _ui.value.copy(
                            loading = false,
                            success = true,
                            error = null,
                            message = "Vehicle added successfully!"
                        )
                        waitingForSync = false
                    } else {
                        android.util.Log.d("AddCarVM", "💾 Vehículo guardado localmente")
                        _ui.value = _ui.value.copy(
                            loading = false,
                            success = false,
                            error = null,
                            message = "Saved locally. Will sync when online."
                        )
                        waitingForSync = true
                    }
                } else {
                    val error = result.exceptionOrNull()
                    android.util.Log.e("AddCarVM", "❌ Error: ${error?.message}")
                    _ui.value = _ui.value.copy(
                        loading = false,
                        error = error?.message ?: "Unknown error"
                    )
                    waitingForSync = false
                }

            } catch (e: Exception) {
                android.util.Log.e("AddCarVM", "❌ Excepción: ${e.message}")
                _ui.value = _ui.value.copy(
                    loading = false,
                    error = e.message ?: "Failed to save vehicle"
                )
                waitingForSync = false
            }
        }
    }


    fun getLastLocation(): Pair<Double, Double>? {
        return locationKV.getLastLocation()
    }


    fun clearSavedLocation() {
        locationKV.clearLocation()
        _hasRecentLocation.value = false
    }

    fun syncPending() {
        viewModelScope.launch {
            android.util.Log.d("AddCarVM", "🔄 Sincronizando vehículos pendientes...")
            _ui.value = _ui.value.copy(loading = true, error = null)

            try {
                val result = repo.syncAllPending()

                if (result.isSuccess) {
                    val syncedCount = result.getOrNull() ?: 0
                    android.util.Log.d("AddCarVM", "✅ $syncedCount vehículos sincronizados")

                    _ui.value = _ui.value.copy(
                        loading = false,
                        message = if (syncedCount > 0) {
                            "$syncedCount vehicle(s) synced successfully!"
                        } else {
                            "No pending vehicles to sync"
                        }
                    )
                } else {
                    _ui.value = _ui.value.copy(
                        loading = false,
                        error = "Failed to sync. Check your connection."
                    )
                }
            } catch (e: Exception) {
                android.util.Log.e("AddCarVM", "❌ Error en sync: ${e.message}")
                _ui.value = _ui.value.copy(
                    loading = false,
                    error = e.message ?: "Sync failed"
                )
            }
        }
    }

    fun refreshConnectivity() {
        _isOffline.value = !repo.isConnected()
    }

    fun clearMessage() {
        _ui.value = _ui.value.copy(message = null, error = null)
    }
}

data class UiState(
    val loading: Boolean = false,
    val success: Boolean = false,
    val error: String? = null,
    val message: String? = null
)

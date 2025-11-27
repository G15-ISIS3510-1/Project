package com.example.kotlinapp.ui.ownerAvailabilityManager

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.kotlinapp.data.repository.AvailabilityRepository
import com.example.kotlinapp.data.repository.AvailabilityItem
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class AvailabilityViewModel(application: Application) : AndroidViewModel(application) {

    private val repo = AvailabilityRepository(context = application)

    private val _ui = MutableStateFlow(UiState())
    val ui: StateFlow<UiState> = _ui.asStateFlow()

    private val _pendingCount = MutableStateFlow(0)
    val pendingCount: StateFlow<Int> = _pendingCount.asStateFlow()

    private val _isOffline = MutableStateFlow(false)
    val isOffline: StateFlow<Boolean> = _isOffline.asStateFlow()

    private val _availabilities = MutableStateFlow<List<AvailabilityItem>>(emptyList())
    val availabilities: StateFlow<List<AvailabilityItem>> = _availabilities.asStateFlow()

    private var currentVehicleId: String? = null
    private var waitingForSync = false

    init {

        viewModelScope.launch {
            repo.getPendingCount().collect { count ->
                val previousCount = _pendingCount.value
                _pendingCount.value = count

                android.util.Log.d("AvailabilityVM", "Disponibilidades pendientes: $count")

                if (waitingForSync && previousCount > 0 && count == 0) {
                    android.util.Log.d("AvailabilityVM", "Sincronización automática completada")
                    _ui.value = _ui.value.copy(
                        loading = false,
                        success = true,
                        message = "Availability synced successfully!"
                    )
                    waitingForSync = false


                    currentVehicleId?.let { loadAvailabilities(it) }
                }
            }
        }


        viewModelScope.launch {
            repo.observeConnectivity().collect { isConnected ->
                _isOffline.value = !isConnected
                android.util.Log.d("AvailabilityVM", "Conectividad cambió: ${if (isConnected) "ONLINE" else "OFFLINE"}")
            }
        }
    }

    fun loadAvailabilities(vehicleId: String) {
        currentVehicleId = vehicleId

        viewModelScope.launch {

            repo.getAvailabilitiesFlow(vehicleId).collect { items ->
                _availabilities.value = items
                android.util.Log.d("AvailabilityVM", "Disponibilidades cargadas: ${items.size}")
            }
        }


        viewModelScope.launch {
            if (repo.isConnected()) {
                repo.revalidateAvailabilities(vehicleId)
            }
        }
    }

    fun createAvailability(
        vehicleId: String,
        startDate: String,
        endDate: String,
        status: String,
        reason: String?
    ) {
        viewModelScope.launch {
            _ui.value = _ui.value.copy(loading = true, error = null, success = false)

            val hasInternet = repo.isConnected()
            _isOffline.value = !hasInternet

            android.util.Log.d("AvailabilityVM", "Creando disponibilidad (Internet: $hasInternet)")

            try {
                val result = repo.createAvailabilityWithRetry(
                    vehicleId, startDate, endDate, status, reason
                )

                if (result.isSuccess) {
                    val localId = result.getOrNull()

                    if (hasInternet) {
                        android.util.Log.d("AvailabilityVM", "Disponibilidad creada con internet")
                        _ui.value = _ui.value.copy(
                            loading = false,
                            success = true,
                            error = null,
                            message = "Availability added successfully!"
                        )
                        waitingForSync = false
                    } else {
                        android.util.Log.d("AvailabilityVM", "Disponibilidad guardada localmente")
                        _ui.value = _ui.value.copy(
                            loading = false,
                            success = false,
                            error = null,
                            message = "Saved locally. Will sync when online."
                        )
                        waitingForSync = true
                    }


                    loadAvailabilities(vehicleId)
                } else {
                    val error = result.exceptionOrNull()
                    android.util.Log.e("AvailabilityVM", "Error: ${error?.message}")
                    _ui.value = _ui.value.copy(
                        loading = false,
                        error = error?.message ?: "Unknown error"
                    )
                    waitingForSync = false
                }

            } catch (e: Exception) {
                android.util.Log.e("AvailabilityVM", "Excepción: ${e.message}")
                _ui.value = _ui.value.copy(
                    loading = false,
                    error = e.message ?: "Failed to save availability"
                )
                waitingForSync = false
            }
        }
    }

    fun updateAvailability(
        availabilityId: String,
        startDate: String?,
        endDate: String?,
        status: String?,
        reason: String?
    ) {
        viewModelScope.launch {
            _ui.value = _ui.value.copy(loading = true, error = null, success = false)

            val hasInternet = repo.isConnected()
            _isOffline.value = !hasInternet

            android.util.Log.d("AvailabilityVM", "Actualizando disponibilidad (Internet: $hasInternet)")

            try {
                val result = repo.updateAvailabilityWithRetry(
                    availabilityId, startDate, endDate, status, reason
                )

                if (result.isSuccess) {
                    if (hasInternet) {
                        android.util.Log.d("AvailabilityVM", "Disponibilidad actualizada con internet")
                        _ui.value = _ui.value.copy(
                            loading = false,
                            success = true,
                            error = null,
                            message = "Availability updated successfully!"
                        )
                        waitingForSync = false
                    } else {
                        android.util.Log.d("AvailabilityVM", "Actualización guardada localmente")
                        _ui.value = _ui.value.copy(
                            loading = false,
                            success = false,
                            error = null,
                            message = "Updated locally. Will sync when online."
                        )
                        waitingForSync = true
                    }


                    currentVehicleId?.let { loadAvailabilities(it) }
                } else {
                    val error = result.exceptionOrNull()
                    _ui.value = _ui.value.copy(
                        loading = false,
                        error = error?.message ?: "Unknown error"
                    )
                    waitingForSync = false
                }

            } catch (e: Exception) {
                android.util.Log.e("AvailabilityVM", "Excepción: ${e.message}")
                _ui.value = _ui.value.copy(
                    loading = false,
                    error = e.message ?: "Failed to update availability"
                )
                waitingForSync = false
            }
        }
    }

    fun deleteAvailability(availabilityId: String, vehicleId: String) {
        viewModelScope.launch {
            _ui.value = _ui.value.copy(loading = true, error = null, success = false)

            val hasInternet = repo.isConnected()
            _isOffline.value = !hasInternet

            android.util.Log.d("AvailabilityVM", "Eliminando disponibilidad (Internet: $hasInternet)")

            try {
                val result = repo.deleteAvailabilityWithRetry(availabilityId, vehicleId)

                if (result.isSuccess) {
                    if (hasInternet) {
                        android.util.Log.d("AvailabilityVM", "Disponibilidad eliminada con internet")
                        _ui.value = _ui.value.copy(
                            loading = false,
                            success = true,
                            error = null,
                            message = "Availability deleted successfully!"
                        )
                        waitingForSync = false
                    } else {
                        android.util.Log.d("AvailabilityVM", "Eliminación guardada localmente")
                        _ui.value = _ui.value.copy(
                            loading = false,
                            success = false,
                            error = null,
                            message = "Deleted locally. Will sync when online."
                        )
                        waitingForSync = true
                    }


                    loadAvailabilities(vehicleId)
                } else {
                    val error = result.exceptionOrNull()
                    _ui.value = _ui.value.copy(
                        loading = false,
                        error = error?.message ?: "Unknown error"
                    )
                    waitingForSync = false
                }

            } catch (e: Exception) {
                android.util.Log.e("AvailabilityVM", "Excepción: ${e.message}")
                _ui.value = _ui.value.copy(
                    loading = false,
                    error = e.message ?: "Failed to delete availability"
                )
                waitingForSync = false
            }
        }
    }

    fun syncPending() {
        viewModelScope.launch {
            android.util.Log.d("AvailabilityVM", "Sincronizando disponibilidades pendientes...")
            _ui.value = _ui.value.copy(loading = true, error = null)

            try {
                val result = repo.syncAllPending()

                if (result.isSuccess) {
                    val syncedCount = result.getOrNull() ?: 0
                    android.util.Log.d("AvailabilityVM", "$syncedCount disponibilidades sincronizadas")

                    _ui.value = _ui.value.copy(
                        loading = false,
                        message = if (syncedCount > 0) {
                            "$syncedCount availability(ies) synced successfully!"
                        } else {
                            "No pending availabilities to sync"
                        }
                    )


                    currentVehicleId?.let { loadAvailabilities(it) }
                } else {
                    _ui.value = _ui.value.copy(
                        loading = false,
                        error = "Failed to sync. Check your connection."
                    )
                }
            } catch (e: Exception) {
                android.util.Log.e("AvailabilityVM", "Error en sync: ${e.message}")
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
        _ui.value = _ui.value.copy(message = null, error = null, success = false)
    }
}

data class UiState(
    val loading: Boolean = false,
    val success: Boolean = false,
    val error: String? = null,
    val message: String? = null
)

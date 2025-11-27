
package com.example.kotlinapp.ui.vehicleSelection

import android.app.Application
import android.util.Log
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.kotlinapp.App
import com.example.kotlinapp.data.api.ApiClient
import com.example.kotlinapp.data.network.NetworkMonitor
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class VehicleSelectionViewModel(application: Application) : AndroidViewModel(application) {

    private val networkMonitor = NetworkMonitor(application)

    private val _vehicles = MutableStateFlow<List<VehicleItem>>(emptyList())
    val vehicles: StateFlow<List<VehicleItem>> = _vehicles.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private val _isOffline = MutableStateFlow(false)
    val isOffline: StateFlow<Boolean> = _isOffline.asStateFlow()

    init {

        viewModelScope.launch {
            networkMonitor.observeConnectivity().collect { isConnected ->
                _isOffline.value = !isConnected
                Log.d("VehicleSelection", "Conectividad: ${if (isConnected) "ONLINE" else "OFFLINE"}")


                if (isConnected && _errorMessage.value != null && _vehicles.value.isEmpty()) {
                    Log.d("VehicleSelection", "Internet recuperado, reintentando carga...")
                    loadOwnerVehicles()
                }
            }
        }
    }

    fun loadOwnerVehicles() {
        viewModelScope.launch {
            _isLoading.value = true
            _errorMessage.value = null


            if (!networkMonitor.isConnected()) {
                _isLoading.value = false
                _isOffline.value = true
                _errorMessage.value = "No internet connection. Please check your network."
                Log.w("VehicleSelection", "No hay conexión a internet")
                return@launch
            }

            try {
                val userId = App.getPreferencesManager().getUserId()

                if (userId == null) {
                    _errorMessage.value = "User not logged in"
                    _isLoading.value = false
                    return@launch
                }

                Log.d("VehicleSelection", "Loading vehicles for user: $userId")

                val response = ApiClient.vehiclesApi.getOwnerVehicles(userId)

                if (response.isSuccessful) {
                    val body = response.body()

                    if (body != null) {
                        Log.d("VehicleSelection", "Received ${body.items.size} vehicles (total: ${body.total})")

                        _vehicles.value = body.items.map { dto ->
                            VehicleItem(
                                vehicleId = dto.vehicle_id,
                                make = dto.make,
                                model = dto.model,
                                year = dto.year,
                                type = dto.transmission,
                                licensePlate = dto.plate ?: "",
                                photoUrl = dto.photo_url
                            )
                        }
                    } else {
                        Log.w("VehicleSelection", "Response body is null")
                        _vehicles.value = emptyList()
                    }
                } else {
                    val errorBody = response.errorBody()?.string()
                    Log.e("VehicleSelection", "Failed to load vehicles: ${response.code()} - $errorBody")
                    _errorMessage.value = "Failed to load vehicles: ${response.code()}"
                }
            } catch (e: Exception) {
                Log.e("VehicleSelection", "Exception loading vehicles", e)

                _errorMessage.value = when {
                    e.message?.contains("Unable to resolve host") == true ->
                        "No internet connection. Please check your network."
                    e.message?.contains("timeout") == true ->
                        "Connection timeout. Please try again."
                    else -> "Error: ${e.message}"
                }
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun refresh() {
        if (!_isLoading.value) {
            loadOwnerVehicles()
        }
    }
}

data class VehicleItem(
    val vehicleId: String,
    val make: String,
    val model: String,
    val year: Int,
    val type: String,
    val licensePlate: String,
    val photoUrl: String? = null
)
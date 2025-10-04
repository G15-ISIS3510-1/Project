package com.example.kotlinapp.ui.vehiclesMap

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.kotlinapp.data.repository.VehicleRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class VehicleMapViewModel(
    private val repo: VehicleRepository = VehicleRepository()
) : ViewModel() {

    private val _vehicles = MutableStateFlow<List<VehicleMapItem>>(emptyList())
    val vehicles: StateFlow<List<VehicleMapItem>> = _vehicles

    init {
        loadVehicles()
    }

    private fun loadVehicles() {
        viewModelScope.launch {
            try {

                val response = repo.getActiveVehicles()
                _vehicles.value = response.map { vehicle ->
                    VehicleMapItem(
                        lat = vehicle.lat,
                        lng = vehicle.lng,
                        make = vehicle.make,
                        model = vehicle.model,
                        year = vehicle.year,
                        dailyPrice = 0.0
                    )
                }

            } catch (e: Exception) {
                println("Error loading vehicles: ${e.message}")
                e.printStackTrace()

            }
        }
    }
}

data class VehicleMapItem(
    val lat: Double,
    val lng: Double,
    val make: String,
    val model: String,
    val year: Int,
    val dailyPrice: Double
)
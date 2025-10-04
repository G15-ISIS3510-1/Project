package com.example.kotlinapp.ui.addCar

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.kotlinapp.App
import com.example.kotlinapp.data.local.PreferencesManager
import com.example.kotlinapp.data.remote.dto.PricingCreate
import com.example.kotlinapp.data.remote.dto.VehicleCreate
import com.example.kotlinapp.data.repository.VehicleRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import retrofit2.HttpException
import java.io.File

class AddCarViewModel(
    private val repo: VehicleRepository = VehicleRepository(),
    private val prefs: PreferencesManager = App.getPreferencesManager()
) : ViewModel() {

    private val _ui = MutableStateFlow(AddCarUiState())
    val ui: StateFlow<AddCarUiState> = _ui

    fun submit(v: VehicleCreate, p: PricingCreate, photoFile: File?) {
        val hasToken = prefs.hasValidToken()
        if (!hasToken) {
            _ui.value = AddCarUiState(error = "You must log in")
            return
        }

        _ui.value = AddCarUiState(loading = true)
        viewModelScope.launch {
            try {
                repo.createVehicleWithPricing(v, p, photoFile)
                _ui.value = AddCarUiState(success = true)
            } catch (e: HttpException) {
                val msg = if (e.code() == 401) "Session expired"
                else "Server Error (${e.code()})"
                _ui.value = AddCarUiState(error = msg)
            } catch (e: Exception) {
                _ui.value = AddCarUiState(error = e.message ?: "Network Error")
            }
        }
    }
}

data class AddCarUiState(
    val loading: Boolean = false,
    val success: Boolean = false,
    val error: String? = null
)



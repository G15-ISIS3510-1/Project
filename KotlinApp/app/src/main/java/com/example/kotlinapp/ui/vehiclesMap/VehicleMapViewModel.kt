package com.example.kotlinapp.ui.vehiclesMap

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.kotlinapp.data.cache.VehicleMemoryCache
import com.example.kotlinapp.data.repository.VehicleRepository
import com.example.kotlinapp.data.repository.VehicleMapItem
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import android.util.Log

class VehicleMapViewModel(
    application: Application
) : AndroidViewModel(application) {

    companion object {
        private const val TAG = "VehicleMapViewModel"
        private const val MAX_VISIBLE_MARKERS = 100 // Límite de markers
    }

    private val repo = VehicleRepository(context = application)

    // ============ CACHE EN MEMORIA (LRU) ============
    private val memoryCache = VehicleMemoryCache()

    private val _vehicles = MutableStateFlow<List<VehicleMapItem>>(emptyList())
    val vehicles: StateFlow<List<VehicleMapItem>> = _vehicles.asStateFlow()

    private val _isRefreshing = MutableStateFlow(false)
    val isRefreshing: StateFlow<Boolean> = _isRefreshing.asStateFlow()

    private val _showCacheBanner = MutableStateFlow(false)
    val showCacheBanner: StateFlow<Boolean> = _showCacheBanner.asStateFlow()

    private val _cacheStats = MutableStateFlow("Cache: 0/50")
    val cacheStats: StateFlow<String> = _cacheStats.asStateFlow()

    // OPTIMIZACIÓN: Reutilizar lista mutable en lugar de crear nuevas instancias
    private val vehiclesList = mutableListOf<VehicleMapItem>()

    init {
        loadVehicles()

    }

    private fun loadVehicles() {
        viewModelScope.launch {
            // Estrategia de caché de 3 niveles:
            // 1. Memoria (LRU) - más rápido
            // 2. Room (Disco) - persistente
            // 3. Red (API) - actualización

            repo.getActiveVehiclesFlow().collect { cachedVehicles ->
                Log.d(TAG, "Recibidos ${cachedVehicles.size} vehículos de Room")

                // OPTIMIZACIÓN: Reutilizar lista existente
                vehiclesList.clear()
                vehiclesList.addAll(cachedVehicles)

                // Actualizar LRU Cache
                memoryCache.putAll(cachedVehicles)
                updateCacheStats()

                // OPTIMIZACIÓN: Limitar vehículos si son demasiados
                val vehiclesToDisplay = if (vehiclesList.size > MAX_VISIBLE_MARKERS) {
                    Log.d(TAG, "⚠Limitando a $MAX_VISIBLE_MARKERS vehículos para optimizar rendering")
                    vehiclesList.take(MAX_VISIBLE_MARKERS)
                } else {
                    vehiclesList.toList() // Crear copia inmutable
                }

                _vehicles.value = vehiclesToDisplay
                Log.d(TAG, "Mostrando ${vehiclesToDisplay.size} vehículos en el mapa")
            }
        }


        revalidate()
    }

    fun revalidate() {
        viewModelScope.launch {
            _isRefreshing.value = true
            Log.d(TAG, "Iniciando revalidación...")

            val startTime = System.currentTimeMillis()

            val result = repo.revalidateVehicles()

            val elapsed = System.currentTimeMillis() - startTime

            // OPTIMIZACIÓN: Eliminar delay artificial innecesario

            when {
                result.isSuccess -> {
                    Log.d(TAG, "Revalidación exitosa en ${elapsed}ms")
                    _showCacheBanner.value = false

                }
                result.isFailure -> {
                    Log.w(TAG, "Revalidación falló: ${result.exceptionOrNull()?.message}")
                    _showCacheBanner.value = true
                }
            }

            _isRefreshing.value = false
        }
    }


    fun getVehicle(vehicleId: String): VehicleMapItem? {
        // 1. Buscar en memoria (O(1) - instantáneo)
        memoryCache.get(vehicleId)?.let {
            Log.d(TAG, "Vehículo obtenido de memoria: $vehicleId")
            return it
        }

        // 2. Buscar en disco si no está en memoria
        Log.d(TAG, "Vehículo no en memoria, buscando en lista: $vehicleId")
        return vehiclesList.find { it.vehicleId == vehicleId }?.also {
            memoryCache.put(vehicleId, it)
        }
    }


    fun clearCache() {
        memoryCache.clear()
        updateCacheStats()
        Log.d(TAG, "Caché limpiado")
    }


    private fun updateCacheStats() {
        _cacheStats.value = "Cache: ${memoryCache.size()}/${memoryCache.maxSize()}"
    }

    override fun onCleared() {
        super.onCleared()
        vehiclesList.clear()
        clearCache()
        Log.d(TAG, "ViewModel limpiado - recursos liberados")
    }
}
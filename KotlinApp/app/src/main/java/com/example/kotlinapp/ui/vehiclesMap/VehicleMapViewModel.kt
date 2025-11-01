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
import kotlinx.coroutines.delay
import android.util.Log

class VehicleMapViewModel(
    application: Application
) : AndroidViewModel(application) {

    companion object {
        private const val TAG = "VehicleMapViewModel"
    }

    private val repo = VehicleRepository(context = application)

    // ============ NUEVO: LRU Cache en memoria ============
    private val memoryCache = VehicleMemoryCache()
    // ====================================================

    private val _vehicles = MutableStateFlow<List<VehicleMapItem>>(emptyList())
    val vehicles: StateFlow<List<VehicleMapItem>> = _vehicles.asStateFlow()

    private val _isRefreshing = MutableStateFlow(false)
    val isRefreshing: StateFlow<Boolean> = _isRefreshing.asStateFlow()

    private val _showCacheBanner = MutableStateFlow(false)
    val showCacheBanner: StateFlow<Boolean> = _showCacheBanner.asStateFlow()

    // ============ NUEVO: Estado del caché ============
    private val _cacheStats = MutableStateFlow("Cache: 0/50")
    val cacheStats: StateFlow<String> = _cacheStats.asStateFlow()
    // =================================================

    init {
        loadVehicles()
        logCacheStats()  // Para debugging
    }

    private fun loadVehicles() {
        viewModelScope.launch {
            // Estrategia de caché de 3 niveles:
            // 1. Memoria (LRU) - más rápido
            // 2. Room (Disco) - persistente
            // 3. Red (API) - actualización

            repo.getActiveVehiclesFlow().collect { cachedVehicles ->
                Log.d(TAG, "📥 Recibidos ${cachedVehicles.size} vehículos de Room")

                // ============ NUEVO: Actualizar LRU Cache ============
                memoryCache.putAll(cachedVehicles)
                updateCacheStats()
                // ====================================================

                _vehicles.value = cachedVehicles
            }
        }

        // Revalidar en segundo plano
        revalidate()
    }

    fun revalidate() {
        viewModelScope.launch {
            _isRefreshing.value = true
            Log.d(TAG, "🔄 Iniciando revalidación...")

            val startTime = System.currentTimeMillis()

            val result = repo.revalidateVehicles()

            val elapsed = System.currentTimeMillis() - startTime
            if (elapsed < 800) {
                delay(800 - elapsed)
            }

            when {
                result.isSuccess -> {
                    Log.d(TAG, "✅ Revalidación exitosa")
                    _showCacheBanner.value = false

                    // ============ NUEVO: Actualizar estadísticas ============
                    logCacheStats()
                    // =======================================================
                }
                result.isFailure -> {
                    Log.w(TAG, "⚠️ Revalidación falló: ${result.exceptionOrNull()?.message}")
                    _showCacheBanner.value = true
                }
            }

            _isRefreshing.value = false
        }
    }

    // ============ NUEVO: Funciones del caché ============

    /**
     * Obtener un vehículo específico (primero busca en memoria, luego en disco)
     */
    fun getVehicle(vehicleId: String): VehicleMapItem? {
        // 1. Buscar en memoria (O(1) - instantáneo)
        memoryCache.get(vehicleId)?.let {
            Log.d(TAG, "⚡ Vehículo obtenido de memoria: $vehicleId")
            return it
        }

        // 2. Buscar en disco si no está en memoria
        Log.d(TAG, "💾 Vehículo no en memoria, buscando en Room: $vehicleId")
        return _vehicles.value.find { it.vehicleId == vehicleId }?.also {
            memoryCache.put(vehicleId, it)
        }
    }

    /**
     * Limpiar caché (útil para testing o logout)
     */
    fun clearCache() {
        memoryCache.clear()
        updateCacheStats()
        Log.d(TAG, "🧹 Caché limpiado")
    }

    /**
     * Actualizar estadísticas del caché en UI
     */
    private fun updateCacheStats() {
        _cacheStats.value = "Cache: ${memoryCache.size()}/${memoryCache.maxSize()}"
    }

    /**
     * Log de estadísticas detalladas (para Viva Voce)
     */
    private fun logCacheStats() {
        val stats = memoryCache.getStats()
        Log.d(TAG, """
            📊 ========== CACHE STATISTICS ==========
            ${stats}
            =========================================
        """.trimIndent())
    }

    /**
     * Obtener estadísticas completas del caché
     */
    fun getCacheStatistics(): String {
        return memoryCache.getStats().toString()
    }
    // ===================================================
}

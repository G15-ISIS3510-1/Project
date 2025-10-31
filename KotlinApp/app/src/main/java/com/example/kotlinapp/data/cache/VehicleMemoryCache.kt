package com.example.kotlinapp.data.cache

import android.util.LruCache
import com.example.kotlinapp.data.repository.VehicleMapItem
import android.util.Log

/**
 * Caché en memoria usando LRU (Least Recently Used)
 * Almacena hasta 50 vehículos en RAM para acceso ultra-rápido
 */
class VehicleMemoryCache {

    companion object {
        private const val MAX_CACHE_SIZE = 50
        private const val TAG = "VehicleMemoryCache"
    }

    // LRU Cache - Estructura de datos eficiente
    private val cache = object : LruCache<String, VehicleMapItem>(MAX_CACHE_SIZE) {

        // Definir el "tamaño" de cada elemento (1 unidad por vehículo)
        override fun sizeOf(key: String, value: VehicleMapItem): Int {
            return 1
        }

        // Callback cuando se remueve un elemento (por LRU o manualmente)
        override fun entryRemoved(
            evicted: Boolean,
            key: String,
            oldValue: VehicleMapItem,
            newValue: VehicleMapItem?
        ) {
            if (evicted) {
                Log.d(TAG, "🗑️ Vehículo $key evicted (LRU policy)")
            }
        }
    }

    /**
     * Obtener vehículo del caché (O(1) - tiempo constante)
     */
    fun get(vehicleId: String): VehicleMapItem? {
        val item = cache.get(vehicleId)
        if (item != null) {
            Log.d(TAG, "✅ Cache HIT: $vehicleId")
        } else {
            Log.d(TAG, "❌ Cache MISS: $vehicleId")
        }
        return item
    }

    /**
     * Guardar vehículo en caché
     */
    fun put(vehicleId: String, vehicle: VehicleMapItem) {
        cache.put(vehicleId, vehicle)
        Log.d(TAG, "💾 Cached: $vehicleId [${vehicle.make} ${vehicle.model}]")
    }

    /**
     * Guardar múltiples vehículos
     */
    fun putAll(vehicles: List<VehicleMapItem>) {
        vehicles.forEach { vehicle ->
            put(vehicle.vehicleId, vehicle)
        }
        Log.d(TAG, "📦 Batch cached: ${vehicles.size} vehicles")
    }

    /**
     * Limpiar todo el caché
     */
    fun clear() {
        val previousSize = cache.size()
        cache.evictAll()
        Log.d(TAG, "🧹 Cache cleared: $previousSize items removed")
    }

    /**
     * Obtener tamaño actual del caché
     */
    fun size(): Int = cache.size()

    /**
     * Obtener capacidad máxima
     */
    fun maxSize(): Int = cache.maxSize()

    /**
     * Obtener hit/miss ratio (para métricas)
     */
    fun getHitCount(): Int = cache.hitCount()
    fun getMissCount(): Int = cache.missCount()

    /**
     * Estadísticas del caché (para debugging y Viva Voce)
     */
    fun getStats(): CacheStats {
        return CacheStats(
            currentSize = size(),
            maxSize = maxSize(),
            hitCount = getHitCount(),
            missCount = getMissCount(),
            hitRate = if (getHitCount() + getMissCount() > 0) {
                getHitCount().toFloat() / (getHitCount() + getMissCount())
            } else 0f
        )
    }

    /**
     * Verificar si un vehículo está en caché
     */
    fun contains(vehicleId: String): Boolean {
        return cache.get(vehicleId) != null
    }
}

/**
 * Data class para estadísticas del caché
 */
data class CacheStats(
    val currentSize: Int,
    val maxSize: Int,
    val hitCount: Int,
    val missCount: Int,
    val hitRate: Float
) {
    override fun toString(): String {
        return """
            Cache Stats:
            - Size: $currentSize/$maxSize
            - Hits: $hitCount
            - Misses: $missCount
            - Hit Rate: ${(hitRate * 100).toInt()}%
        """.trimIndent()
    }
}

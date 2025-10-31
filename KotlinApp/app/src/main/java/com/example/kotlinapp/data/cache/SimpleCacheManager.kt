package com.example.kotlinapp.data.cache

import android.content.Context
import android.content.SharedPreferences
import com.google.gson.Gson
import java.util.concurrent.TimeUnit

/**
 * SimpleCacheManager: Implementación del patrón Cache-Aside
 * 
 * Patrón: Cache-Aside (Lazy Caching)
 * 
 * Flujo:
 * 1. Verificar si existe en cache
 * 2. Si existe y no está expirado → retornar inmediatamente (cache hit)
 * 3. Si no existe o está expirado → llamar a API (cache miss)
 * 4. Guardar resultado en cache
 * 5. Retornar datos
 * 
 * Estrategia:
 * - Cache en memoria (L1) para acceso rápido
 * - Persistencia en disco (L2) para persistir entre sesiones
 * - TTL configurable
 * - Thread-safe
 */
class SimpleCacheManager(context: Context) {
    
    private val prefs: SharedPreferences = context.getSharedPreferences(
        "simple_cache", // Crea este archivo en sharedPreferences en el almacenamiento interno del dispositivo
        Context.MODE_PRIVATE
    )
    
    private val gson = Gson() // Para serializar y deserializar es decir objetos y demas a json y al reves 
    
    // Cache en memoria (L1)
    private val memoryCache: MutableMap<String, CacheEntry<Any>> = mutableMapOf()
    
    // Cache en disco (L2) - persistencia
    private val diskCache: MutableMap<String, DiskCacheEntry> = mutableMapOf()
    
    private data class CacheEntry<T>(
        val data: T,
        val timestamp: Long = System.currentTimeMillis(),
        val ttlMillis: Long = 15 * 60 * 1000 // 15 minutos pde vida
    ) {
        fun isExpired(): Boolean = System.currentTimeMillis() - timestamp > ttlMillis
    }
    
    private data class DiskCacheEntry(
        val json: String,
        val timestamp: Long = System.currentTimeMillis(),
        val ttlMillis: Long = 15 * 60 * 1000 // 15 Mins de vida
    ) {
        fun isExpired(): Boolean = System.currentTimeMillis() - timestamp > ttlMillis
    }
    
    /**
     * Obtener datos del cache (Cache-Aside Pattern)
     * Prioriza: L1 (memoria) → L2 (disco) → null
     */
    fun <T> get(key: String, type: java.lang.reflect.Type): T? {
        // 1. Buscar en memoria (L1)
        val memEntry = memoryCache[key] as? CacheEntry<T>
        if (memEntry != null && !memEntry.isExpired()) {
            return memEntry.data
        }
        
        // 2. Buscar en disco en memoria (L2 - fast lookup)
        val diskEntry = diskCache[key]
        if (diskEntry != null && !diskEntry.isExpired()) {
            try {
                val data = gson.fromJson<T>(diskEntry.json, type)
                
                // Mover a memoria para próximo acceso
                if (data != null) {
                    val memEntry = CacheEntry(data, diskEntry.timestamp, diskEntry.ttlMillis)
                    memoryCache[key] = memEntry as CacheEntry<Any>
                }
                
                return data
            } catch (e: Exception) {
                // Error al deserializar
            }
        }
        
        // 3. Buscar en SharedPreferences (persistencia real)
        if (prefs.contains(key)) {
            val timestamp = prefs.getLong("${key}_timestamp", 0)
            val ttl = prefs.getLong("${key}_ttl", 15 * 60 * 1000)
            
            // Verificar si está expirado
            if (System.currentTimeMillis() - timestamp < ttl) {
                try {
                    val json = prefs.getString(key, null)
                    if (json != null) {
                        val data = gson.fromJson<T>(json, type)
                        
                        // Mover a memoria y diskCache para próximos accesos
                        if (data != null) {
                            val memEntry = CacheEntry(data, timestamp, ttl)
                            memoryCache[key] = memEntry as CacheEntry<Any>
                            
                            val diskEntry = DiskCacheEntry(json, timestamp, ttl)
                            diskCache[key] = diskEntry
                        }
                        
                        return data
                    }
                } catch (e: Exception) {
                    // Error al deserializar
                }
            }
        }
        
        return null
    }
    
    /**
     * Guardar datos en cache (Cache-Aside Pattern)
     * Guarda en: L1 (memoria) + L2 (disco)
     */
    fun <T> put(key: String, data: T, ttlMinutes: Int = 15) {
        val ttlMillis = TimeUnit.MINUTES.toMillis(ttlMinutes.toLong())
        
        // 1. Guardar en memoria (L1)
        val entry = CacheEntry(data, System.currentTimeMillis(), ttlMillis)
        memoryCache[key] = entry as CacheEntry<Any>
        
        // 2. Guardar en disco (L2)
        try {
            val json = gson.toJson(data)
            val diskEntry = DiskCacheEntry(json, System.currentTimeMillis(), ttlMillis)
            diskCache[key] = diskEntry
            
            // Persistir en SharedPreferences
            prefs.edit().putString(key, json).apply()
            prefs.edit().putLong("${key}_timestamp", System.currentTimeMillis()).apply()
            prefs.edit().putLong("${key}_ttl", ttlMillis).apply()
        } catch (e: Exception) {
            // Error al serializar
        }
    }
    
    /**
     * Verificar si existe cache válido
     */
    fun hasValidCache(key: String): Boolean {
        // Verificar memoria
        val memEntry = memoryCache[key]
        if (memEntry != null && !memEntry.isExpired()) {
            return true
        }
        
        // Verificar disco
        val diskEntry = diskCache[key]
        if (diskEntry != null && !diskEntry.isExpired()) {
            return true
        }
        
        // Verificar SharedPreferences
        if (prefs.contains(key)) {
            val timestamp = prefs.getLong("${key}_timestamp", 0)
            val ttl = prefs.getLong("${key}_ttl", 15 * 60 * 1000)
            return System.currentTimeMillis() - timestamp < ttl
        }
        
        return false
    }
    
    /**
     * Limpiar una entrada específica
     */
    fun clear(key: String) {
        memoryCache.remove(key)
        diskCache.remove(key)
        prefs.edit().remove(key)
            .remove("${key}_timestamp")
            .remove("${key}_ttl")
            .apply()
    }
    
    /**
     * Limpiar todo el cache
     */
    fun clearAll() {
        memoryCache.clear()
        diskCache.clear()
        prefs.edit().clear().apply()
    }
}


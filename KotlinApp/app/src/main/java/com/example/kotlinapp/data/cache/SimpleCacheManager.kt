package com.example.kotlinapp.data.cache

import android.content.Context
import android.content.SharedPreferences
import com.google.gson.Gson
import java.util.concurrent.TimeUnit
class SimpleCacheManager(context: Context) {
    
    private val prefs: SharedPreferences = context.getSharedPreferences(
        "simple_cache",
        Context.MODE_PRIVATE
    )
    
    private val gson = Gson()
    

    private val memoryCache: MutableMap<String, CacheEntry<Any>> = mutableMapOf()
    

    private val diskCache: MutableMap<String, DiskCacheEntry> = mutableMapOf()
    
    private data class CacheEntry<T>(
        val data: T,
        val timestamp: Long = System.currentTimeMillis(),
        val ttlMillis: Long = 15 * 60 * 1000
    ) {
        fun isExpired(): Boolean = System.currentTimeMillis() - timestamp > ttlMillis
    }
    
    private data class DiskCacheEntry(
        val json: String,
        val timestamp: Long = System.currentTimeMillis(),
        val ttlMillis: Long = 15 * 60 * 1000
    ) {
        fun isExpired(): Boolean = System.currentTimeMillis() - timestamp > ttlMillis
    }
    

    fun <T> get(key: String, type: java.lang.reflect.Type): T? {

        val memEntry = memoryCache[key] as? CacheEntry<T>
        if (memEntry != null && !memEntry.isExpired()) {
            return memEntry.data
        }
        

        val diskEntry = diskCache[key]
        if (diskEntry != null && !diskEntry.isExpired()) {
            try {
                val data = gson.fromJson<T>(diskEntry.json, type)
                

                if (data != null) {
                    val memEntry = CacheEntry(data, diskEntry.timestamp, diskEntry.ttlMillis)
                    memoryCache[key] = memEntry as CacheEntry<Any>
                }
                
                return data
            } catch (e: Exception) {

            }
        }

        if (prefs.contains(key)) {
            val timestamp = prefs.getLong("${key}_timestamp", 0)
            val ttl = prefs.getLong("${key}_ttl", 15 * 60 * 1000)
            

            if (System.currentTimeMillis() - timestamp < ttl) {
                try {
                    val json = prefs.getString(key, null)
                    if (json != null) {
                        val data = gson.fromJson<T>(json, type)
                        

                        if (data != null) {
                            val memEntry = CacheEntry(data, timestamp, ttl)
                            memoryCache[key] = memEntry as CacheEntry<Any>
                            
                            val diskEntry = DiskCacheEntry(json, timestamp, ttl)
                            diskCache[key] = diskEntry
                        }
                        
                        return data
                    }
                } catch (e: Exception) {

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
        

        val entry = CacheEntry(data, System.currentTimeMillis(), ttlMillis)
        memoryCache[key] = entry as CacheEntry<Any>
        

        try {
            val json = gson.toJson(data)
            val diskEntry = DiskCacheEntry(json, System.currentTimeMillis(), ttlMillis)
            diskCache[key] = diskEntry
            

            prefs.edit().putString(key, json).apply()
            prefs.edit().putLong("${key}_timestamp", System.currentTimeMillis()).apply()
            prefs.edit().putLong("${key}_ttl", ttlMillis).apply()
        } catch (e: Exception) {

        }
    }
    

    fun hasValidCache(key: String): Boolean {

        val memEntry = memoryCache[key]
        if (memEntry != null && !memEntry.isExpired()) {
            return true
        }
        

        val diskEntry = diskCache[key]
        if (diskEntry != null && !diskEntry.isExpired()) {
            return true
        }
        

        if (prefs.contains(key)) {
            val timestamp = prefs.getLong("${key}_timestamp", 0)
            val ttl = prefs.getLong("${key}_ttl", 15 * 60 * 1000)
            return System.currentTimeMillis() - timestamp < ttl
        }
        
        return false
    }
    

    fun clear(key: String) {
        memoryCache.remove(key)
        diskCache.remove(key)
        prefs.edit().remove(key)
            .remove("${key}_timestamp")
            .remove("${key}_ttl")
            .apply()
    }

    fun clearAll() {
        memoryCache.clear()
        diskCache.clear()
        prefs.edit().clear().apply()
    }
}


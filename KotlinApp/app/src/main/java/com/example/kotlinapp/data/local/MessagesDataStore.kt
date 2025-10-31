package com.example.kotlinapp.data.local

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.longPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map

private val Context.messagesDataStore: DataStore<Preferences> by preferencesDataStore(
    name = "messages_preferences"
)

class MessagesDataStore(private val context: Context) {
    
    companion object {
        // Configuración de caché
        private val CACHE_ENABLED = booleanPreferencesKey("cache_enabled")
        private val CACHE_EXPIRY_DAYS = intPreferencesKey("cache_expiry_days")
        private val LAST_SYNC_TIMESTAMP = longPreferencesKey("last_sync_timestamp")
        
        // Configuración de limpieza automática
        private val AUTO_CLEANUP_ENABLED = booleanPreferencesKey("auto_cleanup_enabled")
        private val MESSAGE_RETENTION_DAYS = intPreferencesKey("message_retention_days")
        private val LAST_CLEANUP_TIMESTAMP = longPreferencesKey("last_cleanup_timestamp")
        
        // Configuración offline
        private val OFFLINE_MODE_ENABLED = booleanPreferencesKey("offline_mode_enabled")
        private val SYNC_ON_WIFI_ONLY = booleanPreferencesKey("sync_on_wifi_only")
        
        // Preferencias de usuario
        private val NOTIFICATIONS_ENABLED = booleanPreferencesKey("notifications_enabled")
        private val SOUND_ENABLED = booleanPreferencesKey("sound_enabled")
        
        // Valores por defecto
        const val DEFAULT_CACHE_EXPIRY_DAYS = 7
        const val DEFAULT_MESSAGE_RETENTION_DAYS = 30
    }
    
    // Cache configuration
    val cacheEnabled: Flow<Boolean> = context.messagesDataStore.data
        .map { it[CACHE_ENABLED] ?: true }
    
    val cacheExpiryDays: Flow<Int> = context.messagesDataStore.data
        .map { it[CACHE_EXPIRY_DAYS] ?: DEFAULT_CACHE_EXPIRY_DAYS }
    
    val lastSyncTimestamp: Flow<Long> = context.messagesDataStore.data
        .map { it[LAST_SYNC_TIMESTAMP] ?: 0L }
    
    suspend fun setCacheEnabled(enabled: Boolean) {
        context.messagesDataStore.edit { it[CACHE_ENABLED] = enabled }
    }
    
    suspend fun setCacheExpiryDays(days: Int) {
        context.messagesDataStore.edit { it[CACHE_EXPIRY_DAYS] = days }
    }
    
    suspend fun updateLastSyncTimestamp() {
        context.messagesDataStore.edit { it[LAST_SYNC_TIMESTAMP] = System.currentTimeMillis() }
    }
    
    // Auto cleanup configuration
    val autoCleanupEnabled: Flow<Boolean> = context.messagesDataStore.data
        .map { it[AUTO_CLEANUP_ENABLED] ?: true }
    
    val messageRetentionDays: Flow<Int> = context.messagesDataStore.data
        .map { it[MESSAGE_RETENTION_DAYS] ?: DEFAULT_MESSAGE_RETENTION_DAYS }
    
    val lastCleanupTimestamp: Flow<Long> = context.messagesDataStore.data
        .map { it[LAST_CLEANUP_TIMESTAMP] ?: 0L }
    
    suspend fun setAutoCleanupEnabled(enabled: Boolean) {
        context.messagesDataStore.edit { it[AUTO_CLEANUP_ENABLED] = enabled }
    }
    
    suspend fun setMessageRetentionDays(days: Int) {
        context.messagesDataStore.edit { it[MESSAGE_RETENTION_DAYS] = days }
    }
    
    suspend fun updateLastCleanupTimestamp() {
        context.messagesDataStore.edit { it[LAST_CLEANUP_TIMESTAMP] = System.currentTimeMillis() }
    }
    
    // Offline configuration
    val offlineModeEnabled: Flow<Boolean> = context.messagesDataStore.data
        .map { it[OFFLINE_MODE_ENABLED] ?: false }
    
    val syncOnWifiOnly: Flow<Boolean> = context.messagesDataStore.data
        .map { it[SYNC_ON_WIFI_ONLY] ?: false }
    
    suspend fun setOfflineModeEnabled(enabled: Boolean) {
        context.messagesDataStore.edit { it[OFFLINE_MODE_ENABLED] = enabled }
    }
    
    suspend fun setSyncOnWifiOnly(wifiOnly: Boolean) {
        context.messagesDataStore.edit { it[SYNC_ON_WIFI_ONLY] = wifiOnly }
    }
    
    // User preferences
    val notificationsEnabled: Flow<Boolean> = context.messagesDataStore.data
        .map { it[NOTIFICATIONS_ENABLED] ?: true }
    
    val soundEnabled: Flow<Boolean> = context.messagesDataStore.data
        .map { it[SOUND_ENABLED] ?: true }
    
    suspend fun setNotificationsEnabled(enabled: Boolean) {
        context.messagesDataStore.edit { it[NOTIFICATIONS_ENABLED] = enabled }
    }
    
    suspend fun setSoundEnabled(enabled: Boolean) {
        context.messagesDataStore.edit { it[SOUND_ENABLED] = enabled }
    }
    
    // Helper methods
    suspend fun shouldPerformCleanup(): Boolean {
        val prefs = context.messagesDataStore.data.first()
        val autoCleanup = prefs[AUTO_CLEANUP_ENABLED] ?: true
        if (!autoCleanup) return false
        
        val lastCleanup = prefs[LAST_CLEANUP_TIMESTAMP] ?: 0L
        val oneDayInMillis = 24 * 60 * 60 * 1000L
        return (System.currentTimeMillis() - lastCleanup) > oneDayInMillis
    }
    
    suspend fun getCacheExpiryTimestamp(): Long {
        val prefs = context.messagesDataStore.data.first()
        val days = prefs[CACHE_EXPIRY_DAYS] ?: DEFAULT_CACHE_EXPIRY_DAYS
        return System.currentTimeMillis() - (days * 24 * 60 * 60 * 1000L)
    }
    
    suspend fun getRetentionCutoffTimestamp(): Long {
        val prefs = context.messagesDataStore.data.first()
        val days = prefs[MESSAGE_RETENTION_DAYS] ?: DEFAULT_MESSAGE_RETENTION_DAYS
        return System.currentTimeMillis() - (days * 24 * 60 * 60 * 1000L)
    }
}


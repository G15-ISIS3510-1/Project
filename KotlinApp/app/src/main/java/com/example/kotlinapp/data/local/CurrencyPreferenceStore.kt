package com.example.kotlinapp.data.local

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.longPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map

// 🔹 Top-level extension to create the DataStore
val Context.currencyDataStore by preferencesDataStore(name = "currency_prefs")

/**
 * CurrencyPreferenceStore acts as a persistent cache layer.
 * Saves user's preferred currency and last detected suggestion.
 * Strategy: Persistent Cache (DataStore + time-based invalidation)
 */
class CurrencyPreferenceStore(private val context: Context) {

    private val PREF = stringPreferencesKey("preferred_currency")
    private val LAST = stringPreferencesKey("last_suggested_currency")
    private val LAST_UPDATED = longPreferencesKey("last_cache_time")

    val preferredFlow = context.currencyDataStore.data.map { it[PREF] }
    suspend fun preferredOnce(): String? = preferredFlow.first()

    suspend fun setPreferred(code: String) {
        context.currencyDataStore.edit {
            it[PREF] = code
            it[LAST_UPDATED] = System.currentTimeMillis()
        }
    }

    suspend fun clearPreferred() {
        context.currencyDataStore.edit { it.remove(PREF) }
    }

    suspend fun setLastSuggested(code: String) {
        context.currencyDataStore.edit {
            it[LAST] = code
            it[LAST_UPDATED] = System.currentTimeMillis()
        }
    }

    suspend fun getLastSuggested(): String? =
        context.currencyDataStore.data.map { it[LAST] }.first()

    suspend fun getLastUpdated(): Long? {
        val prefs = context.currencyDataStore.data.first()

        // 🧩 Compatibility fix:
        // If the old "last_cache_time" value was stored as String, remove it once.
        val old = prefs.asMap().entries.find { it.key.name == "last_cache_time" }?.value
        if (old is String) {
            context.currencyDataStore.edit { it.remove(LAST_UPDATED) }
            return null
        }

        return prefs[LAST_UPDATED]
    }
}

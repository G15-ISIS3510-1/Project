package com.example.kotlinapp.data.local

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map

// 🔹 Top-level extension para crear el DataStore
val Context.currencyDataStore by preferencesDataStore(name = "currency_prefs")

/**
 * CurrencyPreferenceStore actúa como una capa de CACHÉ persistente.
 * Guarda la moneda preferida por el usuario y la última sugerencia detectada.
 *
 * Estrategia aplicada: Persistent Cache (DataStore)
 *  - DataStore almacena pares clave-valor de forma asincrónica.
 *  - Ideal para guardar configuraciones y datos livianos.
 */
class CurrencyPreferenceStore(private val context: Context) {

    private val PREF = stringPreferencesKey("preferred_currency")
    private val LAST = stringPreferencesKey("last_suggested_currency")
    private val LAST_UPDATED = stringPreferencesKey("last_cache_time")

    val preferredFlow = context.currencyDataStore.data.map { it[PREF] }
    suspend fun preferredOnce(): String? = preferredFlow.first()

    suspend fun setPreferred(code: String) {
        context.currencyDataStore.edit {
            it[PREF] = code
            it[LAST_UPDATED] = System.currentTimeMillis().toString()
        }
    }

    suspend fun clearPreferred() {
        context.currencyDataStore.edit { it.remove(PREF) }
    }

    suspend fun setLastSuggested(code: String) {
        context.currencyDataStore.edit {
            it[LAST] = code
            it[LAST_UPDATED] = System.currentTimeMillis().toString()
        }
    }

    suspend fun getLastSuggested(): String? =
        context.currencyDataStore.data.map { it[LAST] }.first()

    suspend fun getLastUpdated(): Long? =
        context.currencyDataStore.data.map { it[LAST_UPDATED]?.toLongOrNull() }.first()
}

package com.example.kotlinapp.data.local

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map

// Top-level extension (requerido por DataStore)
val Context.currencyDataStore by preferencesDataStore(name = "currency_prefs")

class CurrencyPreferenceStore(private val context: Context) {
    private val PREF = stringPreferencesKey("preferred_currency")
    private val LAST = stringPreferencesKey("last_suggested_currency")

    val preferredFlow = context.currencyDataStore.data.map { it[PREF] }
    suspend fun preferredOnce(): String? = preferredFlow.first()

    suspend fun setPreferred(code: String) {
        context.currencyDataStore.edit { it[PREF] = code }
    }
    suspend fun clearPreferred() {
        context.currencyDataStore.edit { it.remove(PREF) }
    }

    suspend fun setLastSuggested(code: String) {
        context.currencyDataStore.edit { it[LAST] = code }
    }
}

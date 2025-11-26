package com.example.kotlinapp.data.local

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map

val Context.insuranceDataStore by preferencesDataStore(name = "insurance_prefs")

class InsurancePreferenceStore(private val context: Context) {
    private val SELECTED_INSURANCE = stringPreferencesKey("selected_insurance")

    val selectedFlow = context.insuranceDataStore.data.map { it[SELECTED_INSURANCE] }

    suspend fun getSelected(): String? = selectedFlow.first()

    suspend fun setSelected(value: String) {
        context.insuranceDataStore.edit { it[SELECTED_INSURANCE] = value }
    }
}

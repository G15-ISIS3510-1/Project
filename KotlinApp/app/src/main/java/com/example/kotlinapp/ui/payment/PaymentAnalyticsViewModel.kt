package com.example.kotlinapp.ui.payment

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.kotlinapp.data.repository.PaymentAnalyticsRepository
import com.example.kotlinapp.domain.usecase.GetPaymentMethodAdoption
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch


class PaymentAnalyticsViewModel : ViewModel() {
    private val repo = PaymentAnalyticsRepository()
    private val getAdoption = GetPaymentMethodAdoption(repo)

    private val _analytics = MutableStateFlow<List<PaymentMethodAnalytics>>(emptyList())
    val analytics: StateFlow<List<PaymentMethodAnalytics>> = _analytics

    private val _loading = MutableStateFlow(false)
    val loading: StateFlow<Boolean> = _loading

    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error

    init {
        loadAnalytics()
    }

    fun loadAnalytics() {
        viewModelScope.launch {
            _loading.value = true
            _error.value = null

            try {
                // IMplementacion patrón use case (no el repo directamente)
                val data = getAdoption()
                _analytics.value = data
            } catch (e: Exception) {
                _error.value = e.message ?: "Unknown error"
            } finally {
                _loading.value = false
            }
        }
    }
}

data class PaymentMethodAnalytics(
    val name: String,
    val count: Int,
    val percentage: Double
)
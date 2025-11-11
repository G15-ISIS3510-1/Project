package com.example.kotlinapp.ui.payment

import android.app.Application
import android.util.Log
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.kotlinapp.data.repository.PaymentAnalyticsRepository
import com.example.kotlinapp.data.utils.NetworkMonitor
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

class PaymentAnalyticsViewModel(
    application: Application
) : AndroidViewModel(application) {

    private val repo = PaymentAnalyticsRepository(application.applicationContext)
    private val networkMonitor = NetworkMonitor(application)

    val analytics: StateFlow<List<PaymentMethodAnalytics>> = repo.observeAnalytics()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    private val _loading = MutableStateFlow(false)
    val loading: StateFlow<Boolean> = _loading

    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error


    private val _isOffline = MutableStateFlow(false)
    val isOffline: StateFlow<Boolean> = _isOffline

    private val _showCacheBanner = MutableStateFlow(false)
    val showCacheBanner: StateFlow<Boolean> = _showCacheBanner

    init {

        viewModelScope.launch {
            networkMonitor.isConnected.collect { connected ->
                _isOffline.value = !connected

                if (connected) {

                    Log.d("PaymentVM", "Internet recuperado, sincronizando automáticamente...")
                    loadAnalytics()
                } else {

                    Log.d("PaymentVM", "Sin internet")
                    if (analytics.value.isNotEmpty()) {
                        _showCacheBanner.value = true
                    }
                }
            }
        }


        loadAnalytics()
    }

    fun loadAnalytics() {
        viewModelScope.launch {
            _loading.value = true
            _error.value = null

            val result = repo.syncAnalytics()

            result.fold(
                onSuccess = {

                    _showCacheBanner.value = false
                    _error.value = null

                },
                onFailure = { e ->
                    if (analytics.value.isNotEmpty()) {

                        _showCacheBanner.value = true
                        _error.value = null
                        Log.d("PaymentVM", "Usando cache (${analytics.value.size} métodos)")
                    } else {

                        _showCacheBanner.value = false
                        _error.value = e.message ?: "No internet connection"
                        Log.e("PaymentVM", "Error: ${e.message}")
                    }
                }
            )

            _loading.value = false
        }
    }
}

data class PaymentMethodAnalytics(
    val name: String,
    val count: Int,
    val percentage: Double
)

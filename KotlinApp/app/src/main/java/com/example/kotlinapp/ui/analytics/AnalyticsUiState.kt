package com.example.kotlinapp.ui.analytics

import com.example.kotlinapp.data.models.PriceAnalytics

sealed class AnalyticsUiState {
    object Initial : AnalyticsUiState()
    object Loading : AnalyticsUiState()
    data class Success(val analytics: PriceAnalytics) : AnalyticsUiState()
    data class Error(val message: String) : AnalyticsUiState()
}
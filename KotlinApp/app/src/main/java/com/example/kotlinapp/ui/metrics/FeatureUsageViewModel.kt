package com.example.kotlinapp.ui.metrics

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.kotlinapp.data.repository.FeatureUsageRepository
import com.example.kotlinapp.data.remote.dto.FeatureStatDto
import com.example.kotlinapp.data.remote.dto.FeatureUsageItemDto
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class FeatureUsageViewModel : ViewModel() {
    private val repository = FeatureUsageRepository()
    
    private val _lowUsageFeatures = MutableStateFlow<List<FeatureUsageItemDto>>(emptyList())
    val lowUsageFeatures: StateFlow<List<FeatureUsageItemDto>> = _lowUsageFeatures
    
    private val _usageStats = MutableStateFlow<List<FeatureStatDto>>(emptyList())
    val usageStats: StateFlow<List<FeatureStatDto>> = _usageStats
    
    private val _loading = MutableStateFlow(false)
    val loading: StateFlow<Boolean> = _loading
    
    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error
    
    init {
        loadData()
    }
    
    fun loadData(weeks: Int = 4, threshold: Double = 2.0) {
        viewModelScope.launch {
            _loading.value = true
            _error.value = null
            
            try {
                val lowUsage = repository.getLowUsageFeatures(weeks, threshold)
                val stats = repository.getFeatureUsageStats(null, weeks)
                
                _lowUsageFeatures.value = lowUsage
                _usageStats.value = stats
            } catch (e: Exception) {
                _error.value = e.message ?: "Unknown error"
            } finally {
                _loading.value = false
            }
        }
    }
    
    fun refresh() {
        loadData()
    }
}


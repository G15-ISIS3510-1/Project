package com.example.kotlinapp.ui.metrics

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.kotlinapp.data.repository.FeatureUsageRepository
import com.example.kotlinapp.data.remote.dto.ChatTimeStatsDto
import com.example.kotlinapp.data.remote.dto.FeatureStatDto
import com.example.kotlinapp.data.remote.dto.FeatureUsageItemDto
import kotlinx.coroutines.async
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class FeatureUsageViewModel : ViewModel() {
    private val repository = FeatureUsageRepository()
    
    private val _lowUsageFeatures = MutableStateFlow<List<FeatureUsageItemDto>>(emptyList())
    val lowUsageFeatures: StateFlow<List<FeatureUsageItemDto>> = _lowUsageFeatures
    
    private val _usageStats = MutableStateFlow<List<FeatureStatDto>>(emptyList())
    val usageStats: StateFlow<List<FeatureStatDto>> = _usageStats
    
    private val _chatTimeStats = MutableStateFlow<ChatTimeStatsDto?>(null)
    val chatTimeStats: StateFlow<ChatTimeStatsDto?> = _chatTimeStats
    
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
                Log.d("FeatureUsageViewModel", "Starting to load metrics data")
                // Intentar cargar todas las llamadas en paralelo para ser más rápido
                val lowUsageDeferred = async { 
                    Log.d("FeatureUsageViewModel", "Fetching low usage features")
                    repository.getLowUsageFeatures(weeks, threshold) 
                }
                val statsDeferred = async { 
                    Log.d("FeatureUsageViewModel", "Fetching usage stats")
                    repository.getFeatureUsageStats(null, weeks) 
                }
                val chatTimeStatsDeferred = async {
                    Log.d("FeatureUsageViewModel", "Fetching chat time stats")
                    repository.getChatTimeStats(weeks)
                }
                
                // Esperar todas las respuestas
                val lowUsage = lowUsageDeferred.await()
                val stats = statsDeferred.await()
                val chatTimeStats = chatTimeStatsDeferred.await()
                
                Log.d("FeatureUsageViewModel", "Data loaded successfully: ${lowUsage.size} low usage, ${stats.size} stats, chatTimeStats=${chatTimeStats != null}")
                _lowUsageFeatures.value = lowUsage
                _usageStats.value = stats
                _chatTimeStats.value = chatTimeStats
            } catch (e: Exception) {
                Log.e("FeatureUsageViewModel", "Error loading data", e)
                _error.value = e.message ?: "Error desconocido al cargar métricas"
            } finally {
                _loading.value = false
                Log.d("FeatureUsageViewModel", "Loading completed")
            }
        }
    }
    
    fun refresh() {
        loadData()
    }
}


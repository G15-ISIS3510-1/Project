package com.example.kotlinapp.data.repository

import com.example.kotlinapp.data.api.AnalyticsApiService
import com.example.kotlinapp.data.api.BackendApis
import com.example.kotlinapp.data.remote.dto.FeatureUsageItemDto
import com.example.kotlinapp.data.remote.dto.FeatureStatDto

class FeatureUsageRepository(
    private val api: AnalyticsApiService = BackendApis.analytics
) {
    suspend fun getLowUsageFeatures(
        weeks: Int = 4,
        threshold: Double = 2.0
    ): List<FeatureUsageItemDto> {
        val response = api.getLowUsageFeatures(weeks, threshold)
        
        if (!response.isSuccessful) {
            throw Exception("HTTP ${response.code()}: ${response.message()}")
        }
        
        val body = response.body() ?: throw Exception("Empty response")
        return body.features
    }
    
    suspend fun getFeatureUsageStats(
        featureName: String? = null,
        weeks: Int = 4
    ): List<FeatureStatDto> {
        val response = api.getFeatureUsageStats(featureName, weeks)
        
        if (!response.isSuccessful) {
            throw Exception("HTTP ${response.code()}: ${response.message()}")
        }
        
        val body = response.body() ?: throw Exception("Empty response")
        return body.stats
    }
}


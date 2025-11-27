package com.example.kotlinapp.data.api

import com.example.kotlinapp.data.remote.dto.ChatTimeStatsDto
import com.example.kotlinapp.data.remote.dto.FeatureUsageLogRequest
import com.example.kotlinapp.data.remote.dto.FeatureUsageLogResponse
import com.example.kotlinapp.data.remote.dto.FeatureUsageStatsDto
import com.example.kotlinapp.data.remote.dto.LowUsageFeaturesDto
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Query

interface AnalyticsApiService {
    @GET("api/analytics/features/low-usage")
    suspend fun getLowUsageFeatures(
        @Query("weeks") weeks: Int = 4,
        @Query("threshold") threshold: Double = 2.0
    ): Response<LowUsageFeaturesDto>
    
    @GET("api/analytics/features/usage-stats")
    suspend fun getFeatureUsageStats(
        @Query("feature_name") featureName: String? = null,
        @Query("weeks") weeks: Int = 4
    ): Response<FeatureUsageStatsDto>

    @GET("api/analytics/features/chat-time-stats")
    suspend fun getChatTimeStats(
        @Query("weeks") weeks: Int = 4
    ): Response<ChatTimeStatsDto>

    @POST("api/analytics/features/usage-log")
    suspend fun logFeatureUsage(
        @Body payload: FeatureUsageLogRequest
    ): Response<FeatureUsageLogResponse>
}


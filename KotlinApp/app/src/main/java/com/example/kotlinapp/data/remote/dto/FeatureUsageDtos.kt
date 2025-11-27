package com.example.kotlinapp.data.remote.dto

import com.google.gson.annotations.SerializedName

data class LowUsageFeaturesDto(
    val features: List<FeatureUsageItemDto>,
    val weeks: Int,
    val threshold: Double,
    @SerializedName("total_count")
    val totalCount: Int
)

data class FeatureUsageItemDto(
    @SerializedName("feature_name")
    val featureName: String,
    @SerializedName("avg_uses_per_week_per_user")
    val avgUsesPerWeekPerUser: Double,
    @SerializedName("total_uses")
    val totalUses: Int,
    @SerializedName("unique_users")
    val uniqueUsers: Int
)

data class FeatureUsageStatsDto(
    val stats: List<FeatureStatDto>,
    val weeks: Int,
    @SerializedName("feature_filter")
    val featureFilter: String?,
    @SerializedName("total_features")
    val totalFeatures: Int
)

data class FeatureStatDto(
    @SerializedName("feature_name")
    val featureName: String,
    @SerializedName("total_uses")
    val totalUses: Int,
    @SerializedName("unique_users")
    val uniqueUsers: Int,
    @SerializedName("avg_uses_per_user")
    val avgUsesPerUser: Double,
    @SerializedName("avg_uses_per_week_per_user")
    val avgUsesPerWeekPerUser: Double
)

data class FeatureUsageLogRequest(
    @SerializedName("feature_name")
    val featureName: String,
    @SerializedName("duration_seconds")
    val durationSeconds: Double?,
    @SerializedName("duration_ms")
    val durationMs: Long?,
    @SerializedName("origin_route")
    val originRoute: String?,
    @SerializedName("destination_route")
    val destinationRoute: String?,
    val metadata: Map<String, Any?>?
)

data class FeatureUsageLogResponse(
    val id: Int,
    @SerializedName("feature_name")
    val featureName: String,
    @SerializedName("user_id")
    val userId: String,
    @SerializedName("duration_seconds")
    val durationSeconds: Double?,
    val timestamp: String,
    val metadata: Map<String, Any?>?
)


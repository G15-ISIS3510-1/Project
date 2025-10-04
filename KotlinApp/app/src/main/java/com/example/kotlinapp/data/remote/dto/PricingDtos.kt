package com.example.kotlinapp.data.remote.dto

data class PricingCreate(
    val vehicle_id: String,
    val daily_price: Double,             // Pydantic: float > 0
    val min_days: Int,                   // >=1
    val max_days: Int?,                  // opcional
    val currency: String = "USD"         // 3 letras
)

data class PricingUpdate(
    val daily_price: Double? = null,
    val min_days: Int? = null,
    val max_days: Int? = null,
    val currency: String? = null
)

data class PricingResponse(
    val pricing_id: String,
    val vehicle_id: String,
    val daily_price: Double,
    val min_days: Int,
    val max_days: Int?,
    val currency: String,
    val last_updated: String // ISO-8601
)

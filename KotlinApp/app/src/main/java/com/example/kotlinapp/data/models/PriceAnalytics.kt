package com.example.kotlinapp.data.models

import com.example.kotlinapp.data.remote.dto.VehicleWithPricingResponse

data class PriceAnalytics(
    val currentAvgPrice: Double,
    val totalVehicles: Int,
    val radiusKm: Double,
    val userLocation: Location,
    val nearbyVehicles: List<VehicleWithPricingResponse>
)

data class Location(
    val lat: Double,
    val lng: Double
)


data class VehicleWithPricing(
    val id: String,
    val brand: String,
    val model: String,
    val year: Int,
    val transmission: String,
    val imageUrl: String?,
    val status: String,
    val dailyRate: Double,
    val currency: String,
    val minDays: Int,
    val maxDays: Int?,
    // Añade estos campos si no los tienes
    val lat: Double? = null,
    val lng: Double? = null
)

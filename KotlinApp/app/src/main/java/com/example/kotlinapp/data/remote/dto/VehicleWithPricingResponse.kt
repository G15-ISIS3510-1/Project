package com.example.kotlinapp.data.remote.dto

data class VehicleWithPricingResponse(
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
    val maxDays: Int?
)
package com.example.kotlinapp.data.remote.dto

data class VehicleListResponse(
    val items: List<VehicleWithPricingResponse>,
    val total: Int,
    val skip: Int,
    val limit: Int
)
package com.example.kotlinapp.data.remote.dto

// VehicleCreate = VehicleBase (sin owner_id; el backend usa el del token)
data class VehicleCreate(
    val make: String,
    val model: String,
    val year: Int,                        // 1900..2030
    val plate: String,
    val seats: Int,                       // 1..50
    val transmission: String,
    val fuel_type: String,
    val mileage: Int,                     // >=0
    val status: String,                   // "active" | "inactive" | "pending_review"
    val lat: Double,
    val lng: Double,
    val photo_url: String? = null
)

data class VehicleResponse(
    val vehicle_id: String,
    val owner_id: String,
    val make: String,
    val model: String,
    val year: Int,
    val plate: String,
    val seats: Int,
    val transmission: String,
    val fuel_type: String,
    val mileage: Int,
    val status: String,
    val lat: Double,
    val lng: Double,
    val created_at: String,
    val photo_url: String? = null
)

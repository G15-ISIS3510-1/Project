package com.example.kotlinapp.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "vehicle_locations")
data class VehicleLocationEntity(
    @PrimaryKey
    val vehicle_id: String,
    val lat: Double,
    val lng: Double,
    val make: String,
    val model: String,
    val year: Int,
    val dailyPrice: Double,
    val plate: String,
    val seats: Int,
    val transmission: String,
    val fuel_type: String,
    val mileage: Int,
    val status: String,
    val photo_url: String? = null,
    val updatedAt: Long,
    val source: String = "cache"
)
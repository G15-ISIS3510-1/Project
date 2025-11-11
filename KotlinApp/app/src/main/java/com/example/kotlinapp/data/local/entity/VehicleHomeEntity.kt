package com.example.kotlinapp.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "vehicle_home_cache")
data class VehicleHomeEntity(
    @PrimaryKey
    val vehicleId: String,
    val brand: String,
    val model: String,
    val year: Int,
    val transmission: String,
    val category: String,
    val dailyRate: Double,
    val currency: String,
    val imageUrl: String?,
    val cachedAt: Long = System.currentTimeMillis()
)
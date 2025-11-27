package com.example.kotlinapp.data.local.entity



import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "availability_cache")
data class AvailabilityCacheEntity(
    @PrimaryKey
    val availabilityId: String,
    val vehicleId: String,
    val startDate: String,
    val endDate: String,
    val status: String,
    val reason: String?,
    val updatedAt: Long
)

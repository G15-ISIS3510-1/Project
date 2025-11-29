package com.example.kotlinapp.data.local.entity


import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "pending_availabilities")
data class PendingAvailabilityEntity(
    @PrimaryKey
    val localId: String,

    val vehicleId: String,
    val startDate: String,
    val endDate: String,
    val status: String,
    val reason: String?,


    val operationType: String,


    val remoteAvailabilityId: String?,


    val syncStatus: String,
    val attempts: Int = 0,
    val lastError: String? = null,

    val createdAt: Long,
    val updatedAt: Long
)
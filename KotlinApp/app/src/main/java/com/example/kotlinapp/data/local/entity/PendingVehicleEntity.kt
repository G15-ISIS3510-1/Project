package com.example.kotlinapp.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "pending_vehicles")
data class PendingVehicleEntity(
    @PrimaryKey
    val localId: String,

    // Datos del vehículo
    val make: String,
    val model: String,
    val year: Int,
    val plate: String,
    val seats: Int,
    val transmission: String,
    val fuelType: String,
    val mileage: Int,
    val lat: Double,
    val lng: Double,

    // Datos del pricing
    val dailyPrice: Double,
    val minDays: Int,
    val maxDays: Int?,
    val currency: String,

    // Foto local
    val photoPath: String?,  // Ruta al archivo de foto local

    // Estado de sincronización
    val syncStatus: String,  // "PENDING", "UPLOADING", "SYNCED", "ERROR"
    val remoteVehicleId: String?,
    val remotePricingId: String?,

    // Control de reintentos
    val attempts: Int = 0,
    val lastError: String? = null,

    // Timestamps
    val createdAt: Long,
    val updatedAt: Long
)
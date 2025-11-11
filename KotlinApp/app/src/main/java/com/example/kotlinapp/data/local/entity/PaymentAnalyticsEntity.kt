package com.example.kotlinapp.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "payment_analytics")
data class PaymentAnalyticsEntity(
    @PrimaryKey
    val methodName: String,
    val transactionCount: Int,
    val percentage: Double,
    val cachedAt: Long = System.currentTimeMillis()
)
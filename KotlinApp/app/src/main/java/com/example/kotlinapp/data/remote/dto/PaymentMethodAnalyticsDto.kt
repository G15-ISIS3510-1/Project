package com.example.kotlinapp.data.remote.dto

data class PaymentMethodAnalyticsDto(
    val name: String,
    val count: Int,
    val percentage: Double?
)
package com.example.kotlinapp.data.remote.dto

data class VehicleListHomeResponse(
    val items: List<VehicleResponse>,
    val total: Int,
    val skip: Int,
    val limit: Int
)
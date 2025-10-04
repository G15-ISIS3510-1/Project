package com.example.kotlinapp.data.models

import com.google.gson.annotations.SerializedName

data class TopRatedVehicleSearch(
    @SerializedName("start_ts")
    val startTs: String,
    
    @SerializedName("end_ts")
    val endTs: String,
    
    @SerializedName("lat")
    val latitude: Double,
    
    @SerializedName("lng")
    val longitude: Double,
    
    @SerializedName("radius_km")
    val radiusKm: Double = 50.0,
    
    @SerializedName("limit")
    val limit: Int = 3
)

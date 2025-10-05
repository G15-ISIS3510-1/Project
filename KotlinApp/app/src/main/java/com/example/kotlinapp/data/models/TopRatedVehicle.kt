package com.example.kotlinapp.data.models

import com.google.gson.annotations.SerializedName

data class TopRatedVehicle(
    @SerializedName("vehicle_id")
    val vehicleId: String,
    
    @SerializedName("make")
    val make: String,
    
    @SerializedName("model")
    val model: String,
    
    @SerializedName("year")
    val year: Int,
    
    @SerializedName("seats")
    val seats: Int,
    
    @SerializedName("transmission")
    val transmission: String,
    
    @SerializedName("fuel_type")
    val fuelType: String,
    
    @SerializedName("mileage")
    val mileage: Int,
    
    @SerializedName("lat")
    val latitude: Double,
    
    @SerializedName("lng")
    val longitude: Double,
    
    @SerializedName("photo_url")
    val photoUrl: String?,
    
    @SerializedName("average_rating")
    val averageRating: Double,
    
    @SerializedName("total_ratings")
    val totalRatings: Int,
    
    @SerializedName("distance_km")
    val distanceKm: Double,
    
    @SerializedName("daily_price")
    val dailyPrice: Double?,
    
    @SerializedName("currency")
    val currency: String?,
    
    @SerializedName("owner_name")
    val ownerName: String
) {
    val displayName: String
        get() = "$make $model ($year)"
    
    val ratingText: String
        get() = String.format("%.1f ⭐ (%d calificaciones)", averageRating, totalRatings)
    
    val priceText: String
        get() = if (dailyPrice != null && currency != null) {
            "$${String.format("%.0f", dailyPrice)} $currency/día"
        } else {
            "Precio no disponible"
        }
    
    val distanceText: String
        get() = String.format("%.1f km de distancia", distanceKm)
    
    val fuelTypeText: String
        get() = when (fuelType.lowercase()) {
            "gas" -> "Gasolina"
            "diesel" -> "Diésel"
            "hybrid" -> "Híbrido"
            "ev" -> "Eléctrico"
            else -> fuelType
        }
    
    val transmissionText: String
        get() = when (transmission.uppercase()) {
            "AT" -> "Automático"
            "MT" -> "Manual"
            "CVT" -> "CVT"
            "EV" -> "Eléctrico"
            else -> transmission
        }
    
    val ownerText: String
        get() = "Propietario: $ownerName"
}

package com.example.kotlinapp.data.remote.dto
import com.example.kotlinapp.ui.home.VehicleItem

data class VehicleCreate(
    val make: String,
    val model: String,
    val year: Int,
    val plate: String,
    val seats: Int,
    val transmission: String,
    val fuel_type: String,
    val mileage: Int,
    val status: String,
    val lat: Double,
    val lng: Double,
    val photo_url: String? = null
)

data class VehicleResponse(
    val vehicle_id: String,
    val owner_id: String,
    val make: String,
    val model: String,
    val year: Int,
    val plate: String,
    val seats: Int,
    val transmission: String,
    val fuel_type: String,
    val mileage: Int,
    val status: String,
    val lat: Double,
    val lng: Double,
    val created_at: String,
    val photo_url: String? = null
)



fun VehicleResponse.toVehicleItem(): VehicleItem {
    return VehicleItem(
        title = "$make $model $year",
        rating = 0.0,
        transmission = when(transmission) {
            "AT" -> "Automatic"
            "MT" -> "Manual"
            "CVT" -> "CVT"
            "EV" -> "Electric"
            else -> transmission
        },
        price = "Contact for price",
        imageUrl = photo_url
    )
}

data class PaginatedVehicleResponse(
    val items: List<VehicleResponse>,
    val total: Int,
    val skip: Int,
    val limit: Int
)

package com.example.kotlinapp.data.repository

import com.example.kotlinapp.data.api.VehicleRatingApi
import com.example.kotlinapp.data.models.TopRatedVehicle
import com.example.kotlinapp.data.models.TopRatedVehicleSearch
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.text.SimpleDateFormat
import java.util.*

class VehicleRatingRepository(
    private val api: VehicleRatingApi
) {
    
    suspend fun getTopRatedVehicles(
        token: String,
        startDate: Date,
        endDate: Date,
        latitude: Double,
        longitude: Double,
        radiusKm: Double = 50.0,
        limit: Int = 3
    ): Result<List<TopRatedVehicle>> = withContext(Dispatchers.IO) {
        try {
            val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.getDefault())
            dateFormat.timeZone = TimeZone.getTimeZone("UTC")
            
            val searchParams = TopRatedVehicleSearch(
                startTs = dateFormat.format(startDate),
                endTs = dateFormat.format(endDate),
                latitude = latitude,
                longitude = longitude,
                radiusKm = radiusKm,
                limit = limit
            )
            
            val response = api.getTopRatedVehicles("Bearer $token", searchParams)
            
            if (response.isSuccessful) {
                Result.success(response.body() ?: emptyList())
            } else {
                Result.failure(Exception("Error: ${response.code()} - ${response.message()}"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun getVehicleRatings(
        token: String,
        vehicleId: String
    ): Result<List<com.example.kotlinapp.data.api.VehicleRating>> = withContext(Dispatchers.IO) {
        try {
            val response = api.getVehicleRatings("Bearer $token", vehicleId)
            
            if (response.isSuccessful) {
                Result.success(response.body() ?: emptyList())
            } else {
                Result.failure(Exception("Error: ${response.code()} - ${response.message()}"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}

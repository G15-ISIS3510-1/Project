package com.example.kotlinapp.data.api

import com.example.kotlinapp.data.models.TopRatedVehicle
import com.example.kotlinapp.data.models.TopRatedVehicleSearch
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.POST
import retrofit2.http.Path

interface VehicleRatingApi {
    
    @POST("vehicle-ratings/search/top-rated")
    suspend fun getTopRatedVehicles(
        @Header("Authorization") token: String,
        @Body searchParams: TopRatedVehicleSearch
    ): Response<List<TopRatedVehicle>>
    
    @GET("vehicle-ratings/vehicle/{vehicle_id}")
    suspend fun getVehicleRatings(
        @Header("Authorization") token: String,
        @Path("vehicle_id") vehicleId: String
    ): Response<List<VehicleRating>>
    
    @GET("vehicle-ratings/{rating_id}")
    suspend fun getRatingById(
        @Header("Authorization") token: String,
        @Path("rating_id") ratingId: String
    ): Response<VehicleRating>
}

data class VehicleRating(
    val rating_id: String,
    val vehicle_id: String,
    val booking_id: String,
    val renter_id: String,
    val rating: Double,
    val comment: String?,
    val created_at: String
)

package com.example.kotlinapp.data.api

import com.example.kotlinapp.data.remote.dto.AvailabilityDto
import com.example.kotlinapp.data.remote.dto.CreateAvailabilityRequest
import com.example.kotlinapp.data.remote.dto.UpdateAvailabilityRequest
import retrofit2.Response
import retrofit2.http.*


data class AvailabilityListResponse(
    val items: List<AvailabilityDto>,
    val total: Int,
    val skip: Int,
    val limit: Int
)
interface AvailabilityApiService {
    @GET("api/vehicle-availability/vehicle/{vehicle_id}")
    suspend fun getAvailabilities(@Path("vehicle_id") vehicleId: String): Response<AvailabilityListResponse>

    @POST("api/vehicle-availability/")
    suspend fun createAvailability(@Body request: CreateAvailabilityRequest): Response<AvailabilityDto>

    @PUT("api/vehicle-availability/{availability_id}")
    suspend fun updateAvailability(
        @Path("availability_id") availabilityId: String,
        @Body request: UpdateAvailabilityRequest
    ): Response<AvailabilityDto>

    @DELETE("api/vehicle-availability/{availability_id}")
    suspend fun deleteAvailability(@Path("availability_id") availabilityId: String): Response<Unit>

    @DELETE("api/vehicle-availability/vehicle/{vehicle_id}")
    suspend fun deleteAllAvailabilities(@Path("vehicle_id") vehicleId: String): Response<Unit>
}
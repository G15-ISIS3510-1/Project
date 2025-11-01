package com.example.kotlinapp.data.api

import com.example.kotlinapp.data.remote.dto.LoginRequest
import com.example.kotlinapp.data.remote.dto.PricingCreate
import com.example.kotlinapp.data.remote.dto.PricingResponse
import com.example.kotlinapp.data.remote.dto.PricingUpdate
import com.example.kotlinapp.data.remote.dto.TokenResponse
import com.example.kotlinapp.data.remote.dto.VehicleCreate
import com.example.kotlinapp.data.remote.dto.VehicleResponse
import com.example.kotlinapp.data.remote.dto.VehicleWithPricingResponse
import okhttp3.MultipartBody
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.Multipart
import retrofit2.http.POST
import retrofit2.http.PUT
import retrofit2.http.Part
import retrofit2.http.Path
import retrofit2.http.Query

interface VehiclesApiService {

    @GET("api/vehicles/active")
    suspend fun getActiveVehicles(): List<VehicleResponse>

    @GET("api/vehicles/active-with-pricing")
    suspend fun getActiveVehiclesWithPricing(
        @Query("search") search: String? = null,
        @Query("category") category: String? = null
    ): List<VehicleWithPricingResponse>
    @POST("api/vehicles/")
    suspend fun createVehicle(@Body body: VehicleCreate): VehicleResponse

    @Multipart
    @POST("api/vehicles/{vehicleId}/upload-photo")
    suspend fun uploadPhoto(
        @Path("vehicleId") vehicleId: String,
        @Part file: MultipartBody.Part
    ): PhotoUploadResponse
}

interface PricingApiService {
    @POST("api/pricing/")
    suspend fun createPricing(@Body body: PricingCreate): PricingResponse

    @GET("api/pricing/vehicle/{vehicleId}")
    suspend fun getPricingByVehicle(@Path("vehicleId") id: String): PricingResponse

    @PUT("api/pricing/vehicle/{vehicleId}")
    suspend fun updatePricingByVehicle(
        @Path("vehicleId") id: String,
        @Body body: PricingUpdate
    ): PricingResponse
}

data class PhotoUploadResponse(
    val photo_url: String,
    val message: String
)


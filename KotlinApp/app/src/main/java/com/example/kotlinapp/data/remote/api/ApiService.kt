package com.example.kotlinapp.data.remote.api

import com.example.kotlinapp.data.remote.dto.LoginRequest
import com.example.kotlinapp.data.remote.dto.PricingCreate
import com.example.kotlinapp.data.remote.dto.PricingResponse
import com.example.kotlinapp.data.remote.dto.PricingUpdate
import com.example.kotlinapp.data.remote.dto.TokenResponse
import com.example.kotlinapp.data.remote.dto.VehicleCreate
import com.example.kotlinapp.data.remote.dto.VehicleResponse
import retrofit2.http.*

interface ApiService {
    // Vehicles (prefix en main.py: /api)
    @POST("api/auth/login")
    suspend fun login(@Body body: LoginRequest): TokenResponse
    @POST("api/vehicles/")
    suspend fun createVehicle(@Body body: VehicleCreate): VehicleResponse

    // Pricing (prefix en main.py: /api/pricing)
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

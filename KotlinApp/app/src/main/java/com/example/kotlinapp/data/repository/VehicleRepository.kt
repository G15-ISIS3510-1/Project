package com.example.kotlinapp.data.repository

import android.util.Log
import com.example.kotlinapp.data.api.BackendApis
import com.example.kotlinapp.data.api.PricingApiService
import com.example.kotlinapp.data.api.VehiclesApiService
import com.example.kotlinapp.data.remote.dto.PricingCreate
import com.example.kotlinapp.data.remote.dto.PricingResponse
import com.example.kotlinapp.data.remote.dto.VehicleCreate
import com.example.kotlinapp.data.remote.dto.VehicleResponse
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import java.io.File

class VehicleRepository(
    private val vehiclesApi: VehiclesApiService = BackendApis.vehicles,
    private val pricingApi: PricingApiService = BackendApis.pricing
) {
    suspend fun createVehicleWithPricing(
        v: VehicleCreate,
        p: PricingCreate,
        photoFile: File?
    ): Pair<VehicleResponse, PricingResponse> {

        val vehicle = vehiclesApi.createVehicle(v)

        if (photoFile != null && photoFile.exists()) {
            try {
                val requestFile = photoFile.asRequestBody("image/jpeg".toMediaTypeOrNull())
                val body = MultipartBody.Part.createFormData("file", photoFile.name, requestFile)
                vehiclesApi.uploadPhoto(vehicle.vehicle_id, body)
                Log.d("VehicleRepository", "Photo uploaded successfully")
            } catch (e: Exception) {

                Log.e("VehicleRepository", "Failed to upload photo: ${e.message}", e)

            }
        }

        val pricing = pricingApi.createPricing(p.copy(vehicle_id = vehicle.vehicle_id))

        return vehicle to pricing
    }
}

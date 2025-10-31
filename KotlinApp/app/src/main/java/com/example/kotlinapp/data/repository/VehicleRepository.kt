package com.example.kotlinapp.data.repository

import android.content.Context
import android.util.Log
import com.example.kotlinapp.data.api.BackendApis
import com.example.kotlinapp.data.api.PricingApiService
import com.example.kotlinapp.data.api.VehiclesApiService
import com.example.kotlinapp.data.local.AppDatabase
import com.example.kotlinapp.data.local.dao.VehicleLocationDao
import com.example.kotlinapp.data.local.entity.VehicleLocationEntity
import com.example.kotlinapp.data.remote.dto.PricingCreate
import com.example.kotlinapp.data.remote.dto.PricingResponse
import com.example.kotlinapp.data.remote.dto.VehicleCreate
import com.example.kotlinapp.data.remote.dto.VehicleResponse
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import java.io.File
import java.net.UnknownHostException

class VehicleRepository(
    private val context: Context? = null,
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

    suspend fun getActiveVehicles(): List<VehicleResponse> {
        return vehiclesApi.getActiveVehicles().items
    }


    private fun getDao(): VehicleLocationDao {
        return requireNotNull(context) {
            "Context is required for cache operations"
        }.let {
            AppDatabase.getDatabase(it).vehicleLocationDao()
        }
    }

    fun getActiveVehiclesFlow(): Flow<List<VehicleMapItem>> {
        val dao = getDao()

        return dao.getAllVehiclesFlow().map { entities ->
            entities.map { it.toMapItem() }
        }
    }

    suspend fun revalidateVehicles(): Result<Unit> {
        val dao = getDao()

        return try {
            val response = getActiveVehicles()
            val entities = response.map { it.toEntity() }

            dao.deleteAll()
            dao.insertVehicles(entities)

            Result.success(Unit)
        } catch (e: UnknownHostException) {
            Log.w("VehicleRepository", "No internet connection, using cache")
            Result.failure(e)
        } catch (e: Exception) {
            Log.e("VehicleRepository", "API error: ${e.message}", e)
            Result.failure(e)
        }
    }


    private fun VehicleResponse.toEntity() = VehicleLocationEntity(
        vehicle_id = this.vehicle_id,
        lat = this.lat,
        lng = this.lng,
        make = this.make,
        model = this.model,
        year = this.year,
        plate = this.plate,
        seats = this.seats,
        transmission = this.transmission,
        fuel_type = this.fuel_type,
        mileage = this.mileage,
        status = this.status,
        photo_url = this.photo_url,
        dailyPrice = 0.0,
        updatedAt = System.currentTimeMillis(),
        source = "network"
    )

    private fun VehicleLocationEntity.toMapItem() = VehicleMapItem(
        vehicleId = this.vehicle_id,
        lat = this.lat,
        lng = this.lng,
        make = this.make,
        model = this.model,
        year = this.year,
        dailyPrice = this.dailyPrice,
        plate = this.plate
    )
}

data class VehicleMapItem(
    val vehicleId: String,
    val lat: Double,
    val lng: Double,
    val make: String,
    val model: String,
    val year: Int,
    val dailyPrice: Double,
    val plate: String
)

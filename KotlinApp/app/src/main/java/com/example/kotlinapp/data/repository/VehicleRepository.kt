package com.example.kotlinapp.data.repository

import android.content.Context
import android.util.Log
import com.example.kotlinapp.data.api.BackendApis
import com.example.kotlinapp.data.api.PricingApiService
import com.example.kotlinapp.data.api.VehiclesApiService
import com.example.kotlinapp.data.local.AppDatabase
import com.example.kotlinapp.data.local.entity.PendingVehicleEntity
import com.example.kotlinapp.data.network.NetworkMonitor
import com.example.kotlinapp.data.local.dao.VehicleLocationDao
import com.example.kotlinapp.data.local.entity.VehicleLocationEntity
import com.example.kotlinapp.data.remote.dto.PricingCreate
import com.example.kotlinapp.data.remote.dto.PricingResponse
import com.example.kotlinapp.data.remote.dto.VehicleCreate
import com.example.kotlinapp.data.remote.dto.VehicleResponse
import com.example.kotlinapp.data.remote.dto.VehicleWithPricingResponse
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.flow.take
import kotlinx.coroutines.withContext
import kotlinx.coroutines.flow.map
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import java.io.File
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import java.net.UnknownHostException

class VehicleRepository(
    private val context: Context? = null,
    private val vehiclesApi: VehiclesApiService = BackendApis.vehicles,
    private val pricingApi: PricingApiService = BackendApis.pricing
) {

    companion object {
        private const val TAG = "VehicleRepository"
    }

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
                Log.d(TAG, "Photo uploaded successfully")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to upload photo: ${e.message}", e)
            }
        }

        val pricing = pricingApi.createPricing(p.copy(vehicle_id = vehicle.vehicle_id))

        return vehicle to pricing
    }


    suspend fun getActiveVehicles(): List<VehicleResponse> = withContext(Dispatchers.IO) {
        return@withContext try {
            Log.d(TAG, "Fetching active vehicles from API...")


            val response = vehiclesApi.getActiveVehicles().items


            val vehicles = response




            vehicles.forEachIndexed { index, vehicle ->
                if (index < 5) {
                    Log.d(TAG, "[$index] ${vehicle.make} ${vehicle.model} - Lat: ${vehicle.lat}, Lng: ${vehicle.lng}")
                }
            }



            vehicles

        } catch (e: Exception) {
            Log.e(TAG, "Error fetching vehicles: ${e.message}", e)
            throw e
        }
    }

    private fun getDao(): VehicleLocationDao {
        return requireNotNull(context) {
            "Context is required for cache operations"
        }.let {
            AppDatabase.getDatabase(it).vehicleLocationDao()
        }
    }



    private val pendingDao by lazy {
        AppDatabase.getDatabase(context!!).pendingVehicleDao()
    }

    private val networkMonitor by lazy {
        NetworkMonitor(context!!)
    }

    suspend fun createVehicleWithRetry(
        vehicle: VehicleCreate,
        pricing: PricingCreate,
        photoFile: File?
    ): Result<String> = withContext(Dispatchers.IO) {

        val localId = java.util.UUID.randomUUID().toString()
        val now = System.currentTimeMillis()


        val savedPhotoPath = photoFile?.let { savePhotoLocally(it, localId) }


        val pendingEntity = PendingVehicleEntity(
            localId = localId,
            make = vehicle.make,
            model = vehicle.model,
            year = vehicle.year,
            plate = vehicle.plate,
            seats = vehicle.seats,
            transmission = vehicle.transmission,
            fuelType = vehicle.fuel_type,
            mileage = vehicle.mileage,
            lat = vehicle.lat,
            lng = vehicle.lng,
            dailyPrice = pricing.daily_price,
            minDays = pricing.min_days,
            maxDays = pricing.max_days,
            currency = pricing.currency,
            photoPath = savedPhotoPath,
            syncStatus = "PENDING",
            remoteVehicleId = null,
            remotePricingId = null,
            attempts = 0,
            lastError = null,
            createdAt = now,
            updatedAt = now
        )

        pendingDao.insert(pendingEntity)
        Log.d(TAG, "Vehículo guardado localmente: $localId")


        if (networkMonitor.isConnected()) {
            Log.d(TAG, "Hay internet, intentando subir inmediatamente")
            uploadPendingVehicle(localId)
        } else {
            Log.d(TAG, "Sin internet, esperando conectividad")

            kotlinx.coroutines.CoroutineScope(Dispatchers.IO).launch {
                monitorAndUpload(localId)
            }
        }

        Result.success(localId)
    }

    private fun savePhotoLocally(sourceFile: File, localId: String): String {
        val photosDir = File(context!!.filesDir, "pending_photos")
        if (!photosDir.exists()) photosDir.mkdirs()

        val destFile = File(photosDir, "$localId.jpg")
        sourceFile.copyTo(destFile, overwrite = true)

        Log.d(TAG, "Foto guardada en: ${destFile.absolutePath}")
        return destFile.absolutePath
    }

    private suspend fun monitorAndUpload(localId: String) = withContext(Dispatchers.IO) {
        networkMonitor.observeConnectivity()
            .filter { it == true }
            .take(1)
            .collect {
                Log.d(TAG, "Internet recuperado, subiendo $localId")
                uploadPendingVehicle(localId)
            }
    }

    suspend fun uploadPendingVehicle(localId: String): Result<Unit> = withContext(Dispatchers.IO) {
        val pending = pendingDao.getById(localId)

        if (pending == null) {
            Log.w(TAG, "Vehículo $localId no encontrado")
            return@withContext Result.failure(Exception("Vehicle not found"))
        }

        if (pending.syncStatus == "SYNCED") {
            Log.d(TAG, "Vehículo $localId ya está sincronizado")
            return@withContext Result.success(Unit)
        }


        pendingDao.updateSyncStatus(localId, "UPLOADING", null, System.currentTimeMillis())

        try {
            Log.d(TAG, "Subiendo vehículo $localId...")

            val vehicleDto = VehicleCreate(
                make = pending.make,
                model = pending.model,
                year = pending.year,
                plate = pending.plate,
                seats = pending.seats,
                transmission = pending.transmission,
                fuel_type = pending.fuelType,
                mileage = pending.mileage,
                status = "active",
                lat = pending.lat,
                lng = pending.lng
            )

            val vehicleResponse = vehiclesApi.createVehicle(vehicleDto)
            val remoteVehicleId = vehicleResponse.vehicle_id

            Log.d(TAG, "Vehículo creado en backend: $remoteVehicleId")


            if (pending.photoPath != null) {
                val photoFile = File(pending.photoPath)
                if (photoFile.exists()) {
                    uploadPhoto(remoteVehicleId, photoFile)
                    Log.d(TAG, "Foto subida")
                }
            }


            val pricingDto = PricingCreate(
                vehicle_id = remoteVehicleId,
                daily_price = pending.dailyPrice,
                min_days = pending.minDays,
                max_days = pending.maxDays,
                currency = pending.currency
            )

            pricingApi.createPricing(pricingDto)
            Log.d(TAG, "Pricing creado")


            pendingDao.updateSyncStatus(
                localId,
                "SYNCED",
                remoteVehicleId,
                System.currentTimeMillis()
            )


            pending.photoPath?.let { File(it).delete() }


            delay(1000)
            pendingDao.delete(localId)

            Log.d(TAG, "Sincronización completa de $localId")

            return@withContext Result.success(Unit)

        } catch (e: Exception) {
            Log.e(TAG, "Error subiendo $localId: ${e.message}")

            pendingDao.updateWithError(
                localId,
                "ERROR",
                e.message ?: "Unknown error",
                System.currentTimeMillis()
            )

            if (pending.attempts < 5) {
                Log.d(TAG, "Reintentando en 10 segundos (intento ${pending.attempts + 1}/5)")
                delay(10_000)
                uploadPendingVehicle(localId)
            }

            return@withContext Result.failure(e)
        }
    }


    fun getActiveVehiclesFlow(): Flow<List<VehicleMapItem>> {
        val dao = getDao()

        return dao.getAllVehiclesFlow().map { entities ->
            Log.d(TAG, "Flow emitió ${entities.size} vehículos desde Room")
            entities.map { it.toMapItem() }
        }
    }


    suspend fun revalidateVehicles(): Result<Unit> = withContext(Dispatchers.IO) {
        val dao = getDao()

        return@withContext try {
            Log.d(TAG, "Revalidating vehicles...")

            val startTime = System.currentTimeMillis()
            val vehicles = getActiveVehicles()
            val elapsed = System.currentTimeMillis() - startTime

            Log.d(TAG, "API responded in ${elapsed}ms with ${vehicles.size} vehicles")

            val entities = vehicles.map { it.toEntity() }


            dao.deleteAll()
            dao.insertVehicles(entities)

            Log.d(TAG, "Cached ${entities.size} vehicles in Room")

            Result.success(Unit)

        } catch (e: UnknownHostException) {
            Log.w(TAG, "No internet connection, using cache")
            Result.failure(e)
        } catch (e: Exception) {
            Log.e(TAG, "API error: ${e.message}", e)
            Result.failure(e)
        }
    }

    private suspend fun uploadPhoto(vehicleId: String, photoFile: File) {
        val requestFile = photoFile.asRequestBody("image/jpeg".toMediaTypeOrNull())
        val body = MultipartBody.Part.createFormData("file", photoFile.name, requestFile)
        vehiclesApi.uploadPhoto(vehicleId, body)
    }

    fun getPendingVehiclesFlow(): Flow<List<PendingVehicleEntity>> {
        return pendingDao.getAllPendingFlow()
    }

    fun getPendingCount(): Flow<Int> {
        return pendingDao.countPending()
    }

    suspend fun syncAllPending(): Result<Int> = withContext(Dispatchers.IO) {
        val pending = pendingDao.getAllPendingList()
        var successCount = 0

        pending.forEach { vehicle ->
            val result = uploadPendingVehicle(vehicle.localId)
            if (result.isSuccess) successCount++
        }

        Result.success(successCount)
    }

    fun isConnected(): Boolean {
        return context?.let { networkMonitor.isConnected() } ?: false
    }

    fun observeConnectivity(): Flow<Boolean> {
        return networkMonitor.observeConnectivity()
    }


    private fun VehicleResponse.toEntity() = VehicleLocationEntity(
        vehicle_id = this.vehicle_id,
        lat = this.lat ?: 4.7110,
        lng = this.lng ?: -74.0721,
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

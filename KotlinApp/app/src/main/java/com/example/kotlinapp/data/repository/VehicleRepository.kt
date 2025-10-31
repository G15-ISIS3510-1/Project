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

    // EVENTUAL CONNECTIVITY

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

        // 1. Copiar foto a almacenamiento interno (si existe)
        val savedPhotoPath = photoFile?.let { savePhotoLocally(it, localId) }

        // 2. Guardar en Room como PENDING
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
        Log.d("VehicleRepo", " Vehículo guardado localmente: $localId")

        // 3. Intentar subir si hay internet
        if (networkMonitor.isConnected()) {
            Log.d("VehicleRepo", " Hay internet, intentando subir inmediatamente")
            uploadPendingVehicle(localId)
        } else {
            Log.d("VehicleRepo", " Sin internet, esperando conectividad")

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

        Log.d("VehicleRepo", " Foto guardada en: ${destFile.absolutePath}")
        return destFile.absolutePath
    }

    private suspend fun monitorAndUpload(localId: String) = withContext(Dispatchers.IO) {
        networkMonitor.observeConnectivity()
            .filter { it == true }
            .take(1)
            .collect {
                Log.d("VehicleRepo", " Internet recuperado, subiendo $localId")
                uploadPendingVehicle(localId)

            }
    }

    suspend fun uploadPendingVehicle(localId: String): Result<Unit> = withContext(Dispatchers.IO) {
        val pending = pendingDao.getById(localId)

        if (pending == null) {
            Log.w("VehicleRepo", "Vehículo $localId no encontrado")
            return@withContext Result.failure(Exception("Vehicle not found"))
        }

        if (pending.syncStatus == "SYNCED") {
            Log.d("VehicleRepo", "Vehículo $localId ya está sincronizado")
            return@withContext Result.success(Unit)
        }

        // Actualizar a UPLOADING
        pendingDao.updateSyncStatus(localId, "UPLOADING", null, System.currentTimeMillis())

        try {
            Log.d("VehicleRepo", "Subiendo vehículo $localId...")


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

            Log.d("VehicleRepo", "Vehículo creado en backend: $remoteVehicleId")

            // 2. POST /photo (si existe)
            if (pending.photoPath != null) {
                val photoFile = File(pending.photoPath)
                if (photoFile.exists()) {
                    uploadPhoto(remoteVehicleId, photoFile)
                    Log.d("VehicleRepo", "Foto subida")
                }
            }

            // 3. POST /pricing
            val pricingDto = PricingCreate(
                vehicle_id = remoteVehicleId,
                daily_price = pending.dailyPrice,
                min_days = pending.minDays,
                max_days = pending.maxDays,
                currency = pending.currency
            )

            pricingApi.createPricing(pricingDto)
            Log.d("VehicleRepo", "Pricing creado")

            // 4. Marcar como SYNCED y eliminar
            pendingDao.updateSyncStatus(
                localId,
                "SYNCED",
                remoteVehicleId,
                System.currentTimeMillis()
            )

            // Eliminar foto local
            pending.photoPath?.let { File(it).delete() }

            // Eliminar registro de pending
            delay(1000)  // Pequeño delay para que la UI vea el cambio
            pendingDao.delete(localId)

            Log.d("VehicleRepo", "Sincronización completa de $localId")

            return@withContext Result.success(Unit)

        } catch (e: Exception) {
            Log.e("VehicleRepo", "Error subiendo $localId: ${e.message}")

            // Guardar error
            pendingDao.updateWithError(
                localId,
                "ERROR",
                e.message ?: "Unknown error",
                System.currentTimeMillis()
            )

            // Reintentar después de un delay si no excede límite
            if (pending.attempts < 5) {
                Log.d("VehicleRepo", "Reintentando en 10 segundos (intento ${pending.attempts + 1}/5)")
                delay(10_000)  // 10 segundos
                uploadPendingVehicle(localId)
            }
            
            return@withContext Result.failure(e)
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

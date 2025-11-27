package com.example.kotlinapp.data.repository


import android.content.Context
import android.util.Log

import com.example.kotlinapp.data.api.BackendApis
import com.example.kotlinapp.data.api.ApiClient

import com.example.kotlinapp.data.api.AvailabilityApiService
import com.example.kotlinapp.data.local.AppDatabase
import com.example.kotlinapp.data.local.entity.AvailabilityCacheEntity
import com.example.kotlinapp.data.local.entity.PendingAvailabilityEntity
import com.example.kotlinapp.data.network.NetworkMonitor
import com.example.kotlinapp.data.remote.dto.AvailabilityDto
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.take
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

import com.example.kotlinapp.data.remote.dto.CreateAvailabilityRequest
import com.example.kotlinapp.data.remote.dto.UpdateAvailabilityRequest

class AvailabilityRepository(
    private val context: Context
) {
    private val apiService: AvailabilityApiService = ApiClient.availabilityApiService

    private val pendingDao by lazy {
        AppDatabase.getDatabase(context).pendingAvailabilityDao()
    }

    private val cacheDao by lazy {
        AppDatabase.getDatabase(context).availabilityCacheDao()
    }

    private val networkMonitor by lazy {
        NetworkMonitor(context)
    }


    suspend fun createAvailabilityWithRetry(
        vehicleId: String,
        startDate: String,
        endDate: String,
        status: String,
        reason: String?
    ): Result<String> = withContext(Dispatchers.IO) {

        val localId = java.util.UUID.randomUUID().toString()
        val now = System.currentTimeMillis()


        val pendingEntity = PendingAvailabilityEntity(
            localId = localId,
            vehicleId = vehicleId,
            startDate = startDate,
            endDate = endDate,
            status = status,
            reason = reason,
            operationType = "CREATE",
            remoteAvailabilityId = null,
            syncStatus = "PENDING",
            attempts = 0,
            lastError = null,
            createdAt = now,
            updatedAt = now
        )

        pendingDao.insert(pendingEntity)
        Log.d("AvailabilityRepo", "Disponibilidad guardada localmente: $localId")


        if (networkMonitor.isConnected()) {
            Log.d("AvailabilityRepo", "Hay internet, intentando subir inmediatamente")
            uploadPendingAvailability(localId)
        } else {
            Log.d("AvailabilityRepo", "Sin internet, esperando conectividad")
            CoroutineScope(Dispatchers.IO).launch {
                monitorAndUpload(localId)
            }
        }

        Result.success(localId)
    }


    suspend fun updateAvailabilityWithRetry(
        availabilityId: String,
        startDate: String?,
        endDate: String?,
        status: String?,
        reason: String?
    ): Result<String> = withContext(Dispatchers.IO) {

        val localId = java.util.UUID.randomUUID().toString()
        val now = System.currentTimeMillis()


        val cached = cacheDao.getByVehicle("").find { it.availabilityId == availabilityId }

        if (cached == null) {
            return@withContext Result.failure(Exception("Availability not found in cache"))
        }

        val pendingEntity = PendingAvailabilityEntity(
            localId = localId,
            vehicleId = cached.vehicleId,
            startDate = startDate ?: cached.startDate,
            endDate = endDate ?: cached.endDate,
            status = status ?: cached.status,
            reason = reason ?: cached.reason,
            operationType = "UPDATE",
            remoteAvailabilityId = availabilityId,
            syncStatus = "PENDING",
            attempts = 0,
            lastError = null,
            createdAt = now,
            updatedAt = now
        )

        pendingDao.insert(pendingEntity)


        cacheDao.insertAll(listOf(
            cached.copy(
                startDate = startDate ?: cached.startDate,
                endDate = endDate ?: cached.endDate,
                status = status ?: cached.status,
                reason = reason ?: cached.reason,
                updatedAt = now
            )
        ))

        Log.d("AvailabilityRepo", "Update guardado localmente: $localId")

        if (networkMonitor.isConnected()) {
            uploadPendingAvailability(localId)
        } else {
            CoroutineScope(Dispatchers.IO).launch {
                monitorAndUpload(localId)
            }
        }

        Result.success(localId)
    }


    suspend fun deleteAvailabilityWithRetry(
        availabilityId: String,
        vehicleId: String
    ): Result<String> = withContext(Dispatchers.IO) {

        val localId = java.util.UUID.randomUUID().toString()
        val now = System.currentTimeMillis()

        val pendingEntity = PendingAvailabilityEntity(
            localId = localId,
            vehicleId = vehicleId,
            startDate = "",
            endDate = "",
            status = "",
            reason = null,
            operationType = "DELETE",
            remoteAvailabilityId = availabilityId,
            syncStatus = "PENDING",
            attempts = 0,
            lastError = null,
            createdAt = now,
            updatedAt = now
        )

        pendingDao.insert(pendingEntity)


        cacheDao.delete(availabilityId)

        Log.d("AvailabilityRepo", "Delete guardado localmente: $localId")

        if (networkMonitor.isConnected()) {
            uploadPendingAvailability(localId)
        } else {
            CoroutineScope(Dispatchers.IO).launch {
                monitorAndUpload(localId)
            }
        }

        Result.success(localId)
    }


    private suspend fun monitorAndUpload(localId: String) = withContext(Dispatchers.IO) {
        networkMonitor.observeConnectivity()
            .filter { it == true }
            .take(1)
            .collect {
                Log.d("AvailabilityRepo", "Internet recuperado, subiendo $localId")
                uploadPendingAvailability(localId)
            }
    }

    suspend fun uploadPendingAvailability(localId: String): Result<Unit> = withContext(Dispatchers.IO) {
        val pending = pendingDao.getById(localId)

        if (pending == null) {
            Log.w("AvailabilityRepo", "Disponibilidad $localId no encontrada")
            return@withContext Result.failure(Exception("Availability not found"))
        }

        if (pending.syncStatus == "SYNCED") {
            Log.d("AvailabilityRepo", "Disponibilidad $localId ya está sincronizada")
            return@withContext Result.success(Unit)
        }

        // Actualizar a UPLOADING
        pendingDao.updateSyncStatus(localId, "UPLOADING", null, System.currentTimeMillis())

        try {
            Log.d("AvailabilityRepo", "⬆Subiendo disponibilidad $localId (${pending.operationType})...")

            when (pending.operationType) {
                "CREATE" -> {
                    val request = CreateAvailabilityRequest(
                        vehicle_id = pending.vehicleId,
                        start_ts = pending.startDate,
                        end_ts = pending.endDate,
                        type = pending.status.lowercase(),
                        notes = pending.reason
                    )

                    val response = apiService.createAvailability(request)

                    if (response.isSuccessful) {
                        val dto = response.body()!!
                        Log.d("AvailabilityRepo", "Creado en backend: ${dto.vehicle_id}")


                        cacheDao.insertAll(listOf(
                            AvailabilityCacheEntity(
                                availabilityId = dto.availability_id,
                                vehicleId = dto.vehicle_id,
                                startDate = dto.start_ts,
                                endDate = dto.end_ts,
                                status = dto.type,
                                reason = dto.notes,
                                updatedAt = System.currentTimeMillis()
                            )
                        ))

                        pendingDao.updateSyncStatus(localId, "SYNCED", dto.vehicle_id, System.currentTimeMillis())
                    } else {
                        throw Exception("API error: ${response.code()}")
                    }
                }

                "UPDATE" -> {
                    val request = UpdateAvailabilityRequest(
                        start_ts = pending.startDate,
                        end_ts = pending.endDate,
                        type = pending.status.lowercase(),
                        notes = pending.reason
                    )

                    val response = apiService.updateAvailability(
                        pending.remoteAvailabilityId!!,
                        request
                    )

                    if (response.isSuccessful) {
                        Log.d("AvailabilityRepo", "Actualizado en backend")
                        pendingDao.updateSyncStatus(localId, "SYNCED", pending.remoteAvailabilityId, System.currentTimeMillis())
                    } else {
                        throw Exception("API error: ${response.code()}")
                    }
                }

                "DELETE" -> {
                    val response = apiService.deleteAvailability(pending.remoteAvailabilityId!!)

                    if (response.isSuccessful) {
                        Log.d("AvailabilityRepo", "Eliminado en backend")
                        pendingDao.updateSyncStatus(localId, "SYNCED", pending.remoteAvailabilityId, System.currentTimeMillis())
                    } else {
                        throw Exception("API error: ${response.code()}")
                    }
                }
            }


            delay(1000)
            pendingDao.delete(localId)

            Log.d("AvailabilityRepo", "Sincronización completa de $localId")
            return@withContext Result.success(Unit)

        } catch (e: Exception) {
            Log.e("AvailabilityRepo", "Error subiendo $localId: ${e.message}")

            pendingDao.updateWithError(
                localId,
                "ERROR",
                e.message ?: "Unknown error",
                System.currentTimeMillis()
            )


            if (pending.attempts < 5) {
                Log.d("AvailabilityRepo", "Reintentando en 10 segundos (intento ${pending.attempts + 1}/5)")
                delay(10_000)
                uploadPendingAvailability(localId)
            }

            return@withContext Result.failure(e)
        }
    }


    fun getAvailabilitiesFlow(vehicleId: String): Flow<List<AvailabilityItem>> {
        return cacheDao.getByVehicleFlow(vehicleId).map { cached ->
            cached.map { it.toItem() }
        }
    }
    suspend fun revalidateAvailabilities(vehicleId: String): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            val response = apiService.getAvailabilities(vehicleId)

            if (response.isSuccessful) {
                val body = response.body()
                val dtos = body?.items ?: emptyList()

                val entities = dtos.map {
                    AvailabilityCacheEntity(
                        availabilityId = it.availability_id,
                        vehicleId = it.vehicle_id,
                        startDate = it.start_ts,
                        endDate = it.end_ts,
                        status = it.type,
                        reason = it.notes,
                        updatedAt = System.currentTimeMillis()
                    )
                }

                cacheDao.deleteByVehicle(vehicleId)
                cacheDao.insertAll(entities)

                Log.d("AvailabilityRepo", "Cache actualizado: ${entities.size} items")
                Result.success(Unit)
            } else {
                Result.failure(Exception("API error: ${response.code()}"))
            }
        } catch (e: Exception) {
            Log.e("AvailabilityRepo", "⚠Error revalidando: ${e.message}")
            Result.failure(e)
        }
    }


    fun getPendingCount(): Flow<Int> {
        return pendingDao.countPending()
    }

    suspend fun syncAllPending(): Result<Int> = withContext(Dispatchers.IO) {
        val pending = pendingDao.getAllPendingList()
        var successCount = 0

        pending.forEach { availability ->
            val result = uploadPendingAvailability(availability.localId)
            if (result.isSuccess) successCount++
        }

        Result.success(successCount)
    }

    fun isConnected(): Boolean {
        return networkMonitor.isConnected()
    }

    fun observeConnectivity(): Flow<Boolean> {
        return networkMonitor.observeConnectivity()
    }

    private fun AvailabilityCacheEntity.toItem() = AvailabilityItem(
        availabilityId = this.availabilityId,
        vehicleId = this.vehicleId,
        startDate = this.startDate,
        endDate = this.endDate,
        status = this.status,
        reason = this.reason
    )
}

data class AvailabilityItem(
    val availabilityId: String,
    val vehicleId: String,
    val startDate: String,
    val endDate: String,
    val status: String,
    val reason: String?
)

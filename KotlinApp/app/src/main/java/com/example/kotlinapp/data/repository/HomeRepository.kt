package com.example.kotlinapp.data.repository

import android.content.Context
import android.util.Log
import com.example.kotlinapp.data.api.ApiClient
import com.example.kotlinapp.data.local.AppDatabase
import com.example.kotlinapp.data.local.entity.VehicleHomeEntity
import com.example.kotlinapp.data.remote.dto.VehicleWithPricingResponse
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class HomeRepository(context: Context) {

    private val dao = AppDatabase.getDatabase(context).vehicleHomeCacheDao()

    companion object {
        private const val TAG = "HomeRepo"
        private const val MAX_CACHE_SIZE = 20
    }

    /**
     * Observar vehículos desde cache (Flow reactivo)
     */
    fun observeVehicles(
        searchQuery: String?,
        category: String?
    ): Flow<List<VehicleWithPricingResponse>> {
        return when {
            !searchQuery.isNullOrBlank() -> {
                Log.d(TAG, "Observando cache con búsqueda: $searchQuery")
                dao.observeBySearch(searchQuery)
            }
            category != null -> {
                Log.d(TAG, "Observando cache con categoría: $category")
                dao.observeByCategory(category)
            }
            else -> {
                Log.d(TAG, "Observando todos los vehículos en cache")
                dao.observeAll()
            }
        }.map { entities ->
            entities.map { entity ->
                VehicleWithPricingResponse(
                    id = entity.vehicleId,
                    brand = entity.brand,
                    model = entity.model,
                    year = entity.year,
                    transmission = entity.transmission,
                    imageUrl = entity.imageUrl,
                    status = "available",
                    dailyRate = entity.dailyRate,
                    currency = entity.currency,
                    minDays = 1,
                    maxDays = 30
                )
            }
        }
    }


    suspend fun syncVehicles(
        searchQuery: String?,
        category: String?
    ): Result<Unit> {
        return try {
            Log.d(TAG, "Sincronizando desde API (query=$searchQuery, category=$category)...")

            val response = ApiClient.vehiclesApi.getActiveVehiclesWithPricing(
                search = searchQuery,
                category = category
            )

            Log.d(TAG, "API retornó ${response.items.size} vehículos")

            val vehiclesToCache = response.items.take(MAX_CACHE_SIZE)

            val entities = vehiclesToCache.map { vehicle ->
                VehicleHomeEntity(
                    vehicleId = vehicle.id,
                    brand = vehicle.brand,
                    model = vehicle.model,
                    year = vehicle.year,
                    transmission = vehicle.transmission,
                    category = inferCategory(vehicle),
                    dailyRate = vehicle.dailyRate,
                    currency = vehicle.currency,
                    imageUrl = vehicle.imageUrl,
                    cachedAt = System.currentTimeMillis()
                )
            }

            dao.deleteAll()
            dao.insertAll(entities)

            Log.d(TAG, " ${entities.size} vehículos guardados en cache")
            Result.success(Unit)

        } catch (e: Exception) {
            Log.e(TAG, " Error sincronizando: ${e.message}")

            val cachedCount = dao.count()
            if (cachedCount > 0) {
                Log.d(TAG, "Usando $cachedCount vehículos desde cache")
                Result.success(Unit)
            } else {
                Log.e(TAG, "No hay cache disponible")
                Result.failure(e)
            }
        }
    }


    private fun inferCategory(vehicle: VehicleWithPricingResponse): String {
        val modelLower = vehicle.model.lowercase()
        val brandLower = vehicle.brand.lowercase()

        return when {
            modelLower.contains("suv") || modelLower.contains("4x4") -> "SUVs"
            modelLower.contains("van") || modelLower.contains("minivan") -> "Minivans"
            modelLower.contains("truck") || modelLower.contains("pickup") -> "Trucks"
            brandLower.contains("mercedes") || brandLower.contains("bmw") || brandLower.contains("audi") -> "Luxury"
            else -> "Cars"
        }
    }
}
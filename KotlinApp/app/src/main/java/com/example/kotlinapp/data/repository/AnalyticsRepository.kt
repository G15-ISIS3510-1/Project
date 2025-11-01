package com.example.kotlinapp.data.repository

import com.example.kotlinapp.data.api.VehiclesApiService
import com.example.kotlinapp.data.models.PriceAnalytics
import com.example.kotlinapp.data.remote.dto.VehicleWithPricingResponse
import com.example.kotlinapp.data.utils.GeoUtils
import com.example.kotlinapp.data.models.Location


class AnalyticsRepository (
    private val apiService: VehiclesApiService
) {

    suspend fun getPriceAnalytics(
        userLat: Double,
        userLng: Double,
        radiusKm: Double = 5.0
    ): Result<PriceAnalytics> {
        return try {
            // 1. Obtener vehículos
            val allVehicles: List<VehicleWithPricingResponse> =
                apiService.getActiveVehiclesWithPricing().items
            // 🔍 DEBUGGING: Ver qué llega del backend
            println("💰 === VEHICLES para analitics (${allVehicles.size}) ===")
            allVehicles.forEachIndexed { index, vehicle ->
                println("[$index] ${vehicle.brand} ${vehicle.model} ${vehicle.year}")
                println("    💵 Price: $${vehicle.dailyRate} ${vehicle.currency}")
                println("    📍 Coords: ${vehicle.lat}, ${vehicle.lng}")
                println("    Status: ${vehicle.status}")
                println()
            }

            // 2. Filtrar por distancia
            val nearbyVehicles = allVehicles.filter { vehicle ->
                vehicle.lat != null && vehicle.lng != null &&
                        GeoUtils.calculateDistance(
                            userLat, userLng,
                            vehicle.lat, vehicle.lng
                        ) <= radiusKm
            }

            // 3. Calcular promedio
            val avgPrice = if (nearbyVehicles.isNotEmpty()) {
                nearbyVehicles.map { it.dailyRate }.average()
            } else {
                0.0
            }

            // 4. Construir resultado
            val analytics = PriceAnalytics(
                currentAvgPrice = avgPrice,
                totalVehicles = nearbyVehicles.size,
                radiusKm = radiusKm,
                userLocation = Location(userLat, userLng),
                nearbyVehicles = nearbyVehicles
            )

            Result.success(analytics)

        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
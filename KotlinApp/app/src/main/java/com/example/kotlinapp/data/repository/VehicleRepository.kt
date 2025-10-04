package com.example.kotlinapp.data.repository

import com.example.kotlinapp.data.api.BackendApis
import com.example.kotlinapp.data.api.PricingApiService
import com.example.kotlinapp.data.api.VehiclesApiService
import com.example.kotlinapp.data.remote.dto.PricingCreate
import com.example.kotlinapp.data.remote.dto.PricingResponse
import com.example.kotlinapp.data.remote.dto.VehicleCreate
import com.example.kotlinapp.data.remote.dto.VehicleResponse

class VehicleRepository(
    private val vehiclesApi: VehiclesApiService = BackendApis.vehicles,
    private val pricingApi: PricingApiService = BackendApis.pricing
) {
    suspend fun createVehicleWithPricing(
        v: VehicleCreate,
        p: PricingCreate
    ): Pair<VehicleResponse, PricingResponse> {

        val veh = vehiclesApi.createVehicle(v)
        val price = pricingApi.createPricing(p.copy(vehicle_id = veh.vehicle_id))
        return veh to price
    }
}

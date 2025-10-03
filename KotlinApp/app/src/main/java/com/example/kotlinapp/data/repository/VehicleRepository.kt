package com.example.kotlinapp.data.repository

import com.example.kotlinapp.data.remote.api.ApiService
import com.example.kotlinapp.data.remote.api.RetrofitClient
import com.example.kotlinapp.data.remote.dto.PricingCreate
import com.example.kotlinapp.data.remote.dto.PricingResponse
import com.example.kotlinapp.data.remote.dto.VehicleCreate
import com.example.kotlinapp.data.remote.dto.VehicleResponse

class VehicleRepository(
    private val api: ApiService = RetrofitClient.api
) {
    suspend fun createVehicleWithPricing(
        v: VehicleCreate,
        p: PricingCreate
    ): Pair<VehicleResponse, PricingResponse> {
        val veh = api.createVehicle(v)
        val price = api.createPricing(p.copy(vehicle_id = veh.vehicle_id))
        return veh to price
    }
}
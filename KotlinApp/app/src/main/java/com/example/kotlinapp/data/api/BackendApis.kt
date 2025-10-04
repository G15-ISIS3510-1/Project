package com.example.kotlinapp.data.api

object BackendApis {
    val vehicles: VehiclesApiService by lazy { ApiClient.create(VehiclesApiService::class.java) }
    val pricing: PricingApiService  by lazy { ApiClient.create(PricingApiService::class.java) }
}
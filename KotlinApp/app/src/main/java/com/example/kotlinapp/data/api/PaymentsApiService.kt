package com.example.kotlinapp.data.api

import com.example.kotlinapp.data.remote.dto.PaymentMethodAnalyticsDto
import retrofit2.http.GET
import retrofit2.Response

interface PaymentsApiService {
    @GET("api/payments/analytics/adoption")
    suspend fun methodAdoption(): Response<List<PaymentMethodAnalyticsDto>>
}
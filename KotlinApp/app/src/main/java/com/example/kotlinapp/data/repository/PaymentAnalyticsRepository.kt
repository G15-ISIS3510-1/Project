package com.example.kotlinapp.data.repository

import com.example.kotlinapp.data.api.BackendApis
import com.example.kotlinapp.data.api.PaymentsApiService
import com.example.kotlinapp.ui.payment.PaymentMethodAnalytics

class PaymentAnalyticsRepository(
    private val api: PaymentsApiService = BackendApis.payments
) : PaymentsRepository {

    override suspend fun getMethodAdoption(): List<PaymentMethodAnalytics> {
        val resp = api.methodAdoption()

        if (!resp.isSuccessful) {
            throw Exception("HTTP ${resp.code()}: ${resp.message()}")
        }

        val body = resp.body() ?: throw Exception("Empty response")

        if (body.isEmpty()) {
            return emptyList()
        }

        val total = body.sumOf { it.count }.coerceAtLeast(1)

        return body.map {
            PaymentMethodAnalytics(
                name = it.name,
                count = it.count,
                percentage = it.percentage ?: (it.count * 100.0 / total)
            )
        }
    }
}
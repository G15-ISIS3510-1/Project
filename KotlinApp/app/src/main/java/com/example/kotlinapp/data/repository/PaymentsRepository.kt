package com.example.kotlinapp.data.repository

import com.example.kotlinapp.ui.payment.PaymentMethodAnalytics

interface PaymentsRepository {
    suspend fun getMethodAdoption(): List<PaymentMethodAnalytics>
}
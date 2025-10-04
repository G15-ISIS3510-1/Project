package com.example.kotlinapp.domain.usecase

import com.example.kotlinapp.ui.payment.PaymentMethodAnalytics
import com.example.kotlinapp.data.repository.PaymentsRepository

class GetPaymentMethodAdoption(
    private val repository: PaymentsRepository
) {
    suspend operator fun invoke(): List<PaymentMethodAnalytics> {
        return repository.getMethodAdoption()
    }
}
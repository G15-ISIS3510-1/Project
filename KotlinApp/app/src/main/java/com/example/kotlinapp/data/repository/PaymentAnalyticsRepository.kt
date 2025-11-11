package com.example.kotlinapp.data.repository

import android.content.Context
import android.util.Log
import com.example.kotlinapp.data.api.BackendApis
import com.example.kotlinapp.data.api.PaymentsApiService
import com.example.kotlinapp.data.local.AppDatabase
import com.example.kotlinapp.data.local.entity.PaymentAnalyticsEntity
import com.example.kotlinapp.ui.payment.PaymentMethodAnalytics
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.withContext

class PaymentAnalyticsRepository(
    context: Context,
    private val api: PaymentsApiService = BackendApis.payments
) : PaymentsRepository {

    private val dao = AppDatabase.getDatabase(context).paymentAnalyticsDao()

    fun observeAnalytics(): Flow<List<PaymentMethodAnalytics>> {
        return dao.observeAll().map { entities ->
            entities.map { entity ->
                PaymentMethodAnalytics(
                    name = entity.methodName,
                    count = entity.transactionCount,
                    percentage = entity.percentage
                )
            }
        }
    }

    /** Sincroniza analytics desde API usando estrategia de múltiples dispatchers anidados:
     1. Dispatchers.IO (externo): Llamada HTTP (red)
     2. Dispatchers.Default (anidado): Procesamiento CPU-intensivo (mapping, cálculos)
     3. Dispatchers.IO (anidado): Escritura a Room (I/O bloqueante)
     */
    suspend fun syncAnalytics(): Result<Unit> = withContext(Dispatchers.IO) {
        return@withContext try {
            Log.d("PaymentRepo", "[Dispatcher.IO] Sincronizando analytics desde API...")

            // ============ PASO 1: Fetch de red en IO ============
            val resp = api.methodAdoption()

            if (!resp.isSuccessful) {
                throw Exception("HTTP ${resp.code()}: ${resp.message()}")
            }

            val body = resp.body() ?: throw Exception("Empty response")
            Log.d("PaymentRepo", "API retornó ${body.size} métodos de pago")


            val entities = withContext(Dispatchers.Default) {
                Log.d("PaymentRepo", "[Dispatcher.Default] Procesando datos (cálculos)...")


                val total = body.sumOf { it.count }.coerceAtLeast(1)


                val analytics = body.map {
                    PaymentMethodAnalytics(
                        name = it.name,
                        count = it.count,
                        percentage = it.percentage ?: (it.count * 100.0 / total)
                    )
                }

                analytics.map { method ->
                    PaymentAnalyticsEntity(
                        methodName = method.name,
                        transactionCount = method.count,
                        percentage = method.percentage,
                        cachedAt = System.currentTimeMillis()
                    )
                }
            }

            Log.d("PaymentRepo", "Procesamiento completado: ${entities.size} entidades")

            withContext(Dispatchers.IO) {
                Log.d("PaymentRepo", "[Dispatcher.IO] Guardando en Room...")
                dao.deleteAll()
                dao.insertAll(entities)
                Log.d("PaymentRepo", "${entities.size} métodos guardados en cache")
            }

            Result.success(Unit)

        } catch (e: Exception) {
            Log.e("PaymentRepo", "Error sincronizando: ${e.message}")


            val cachedCount = dao.count()
            if (cachedCount > 0) {
                Log.d("PaymentRepo", "Usando $cachedCount métodos desde cache")
                Result.success(Unit)
            } else {
                Log.e("PaymentRepo", "No hay cache disponible")
                Result.failure(e)
            }
        }
    }

    override suspend fun getMethodAdoption(): List<PaymentMethodAnalytics> {

        val result = syncAnalytics()

        return if (result.isSuccess) {

            dao.getAll().map { entity ->
                PaymentMethodAnalytics(
                    name = entity.methodName,
                    count = entity.transactionCount,
                    percentage = entity.percentage
                )
            }
        } else {

            throw result.exceptionOrNull() ?: Exception("Unknown error")
        }
    }
}
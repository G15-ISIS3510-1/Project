package com.example.kotlinapp.data.local.dao

import androidx.room.*
import com.example.kotlinapp.data.local.entity.PaymentAnalyticsEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface PaymentAnalyticsDao {

    @Query("SELECT * FROM payment_analytics ORDER BY percentage ASC")
    fun observeAll(): Flow<List<PaymentAnalyticsEntity>>

    @Query("SELECT * FROM payment_analytics ORDER BY percentage ASC")
    suspend fun getAll(): List<PaymentAnalyticsEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(analytics: List<PaymentAnalyticsEntity>)

    @Query("DELETE FROM payment_analytics")
    suspend fun deleteAll()

    @Query("SELECT COUNT(*) FROM payment_analytics")
    suspend fun count(): Int
}
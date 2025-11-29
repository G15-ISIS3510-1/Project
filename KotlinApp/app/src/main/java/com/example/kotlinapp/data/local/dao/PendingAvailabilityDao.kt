package com.example.kotlinapp.data.local.dao

import androidx.room.*
import com.example.kotlinapp.data.local.entity.PendingAvailabilityEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface PendingAvailabilityDao {

    @Query("SELECT * FROM pending_availabilities WHERE syncStatus != 'SYNCED' ORDER BY createdAt DESC")
    fun getAllPendingFlow(): Flow<List<PendingAvailabilityEntity>>

    @Query("SELECT * FROM pending_availabilities WHERE localId = :localId")
    suspend fun getById(localId: String): PendingAvailabilityEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(availability: PendingAvailabilityEntity)

    @Query("""
        UPDATE pending_availabilities 
        SET syncStatus = :status, 
            remoteAvailabilityId = :remoteId,
            updatedAt = :timestamp,
            attempts = attempts + 1
        WHERE localId = :localId
    """)
    suspend fun updateSyncStatus(
        localId: String,
        status: String,
        remoteId: String?,
        timestamp: Long
    )

    @Query("""
        UPDATE pending_availabilities 
        SET syncStatus = :status,
            lastError = :error,
            updatedAt = :timestamp,
            attempts = attempts + 1
        WHERE localId = :localId
    """)
    suspend fun updateWithError(
        localId: String,
        status: String,
        error: String,
        timestamp: Long
    )

    @Query("DELETE FROM pending_availabilities WHERE localId = :localId")
    suspend fun delete(localId: String)

    @Query("SELECT COUNT(*) FROM pending_availabilities WHERE syncStatus = 'PENDING' OR syncStatus = 'ERROR'")
    fun countPending(): Flow<Int>

    @Query("SELECT * FROM pending_availabilities WHERE syncStatus = 'PENDING' OR syncStatus = 'ERROR'")
    suspend fun getAllPendingList(): List<PendingAvailabilityEntity>

    @Query("SELECT * FROM pending_availabilities WHERE vehicleId = :vehicleId AND syncStatus != 'SYNCED' ORDER BY startDate ASC")
    fun getPendingByVehicleFlow(vehicleId: String): Flow<List<PendingAvailabilityEntity>>
}
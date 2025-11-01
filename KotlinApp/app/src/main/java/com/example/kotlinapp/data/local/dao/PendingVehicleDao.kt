package com.example.kotlinapp.data.local.dao

import androidx.room.*
import com.example.kotlinapp.data.local.entity.PendingVehicleEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface PendingVehicleDao {


    @Query("SELECT * FROM pending_vehicles WHERE syncStatus != 'SYNCED' ORDER BY createdAt DESC")
    fun getAllPendingFlow(): Flow<List<PendingVehicleEntity>>


    @Query("SELECT * FROM pending_vehicles WHERE localId = :localId")
    suspend fun getById(localId: String): PendingVehicleEntity?


    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(vehicle: PendingVehicleEntity)


    @Query("""
        UPDATE pending_vehicles 
        SET syncStatus = :status, 
            remoteVehicleId = :remoteId,
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
        UPDATE pending_vehicles 
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


    @Query("DELETE FROM pending_vehicles WHERE localId = :localId")
    suspend fun delete(localId: String)


    @Query("SELECT COUNT(*) FROM pending_vehicles WHERE syncStatus = 'PENDING'")
    fun countPending(): Flow<Int>


    @Query("SELECT * FROM pending_vehicles WHERE syncStatus = 'PENDING' OR syncStatus = 'ERROR'")
    suspend fun getAllPendingList(): List<PendingVehicleEntity>
}
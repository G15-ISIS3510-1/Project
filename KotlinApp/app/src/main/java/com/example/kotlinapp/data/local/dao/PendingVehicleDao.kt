package com.example.kotlinapp.data.local.dao

import androidx.room.*
import com.example.kotlinapp.data.local.entity.PendingVehicleEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface PendingVehicleDao {

    // Obtener todos los vehículos pendientes como Flow (reactivo)
    @Query("SELECT * FROM pending_vehicles WHERE syncStatus != 'SYNCED' ORDER BY createdAt DESC")
    fun getAllPendingFlow(): Flow<List<PendingVehicleEntity>>

    // Obtener un vehículo específico
    @Query("SELECT * FROM pending_vehicles WHERE localId = :localId")
    suspend fun getById(localId: String): PendingVehicleEntity?

    // Insertar vehículo pendiente
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(vehicle: PendingVehicleEntity)

    // Actualizar estado de sincronización
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

    // Actualizar con error
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

    // Eliminar vehículo sincronizado
    @Query("DELETE FROM pending_vehicles WHERE localId = :localId")
    suspend fun delete(localId: String)

    // Contar vehículos pendientes
    @Query("SELECT COUNT(*) FROM pending_vehicles WHERE syncStatus = 'PENDING'")
    fun countPending(): Flow<Int>

    // Obtener todos los pendientes (para sincronización manual)
    @Query("SELECT * FROM pending_vehicles WHERE syncStatus = 'PENDING' OR syncStatus = 'ERROR'")
    suspend fun getAllPendingList(): List<PendingVehicleEntity>
}
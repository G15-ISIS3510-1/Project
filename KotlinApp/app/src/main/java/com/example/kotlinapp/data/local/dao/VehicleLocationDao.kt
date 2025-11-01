package com.example.kotlinapp.data.local.dao

import androidx.room.*
import com.example.kotlinapp.data.local.entity.VehicleLocationEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface VehicleLocationDao {

    @Query("SELECT * FROM vehicle_locations ORDER BY updatedAt DESC")
    fun getAllVehiclesFlow(): Flow<List<VehicleLocationEntity>>

    @Query("SELECT * FROM vehicle_locations")
    suspend fun getAllVehicles(): List<VehicleLocationEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertVehicles(vehicles: List<VehicleLocationEntity>)

    @Query("DELETE FROM vehicle_locations")
    suspend fun deleteAll()

    @Query("UPDATE vehicle_locations SET updatedAt = :timestamp WHERE vehicle_id = :id")
    suspend fun updateTimestamp(id: String, timestamp: Long)
}
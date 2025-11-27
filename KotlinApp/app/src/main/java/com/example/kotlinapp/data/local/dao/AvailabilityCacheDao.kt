package com.example.kotlinapp.data.local.dao


import androidx.room.*
import com.example.kotlinapp.data.local.entity.AvailabilityCacheEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface AvailabilityCacheDao {

    @Query("SELECT * FROM availability_cache WHERE vehicleId = :vehicleId ORDER BY startDate ASC")
    fun getByVehicleFlow(vehicleId: String): Flow<List<AvailabilityCacheEntity>>

    @Query("SELECT * FROM availability_cache WHERE vehicleId = :vehicleId ORDER BY startDate ASC")
    suspend fun getByVehicle(vehicleId: String): List<AvailabilityCacheEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(availabilities: List<AvailabilityCacheEntity>)

    @Query("DELETE FROM availability_cache WHERE vehicleId = :vehicleId")
    suspend fun deleteByVehicle(vehicleId: String)

    @Query("DELETE FROM availability_cache WHERE availabilityId = :availabilityId")
    suspend fun delete(availabilityId: String)
}
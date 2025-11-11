package com.example.kotlinapp.data.local.dao

import androidx.room.*
import com.example.kotlinapp.data.local.entity.VehicleHomeEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface VehicleHomeCacheDao {

    @Query("SELECT * FROM vehicle_home_cache ORDER BY cachedAt DESC")
    fun observeAll(): Flow<List<VehicleHomeEntity>>

    @Query("SELECT * FROM vehicle_home_cache WHERE category = :category ORDER BY cachedAt DESC")
    fun observeByCategory(category: String): Flow<List<VehicleHomeEntity>>

    @Query("""
        SELECT * FROM vehicle_home_cache 
        WHERE brand LIKE '%' || :query || '%' 
           OR model LIKE '%' || :query || '%'
        ORDER BY cachedAt DESC
    """)
    fun observeBySearch(query: String): Flow<List<VehicleHomeEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(vehicles: List<VehicleHomeEntity>)

    @Query("DELETE FROM vehicle_home_cache")
    suspend fun deleteAll()

    @Query("SELECT COUNT(*) FROM vehicle_home_cache")
    suspend fun count(): Int
}
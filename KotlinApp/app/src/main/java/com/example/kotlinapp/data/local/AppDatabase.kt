package com.example.kotlinapp.data.local

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import com.example.kotlinapp.data.local.dao.PendingVehicleDao
import com.example.kotlinapp.data.local.dao.VehicleLocationDao
import com.example.kotlinapp.data.local.entity.PendingVehicleEntity
import com.example.kotlinapp.data.local.entity.VehicleLocationEntity

@Database(
    entities = [
        VehicleLocationEntity::class,
        PendingVehicleEntity::class  // ← AGREGAR ESTA LÍNEA
    ],
    version = 2,  // ← INCREMENTAR LA VERSIÓN (era 1, ahora 2)
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {

    abstract fun vehicleLocationDao(): VehicleLocationDao
    abstract fun pendingVehicleDao(): PendingVehicleDao  // ← AGREGAR ESTE DAO

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getDatabase(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "vehicle_rental_db"
                )
                    .fallbackToDestructiveMigration()  // ← IMPORTANTE para desarrollo
                    .build()
                INSTANCE = instance
                instance
            }
        }
    }
}
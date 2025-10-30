package com.example.kotlinapp.data.local

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import com.example.kotlinapp.data.local.dao.VehicleLocationDao
import com.example.kotlinapp.data.local.entity.VehicleLocationEntity

@Database(
    entities = [VehicleLocationEntity::class],
    version = 1,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun vehicleLocationDao(): VehicleLocationDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getDatabase(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "vehicle_rental_db"
                ).build()
                INSTANCE = instance
                instance
            }
        }
    }
}
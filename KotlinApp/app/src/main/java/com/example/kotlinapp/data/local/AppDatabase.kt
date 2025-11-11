package com.example.kotlinapp.data.local

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import com.example.kotlinapp.data.local.dao.PendingVehicleDao
import com.example.kotlinapp.data.local.dao.VehicleLocationDao
import com.example.kotlinapp.data.local.entity.PendingVehicleEntity
import com.example.kotlinapp.data.local.entity.VehicleLocationEntity
import com.example.kotlinapp.data.local.dao.PaymentAnalyticsDao
import com.example.kotlinapp.data.local.dao.VehicleHomeCacheDao
import com.example.kotlinapp.data.local.entity.PaymentAnalyticsEntity
import com.example.kotlinapp.data.local.entity.VehicleHomeEntity



@Database(
    entities = [
        VehicleLocationEntity::class,
        PendingVehicleEntity::class,
        PaymentAnalyticsEntity::class,
        VehicleHomeEntity::class
    ],
    version = 4,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {

    abstract fun vehicleLocationDao(): VehicleLocationDao
    abstract fun pendingVehicleDao(): PendingVehicleDao

    abstract fun paymentAnalyticsDao(): PaymentAnalyticsDao

    abstract fun vehicleHomeCacheDao(): VehicleHomeCacheDao

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

                .fallbackToDestructiveMigration()
                .build()

                INSTANCE = instance
                instance
            }
        }
    }
}

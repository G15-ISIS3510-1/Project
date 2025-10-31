package com.example.kotlinapp.core

import android.content.Context
import androidx.room.Room
import com.example.kotlinapp.data.local.MessagesDatabase

object MessagesDatabaseModule {
    @Volatile
    private var INSTANCE: MessagesDatabase? = null

    fun getDatabase(context: Context): MessagesDatabase {
        return INSTANCE ?: synchronized(this) {
            val instance = Room.databaseBuilder(
                context.applicationContext,
                MessagesDatabase::class.java,
                "messages_db"
            )
                .addMigrations(MessagesDatabase.MIGRATION_1_2)
                .fallbackToDestructiveMigration() // Solo en desarrollo
                .build()
            INSTANCE = instance
            instance
        }
    }
}


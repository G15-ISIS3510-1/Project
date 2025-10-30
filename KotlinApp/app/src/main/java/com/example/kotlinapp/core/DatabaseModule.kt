package com.example.kotlinapp.core

import android.content.Context
import androidx.room.Room
import com.example.kotlinapp.data.local.FeedbackDatabase

object DatabaseModule {
    @Volatile
    private var INSTANCE: FeedbackDatabase? = null

    fun getDatabase(context: Context): FeedbackDatabase {
        return INSTANCE ?: synchronized(this) {
            val instance = Room.databaseBuilder(
                context.applicationContext,
                FeedbackDatabase::class.java,
                "feedback_db"
            ).build()
            INSTANCE = instance
            instance
        }
    }
}

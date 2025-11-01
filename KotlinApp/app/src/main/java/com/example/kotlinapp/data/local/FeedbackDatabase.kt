package com.example.kotlinapp.data.local

import androidx.room.Database
import androidx.room.RoomDatabase

@Database(entities = [FeedbackEntity::class], version = 1)
abstract class FeedbackDatabase : RoomDatabase() {
    abstract fun feedbackDao(): FeedbackDao
}

package com.example.kotlinapp.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "feedback")
data class FeedbackEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Int = 0,
    val featureName: String,
    val comment: String,
    val timestamp: Long = System.currentTimeMillis(),
    val synced: Boolean = false
)

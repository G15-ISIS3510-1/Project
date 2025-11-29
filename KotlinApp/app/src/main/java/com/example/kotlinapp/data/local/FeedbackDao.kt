package com.example.kotlinapp.data.local

import androidx.room.*

@Dao
interface FeedbackDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertFeedback(feedback: FeedbackEntity)

    @Query("SELECT * FROM feedback ORDER BY timestamp DESC")
    suspend fun getAllFeedback(): List<FeedbackEntity>

    @Query("SELECT * FROM feedback WHERE synced = 0")
    suspend fun getPendingFeedback(): List<FeedbackEntity>

    @Update
    suspend fun updateFeedback(feedback: FeedbackEntity)
}

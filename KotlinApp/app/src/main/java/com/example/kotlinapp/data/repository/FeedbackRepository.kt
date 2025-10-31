package com.example.kotlinapp.data.repository

import com.example.kotlinapp.data.local.FeedbackDao
import com.example.kotlinapp.data.local.FeedbackEntity

class FeedbackRepository(private val dao: FeedbackDao) {

    suspend fun saveFeedback(featureName: String, comment: String) {
        val feedback = FeedbackEntity(featureName = featureName, comment = comment)
        dao.insertFeedback(feedback)
    }

    suspend fun getAllFeedback() = dao.getAllFeedback()

    suspend fun getPendingFeedback() = dao.getPendingFeedback()

    suspend fun markAsSynced(feedback: FeedbackEntity) {
        dao.updateFeedback(feedback.copy(synced = true))
    }
}

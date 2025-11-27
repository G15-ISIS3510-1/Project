package com.example.kotlinapp.data.repository

import com.example.kotlinapp.data.local.FeedbackDao
import com.example.kotlinapp.data.local.FeedbackEntity
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class FeedbackRepository(private val dao: FeedbackDao) {

    suspend fun saveFeedback(featureName: String, comment: String) = withContext(Dispatchers.IO) {
        dao.insertFeedback(FeedbackEntity(featureName = featureName, comment = comment))
    }

    suspend fun getAllFeedback() = withContext(Dispatchers.IO) { dao.getAllFeedback() }

    suspend fun getPendingFeedback() = withContext(Dispatchers.IO) { dao.getPendingFeedback() }

    suspend fun markAsSynced(feedback: FeedbackEntity) = withContext(Dispatchers.IO) {
        dao.updateFeedback(feedback.copy(synced = true))
    }
}

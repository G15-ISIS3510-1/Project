package com.example.kotlinapp.core

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.example.kotlinapp.data.local.FeedbackEntity
import com.example.kotlinapp.data.repository.FeedbackRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder

class FeedbackSyncWorker(
    private val context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
        try {
            val dao = DatabaseModule.getDatabase(context).feedbackDao()
            val repository = FeedbackRepository(dao)
            val pendingFeedbacks = repository.getPendingFeedback()

            if (pendingFeedbacks.isEmpty()) return@withContext Result.success()

            for (feedback in pendingFeedbacks) {
                val success = sendToGoogleForm(feedback)
                if (success) repository.markAsSynced(feedback)
            }

            Result.success()
        } catch (e: Exception) {
            e.printStackTrace()
            Result.retry()
        }
    }

    // ✉️ Envía un POST al Google Form
    private fun sendToGoogleForm(feedback: FeedbackEntity): Boolean {
        val formUrl = "https://docs.google.com/forms/u/0/d/e/1FAIpQLSdu9oZodn38MI1yO1CepZqnie3Ts5NqUL3byTddQnhyRwCfgw/formResponse" // <-- cambia esto
        val featureKey = "entry.1201931167" // <-- cambia esto
        val commentKey = "entry.589334695" // <-- cambia esto

        val postData = "${featureKey}=${URLEncoder.encode(feedback.featureName, "UTF-8")}" +
                "&${commentKey}=${URLEncoder.encode(feedback.comment, "UTF-8")}"

        val url = URL(formUrl)
        val conn = (url.openConnection() as HttpURLConnection).apply {
            requestMethod = "POST"
            doOutput = true
            outputStream.write(postData.toByteArray(Charsets.UTF_8))
            outputStream.flush()
            outputStream.close()
        }

        return conn.responseCode == 200 || conn.responseCode == 302
    }
}

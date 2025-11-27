package com.example.kotlinapp.analytics

import android.util.Log
import com.example.kotlinapp.data.repository.FeatureUsageRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class ChatTimeTracker(
    private val repository: FeatureUsageRepository,
    private val scope: CoroutineScope
) {

    fun trackChatSession(
        durationMillis: Long,
        durationSeconds: Double,
        startMs: Long,
        endMs: Long,
        originRoute: String,
        destinationRoute: String
    ) {
        Log.d(TAG, "🚀 Starting to track chat session: ${durationSeconds}s from $originRoute to $destinationRoute")
        scope.launch(Dispatchers.IO) {
            val metadata = mapOf(
                "start_epoch_ms" to startMs,
                "end_epoch_ms" to endMs
            )

            Log.d(TAG, "📤 Sending feature usage log to API...")
            val success = repository.logFeatureUsage(
                featureName = FEATURE_NAME,
                durationSeconds = durationSeconds,
                durationMs = durationMillis,
                originRoute = originRoute,
                destinationRoute = destinationRoute,
                metadata = metadata
            )

            if (success) {
                Log.d(TAG, "✅ Successfully logged chat time spent event")
            } else {
                Log.w(TAG, "❌ Failed to log chat time spent event")
            }
        }
    }

    companion object {
        private const val TAG = "ChatTimeTracker"
        const val FEATURE_NAME = "time_spent_in_chat_before_leave"
    }
}


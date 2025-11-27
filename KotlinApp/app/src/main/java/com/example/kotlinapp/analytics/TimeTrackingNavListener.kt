package com.example.kotlinapp.analytics

import android.os.Bundle
import android.util.Log
import androidx.navigation.NavController
import androidx.navigation.NavDestination

class TimeTrackingNavListener(
    private val tracker: ChatTimeTracker,
    private val trackedDestinationIds: Set<Int>,
    private val minimumDurationSeconds: Double = 1.0
) : NavController.OnDestinationChangedListener {

    private var currentDestinationId: Int? = null
    private var currentRouteLabel: String = "unknown"
    private var startTimeMs: Long = System.currentTimeMillis()

    init {
        Log.d(TAG, "TimeTrackingNavListener initialized. Tracked IDs: $trackedDestinationIds")
    }

    override fun onDestinationChanged(
        controller: NavController,
        destination: NavDestination,
        arguments: Bundle?
    ) {
        val now = System.currentTimeMillis()
        val durationMillis = now - startTimeMs
        val durationSeconds = durationMillis / 1000.0

        val destinationName = destination.route ?: destination.displayName()
        Log.d(TAG, "Navigation changed: ${currentRouteLabel} (ID: $currentDestinationId) -> $destinationName (ID: ${destination.id})")
        Log.d(TAG, "Time spent on previous destination: ${durationSeconds}s")

        val previousDestinationId = currentDestinationId
        if (previousDestinationId != null &&
            previousDestinationId in trackedDestinationIds &&
            durationSeconds >= minimumDurationSeconds
        ) {
            Log.d(TAG, "✅ Tracking chat session: ${durationSeconds}s from $currentRouteLabel to $destinationName")
            tracker.trackChatSession(
                durationMillis = durationMillis,
                durationSeconds = durationSeconds,
                startMs = startTimeMs,
                endMs = now,
                originRoute = currentRouteLabel,
                destinationRoute = destinationName
            )
        } else {
            if (previousDestinationId == null) {
                Log.d(TAG, "⏭️ Skipping: No previous destination")
            } else if (previousDestinationId !in trackedDestinationIds) {
                Log.d(TAG, "⏭️ Skipping: Previous destination (ID: $previousDestinationId) not in tracked set")
            } else if (durationSeconds < minimumDurationSeconds) {
                Log.d(TAG, "⏭️ Skipping: Duration ($durationSeconds) < minimum ($minimumDurationSeconds)")
            }
        }

        startTimeMs = now
        currentDestinationId = destination.id
        currentRouteLabel = destinationName
        
        if (destination.id in trackedDestinationIds) {
            Log.d(TAG, "📍 Now tracking time on: $destinationName (ID: ${destination.id})")
        }
    }

    private fun NavDestination.displayName(): String {
        return label?.toString() ?: id.toString()
    }

    companion object {
        private const val TAG = "TimeTrackingNavListener"
    }
}


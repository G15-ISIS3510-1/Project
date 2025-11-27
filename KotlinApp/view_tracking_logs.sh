#!/bin/bash
echo "📱 Viewing tracking logs... Filter by: TimeTrackingNavListener, ChatTimeTracker, FeatureUsageRepository"
echo "Press Ctrl+C to stop"
echo ""
adb logcat -c  # Clear previous logs
adb logcat | grep -E "TimeTrackingNavListener|ChatTimeTracker|FeatureUsageRepository|MainActivity.*navigation"

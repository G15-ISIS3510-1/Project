class TimeTracker {
  static String? currentView;
  static DateTime? startTime;

  static void start(String viewName) {
    currentView = viewName;
    startTime = DateTime.now();
  }

  static Map<String, dynamic>? stop() {
    if (currentView == null || startTime == null) return null;

    final end = DateTime.now();
    final duration = end.difference(startTime!).inSeconds;

    final record = {
      "view": currentView,
      "start": startTime!.toIso8601String(),
      "end": end.toIso8601String(),
      "duration": duration,
    };

    currentView = null;
    startTime = null;

    return record;
  }
}

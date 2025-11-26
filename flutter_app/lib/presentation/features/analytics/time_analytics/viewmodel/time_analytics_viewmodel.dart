import 'package:flutter/material.dart';
import '../data/time_repository.dart';

class TimeAnalyticsViewModel extends ChangeNotifier {
  final TimeRepository repo;
  bool loading = false;
  bool usedCache = false;
  String? error;

  List<Map<String, dynamic>> logs = [];

  int totalSeconds = 0;
  double avgLastWeek = 0;
  List<Map<String, dynamic>> topFive = [];
  List<Map<String, dynamic>> bottomFive = [];
  Map<String, int> history = {};

  TimeAnalyticsViewModel(this.repo);

  Future<void> load() async {
    loading = true;
    notifyListeners();

    try {
      final result = await repo.getUsageLogs();
      logs = result;

      _computeTotal();
      _computeAvg();
      _computeTopFive();
      _computeBottomFive();
      _computeHistory();

      usedCache = true;
      error = null;
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  void _computeTotal() {
    totalSeconds = logs
        .fold<num>(0, (sum, e) => sum + (e['duration'] ?? 0))
        .toInt();
  }

  void _computeAvg() {
    final now = DateTime.now();

    final lastWeek = logs.where((e) {
      final date = DateTime.parse(e['start']);
      return now.difference(date).inDays <= 7;
    }).toList();

    if (lastWeek.isEmpty) {
      avgLastWeek = 0;
      return;
    }

    final total = lastWeek.fold<num>(
      0,
      (sum, e) => sum + (e['duration'] ?? 0),
    );

    avgLastWeek = total / lastWeek.length;
  }

  void _computeTopFive() {
    final map = <String, int>{};

    for (var e in logs) {
      final view = e['view'];
      final dur = e['duration'] ?? 0;

      map[view] = (((map[view] ?? 0) as num ) + (dur)).toInt();
    }

    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    topFive = sorted
        .take(5)
        .map((e) => {"view": e.key, "duration": e.value})
        .toList();
  }

  void _computeBottomFive() {
    final map = <String, int>{};

    for (var e in logs) {
      final view = e['view'];
      final dur = e['duration'] ?? 0;

      map[view] = (((map[view] ?? 0) as num) + dur).toInt();
    }

    final sorted = map.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    bottomFive = sorted
        .take(5)
        .map((e) => {"view": e.key, "duration": e.value})
        .toList();
  }

  void _computeHistory() {
    history = {};

    for (var e in logs) {
      final date = DateTime.parse(e['start'])
          .toString()
          .substring(0, 10);

      final dur = e['duration'] ?? 0;

      history[date] =
          (((history[date] ?? 0) as num) + dur).toInt();
    }
  }

  String format(int sec) {
    final h = sec ~/ 3600;
    final m = (sec % 3600) ~/ 60;
    final s = sec % 60;
    return "${h}h ${m}m ${s}s";
  }
}

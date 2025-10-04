// lib/core/theme_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/time_utils.dart';

enum ThemePref { auto, light, dark }

class ThemeController extends ChangeNotifier {
  ThemePref _pref = ThemePref.auto;
  int _nightStart = 19; // 19:00
  int _nightEnd = 6; // 06:00
  Timer? _ticker;

  ThemeController() {
    _load();
    _startTicker();
  }

  ThemePref get pref => _pref;
  int get nightStart => _nightStart;
  int get nightEnd => _nightEnd;

  ThemeMode get currentMode {
    switch (_pref) {
      case ThemePref.light:
        return ThemeMode.light;
      case ThemePref.dark:
        return ThemeMode.dark;
      case ThemePref.auto:
        final night = isNightNow(
          DateTime.now(),
          startHour: _nightStart,
          endHour: _nightEnd,
        );
        return night ? ThemeMode.dark : ThemeMode.light;
    }
  }

  void setPref(ThemePref p) {
    _pref = p;
    _save();
    notifyListeners();
  }

  void setNightWindow({required int startHour, required int endHour}) {
    _nightStart = startHour;
    _nightEnd = endHour;
    _save();
    notifyListeners();
  }

  // Recalcula cada minuto para capturar el “cambio de hora”
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_pref == ThemePref.auto) notifyListeners();
    });
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    _pref = ThemePref.values[sp.getInt('theme_pref') ?? ThemePref.auto.index];
    _nightStart = sp.getInt('night_start') ?? 19;
    _nightEnd = sp.getInt('night_end') ?? 6;
    notifyListeners();
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt('theme_pref', _pref.index);
    await sp.setInt('night_start', _nightStart);
    await sp.setInt('night_end', _nightEnd);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

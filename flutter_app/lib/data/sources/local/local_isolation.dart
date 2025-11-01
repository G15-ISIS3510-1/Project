// lib/data/local/local_isolation.dart
import 'dart:io';
import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Utilidades de limpieza "rápida y efectiva" al cambiar de sesión.
class LocalIsolation {
  /// Limpia preferencia compartida, caches de imágenes y cache manager.
  /// Nota: El borrado de tablas Drift se hace en _clearAppData() (main.dart).
  static Future<void> hardReset() async {
    // 1) Preferencias compartidas
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.clear();
    } catch (_) {}

    // 2) Cache de archivos (imágenes, http cache)
    try {
      await DefaultCacheManager().emptyCache();
    } catch (_) {}

    // 3) Cache de imágenes en RAM de Flutter
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (_) {}
  }
}

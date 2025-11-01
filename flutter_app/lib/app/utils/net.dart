// lib/app/utils/net.dart
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class Net {
  static Future<bool> isOnline() async {
    final c = await Connectivity().checkConnectivity();

    if (c == ConnectivityResult.none) return false;
    // opcional: intento de DNS rápido para confirmar salida
    try {
      final res = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(milliseconds: 500));
      return res.isNotEmpty && res.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

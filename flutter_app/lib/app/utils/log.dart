import 'package:flutter/foundation.dart';

String _snip(String s, [int max = 600]) =>
    s.length <= max ? s : s.substring(0, max) + '…[snip]';
void logD(String tag, String msg) {
  if (!kDebugMode) return;
  final ts = DateTime.now().toIso8601String();
  debugPrint('[$ts][$tag] $msg');
}

String snipBody(String body, {int max = 600}) => _snip(body, max);

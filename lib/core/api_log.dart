import 'package:flutter/foundation.dart';

void apiLog(String message) {
  if (kDebugMode) debugPrint('[api] $message');
}

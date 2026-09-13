import 'package:flutter/material.dart';
import 'package:pulse/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse/core/env.dart';

void main() {
  if (!Env.useLocalStub && (Env.apiBase.isEmpty || Env.bucket.isEmpty)) {
    throw StateError(
      'API_BASE and BUCKET are missing. Run: flutter run --dart-define-from-file=env.json',
    );
  }
  runApp(const ProviderScope(child: App()));
}

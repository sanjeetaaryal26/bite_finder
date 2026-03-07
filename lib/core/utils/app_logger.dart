import 'package:flutter/foundation.dart';

class AppLogger {
  static void error(Object error, StackTrace stackTrace, {String? context}) {
    final prefix = context == null || context.isEmpty ? 'AppError' : 'AppError[$context]';
    debugPrint('$prefix: $error');
    debugPrint('$stackTrace');
  }
}

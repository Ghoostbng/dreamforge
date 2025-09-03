import 'package:flutter/foundation.dart';

class AppLogger {
  static void d(String message) {
    if (kDebugMode) {
      print('DEBUG: $message');
    }
  }

  static void i(String message) {
    if (kDebugMode) {
      print('INFO: $message');
    }
  }

  static void w(String message) {
    if (kDebugMode) {
      print('WARN: $message');
    }
  }

  static void e(String message) {
    if (kDebugMode) {
      print('ERROR: $message');
    }
  }
}
import "package:flutter/foundation.dart";
class Logger {
  static void info(String msg) {
    debugPrint("[INFO] $msg");
  }

  static void warn(String msg) {
    debugPrint("[WARN] $msg");
  }

  static void error(String msg) {
    debugPrint("[ERROR] $msg");
  }
}
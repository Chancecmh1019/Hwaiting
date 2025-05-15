import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/exam_date_calculator.dart';

class ExamCountdownWidget {
  static const MethodChannel _channel = MethodChannel('com.hwaiting/widget');

  static void initialize() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'getRemainingTime':
          return await ExamDateCalculator.getRemainingTime();
        case 'formatExamDateForWidget':
          return await ExamDateCalculator.formatExamDateForWidget();
        default:
          throw MissingPluginException();
      }
    });
  }

  static Future<void> updateWidget() async {
    try {
      await _channel.invokeMethod('updateWidget');
    } catch (e) {
      debugPrint('更新小工具失敗: $e'); // 保持原錯誤日誌格式，使用繁體中文
    }
  }
}
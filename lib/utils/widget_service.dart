import 'package:home_widget/home_widget.dart';
import 'dart:async';
import 'exam_date_calculator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

/// 桌面小工具更新服務
class WidgetService {
  static const String appGroupId = 'group.com.hwaiting';
  static const String widgetName = 'ExamCountdownWidget';
  static Timer? _updateTimer;
  static bool _isUpdating = false;
  static DateTime? _lastUpdateTime;
  
  /// 初始化桌面小工具服務
  static Future<void> init() async {
    try {
      // 初始化 HomeWidget
      await HomeWidget.setAppGroupId(appGroupId);
      
      // 開始定期更新小工具（每分鐘一次）
      _startPeriodicUpdates();
      
      // 監聽小工具點擊事件
      HomeWidget.widgetClicked.listen((uri) {
        // 小工具被點擊時立即更新
        updateWidget();
      });
      
      print('小工具服務初始化成功');
    } catch (e) {
      print('小工具服務初始化錯誤: $e');
    }
  }
  
  /// 開始定期更新小工具
  static void _startPeriodicUpdates() {
    // 取消之前的計時器（如果有的話）
    _updateTimer?.cancel();
    
    // 創建新的計時器，每分鐘更新一次小工具
    _updateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      updateWidget();
    });
    
    // 先立即執行一次更新
    updateWidget();
  }
  
  /// 確保數據已正確儲存到本地（用於檢測）
  static Future<void> _verifyDataSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final examYear = prefs.getInt(ExamDateCalculator.selectedExamYearKey) ?? 0;
    
    // 如果沒有獲取到考試年份，重新設置
    if (examYear == 0) {
      final calculator = ExamDateCalculator();
      final rocYear = calculator.getMinSelectableExamYear();
      await calculator.saveSelectedExamYear(rocYear);
      print('檢測到未設置會考年份，已自動設置為: $rocYear');
    } else {
      print('當前設置的會考年份為: $examYear');
    }
  }
  
  /// 更新小工具
  static Future<void> updateWidget() async {
    // 防止重複更新
    if (_isUpdating) return;
    
    // 檢查更新頻率
    final now = DateTime.now();
    if (_lastUpdateTime != null && 
        now.difference(_lastUpdateTime!).inSeconds < 30) {
      return;
    }
    
    try {
      _isUpdating = true;
      
      // 首先檢查數據是否存在
      await _verifyDataSaved();
      
      // 獲取考試日期計算器
      final calculator = ExamDateCalculator();
      
      // 獲取剩餘時間
      final remainingTime = await calculator.getRemainingTime();
      
      // 獲取考試日期
      final examDate = await calculator.getNextExamDate();
      
      // 獲取考試年份
      final examYear = await calculator.getSelectedExamYear();
      
      // 獲取考試狀態
      final examStatus = await calculator.getExamStatus();
      
      // 獲取考試日期格式化
      final examDateFormatted = await calculator.formatExamDate();
      
      print('更新小工具數據: 年份=$examYear, 狀態=$examStatus, 倒數=${remainingTime.toString()}, 日期=$examDateFormatted');
      
      // 更新小工具數據
      await HomeWidget.saveWidgetData('countdown_days', remainingTime['days'].toString());
      await HomeWidget.saveWidgetData('exam_date', examDate?.toIso8601String());
      await HomeWidget.saveWidgetData('exam_year', examYear.toString());
      await HomeWidget.saveWidgetData('exam_status', examStatus);
      await HomeWidget.saveWidgetData('exam_date_formatted', examDateFormatted);
      
      // 更新小工具
      await HomeWidget.updateWidget(
        name: widgetName,
        androidName: 'ExamCountdownWidget',
        qualifiedAndroidName: 'com.hwaiting.ExamCountdownWidget',
      );
      
      _lastUpdateTime = now;
    } catch (e) {
      print('更新小工具失敗: $e');
    } finally {
      _isUpdating = false;
    }
  }
  
  /// 強制更新小工具
  static Future<void> forceUpdateWidget() async {
    _lastUpdateTime = null;
    await updateWidget();
  }
  
  /// 釋放資源
  static void dispose() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }
}
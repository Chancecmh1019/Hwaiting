import 'package:home_widget/home_widget.dart';
import 'dart:async';
import 'exam_date_calculator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 桌面小工具更新服務
class WidgetService {
  static const String appGroupId = 'group.com.hwaiting';
  static const String widgetName = 'ExamCountdownWidget';
  static Timer? _updateTimer;
  
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
    
    // 創建新的計時器，每10秒更新一次小工具 (提高更新頻率)
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
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
      final rocYear = ExamDateCalculator.getMinSelectableExamYear();
      await ExamDateCalculator.saveSelectedExamYear(rocYear);
      print('檢測到未設置會考年份，已自動設置為: $rocYear');
    } else {
      print('當前設置的會考年份為: $examYear');
    }
  }
  
  /// 更新桌面小工具
  static Future<void> updateWidget() async {
    try {
      // 首先檢查數據是否存在
      await _verifyDataSaved();
      
      // 獲取倒數時間
      final remainingTime = await ExamDateCalculator.getRemainingTime();
      final rocYear = await ExamDateCalculator.getExamRocYear();
      final examStatus = await ExamDateCalculator.getExamStatus();
      
      print('更新小工具數據: 年份=$rocYear, 狀態=$examStatus, 倒數=${remainingTime.toString()}');
      
      // 更新小工具數據
      await HomeWidget.saveWidgetData('years', remainingTime['years']);
      await HomeWidget.saveWidgetData('months', remainingTime['months']);
      await HomeWidget.saveWidgetData('days', remainingTime['days']);
      await HomeWidget.saveWidgetData('hours', remainingTime['hours']);
      await HomeWidget.saveWidgetData('minutes', remainingTime['minutes']);
      await HomeWidget.saveWidgetData('seconds', remainingTime['seconds']);
      await HomeWidget.saveWidgetData('examYear', rocYear);
      await HomeWidget.saveWidgetData('examStatus', examStatus);
      await HomeWidget.saveWidgetData('lastUpdated', DateTime.now().millisecondsSinceEpoch);
      
      // 確保更新數據已經寫入
      await Future.delayed(const Duration(milliseconds: 50)); 
      
      // 更新小工具
      await HomeWidget.updateWidget(
        name: widgetName,
        androidName: widgetName,
        iOSName: widgetName,
      );
      
      // 雙重更新 Android 小工具確保立即更新
      try {
        await Future.delayed(const Duration(milliseconds: 100));
        await HomeWidget.updateWidget(
          androidName: widgetName,
        );
        
        // 再次更新確保穩定
        await Future.delayed(const Duration(milliseconds: 200));
        await HomeWidget.updateWidget(
          androidName: widgetName,
        );
      } catch (e) {
        print('更新 Android 小工具時發生錯誤: $e');
      }
    } catch (e) {
      print('更新小工具時發生錯誤: $e');
    }
  }
  
  /// 手動強制更新小工具
  static Future<void> forceUpdateWidget() async {
    await updateWidget();
    print('已強制更新小工具');
  }
  
  /// 釋放資源
  static void dispose() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }
} 
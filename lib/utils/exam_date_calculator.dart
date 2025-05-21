import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ExamDateCalculator {
  // 儲存選擇的會考年份的 key
  static const String selectedExamYearKey = 'selected_exam_year';
  
  /// 計算給定年份的會考日期（民國年）
  /// 台灣會考都在5月的第三個週六舉行
  DateTime calculateExamDate(int rocYear) {
    // 將民國年轉換為西元年
    final gregorianYear = rocYear + 1911;
    
    // 找出當年5月1日是星期幾
    final may1 = DateTime(gregorianYear, 5, 1);
    final may1Weekday = may1.weekday; // 1代表週一，7代表週日
    
    // 計算第一個週六的日期
    // DateTime的weekday: 1-7表示週一至週日
    // 所以，到週六的距離是：(6 - weekday) % 7 + 1
    // 但是如果剛好5月1日是週六，這裡會算出7，所以我們用 (13 - weekday) % 7 來計算
    final daysToFirstSaturday = (13 - may1Weekday) % 7;
    final firstSaturday = may1.add(Duration(days: daysToFirstSaturday));
    
    // 第三個週六就是第一個週六加14天
    final thirdSaturday = firstSaturday.add(const Duration(days: 14));
    
    // 設定會考開始時間為早上8:20
    return DateTime(
      thirdSaturday.year,
      thirdSaturday.month,
      thirdSaturday.day,
      8, // 小時
      20, // 分鐘
    );
  }
  
  /// 獲取當前的民國年
  int getCurrentRocYear() {
    final now = DateTime.now();
    return now.year - 1911;
  }
  
  /// 檢查指定會考年份是否已過期
  bool isExamYearExpired(int rocYear) {
    final now = DateTime.now();
    final examDate = calculateExamDate(rocYear);
    final examEndDate = DateTime(examDate.year, examDate.month, examDate.day + 1, 24, 0); // 隔天晚上12點
    return now.isAfter(examEndDate);
  }
  
  /// 獲取可選擇的最小會考年份（不能選擇已過期的會考）
  int getMinSelectableExamYear() {
    final currentRocYear = getCurrentRocYear();
    return isExamYearExpired(currentRocYear) ? currentRocYear + 1 : currentRocYear;
  }
  
  /// 獲取可選擇的會考年份列表（當前年份到未來3年）
  List<int> getSelectableExamYears() {
    final minYear = getMinSelectableExamYear();
    return [minYear, minYear + 1, minYear + 2, minYear + 3];
  }
  
  /// 保存選擇的會考年份
  Future<void> saveSelectedExamYear(int rocYear) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(selectedExamYearKey, rocYear);
  }
  
  /// 獲取儲存的選擇會考年份，如果沒有設定則返回當前可選的最小年份
  Future<int> getSelectedExamYear() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedYear = prefs.getInt(selectedExamYearKey);
    
    if (selectedYear == null) {
      // 如果沒有選擇，使用最小可選年份
      final minYear = getMinSelectableExamYear();
      await saveSelectedExamYear(minYear);
      return minYear;
    }
    
    // 確保選擇的年份不是過期的
    if (isExamYearExpired(selectedYear)) {
      final minYear = getMinSelectableExamYear();
      await saveSelectedExamYear(minYear);
      return minYear;
    }
    
    return selectedYear;
  }
  
  /// 獲取目前設定的會考日期
  Future<DateTime?> getNextExamDate() async {
    // 獲取用戶選擇的會考年份
    final selectedRocYear = await getSelectedExamYear();
    
    // 使用calculateExamDate方法直接計算選定年份的會考日期
    final examDate = calculateExamDate(selectedRocYear);
    
    return examDate;
  }
  
  /// 計算從現在到會考的剩餘時間
  Future<Map<String, int>> getRemainingTime() async {
    final now = DateTime.now();
    // 重新獲取最新的會考日期，確保年份切換後能正確計算
    final selectedYear = await getSelectedExamYear();
    final examDate = calculateExamDate(selectedYear);
    
    // 計算總秒數差
    final difference = examDate.difference(now);
    final totalSeconds = difference.inSeconds;
    
    if (totalSeconds <= 0) {
      return {
        'days': 0,
        'hours': 0,
        'minutes': 0,
        'seconds': 0,
      };
    }
    
    // 直接使用 Duration 計算總天數、小時、分鐘和秒數
    final days = difference.inDays;
    final hours = difference.inHours.remainder(24);
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);
    
    return {
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
    };
  }
  
  /// 取得會考年份的民國年
  Future<int> getExamRocYear() async {
    return await getSelectedExamYear();
  }
  
  /// 判斷目前是否處於會考特殊時期
  Future<String> getExamStatus() async {
    final now = DateTime.now();
    final selectedYear = await getSelectedExamYear();
    final examDate = calculateExamDate(selectedYear);
    
    // 考試當天早上 00:00 到 08:20
    final examDayMorning = DateTime(examDate.year, examDate.month, examDate.day, 0, 0);
    // 會考結束時間（隔天 12:30）
    final examEndTime = DateTime(examDate.year, examDate.month, examDate.day + 1, 12, 30);
    // 慶祝結束時間（隔天 24:00）
    final celebrationEndTime = DateTime(examDate.year, examDate.month, examDate.day + 1, 24, 0);
    
    if (now.isAfter(examDayMorning) && now.isBefore(examDate)) {
      return 'before_exam'; // 會考當天，但還未開始
    } else if (now.isAfter(examDate) && now.isBefore(examEndTime)) {
      return 'during_exam'; // 會考進行中
    } else if (now.isAfter(examEndTime) && now.isBefore(celebrationEndTime)) {
      return 'after_exam'; // 會考結束，慶祝時間
    } else {
      return 'normal'; // 正常倒數階段
    }
  }
  
  /// 判斷指定年月的日期有幾天
  int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
  
  /// 返回最小值
  int min(int a, int b) {
    return a < b ? a : b;
  }
  
  /// 格式化會考日期為易讀形式
  Future<String> formatExamDate() async {
    final examDate = await getNextExamDate();
    if (examDate == null) return '未設定會考日期';
    
    final year = examDate.year;
    final month = examDate.month;
    final day = examDate.day;
    final nextDay = examDate.add(const Duration(days: 1)).day;
    
    return '$year年$month月$day日~$nextDay日';
  }
  
  /// 格式化會考日期為小工具顯示
  Future<String> formatExamDateForWidget() async {
    final examDate = await getNextExamDate();
    if (examDate == null) return '未設定會考日期';
    
    final rocYear = examDate.year - 1911;
    final formatter = DateFormat('MM/dd');
    return '$rocYear年 ${formatter.format(examDate)}';
  }
}
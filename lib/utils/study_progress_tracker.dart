import 'package:shared_preferences/shared_preferences.dart';

/// 學習進度追蹤服務
/// 用於記錄和管理用戶的學習進度
class StudyProgressTracker {
  // 儲存鍵名
  static const String _subjectsKey = 'study_subjects';
  static const String _progressPrefix = 'progress_';
  static const String _goalsPrefix = 'goals_';
  static const String _lastStudyDatePrefix = 'last_study_';
  static const String _totalProgressKey = 'total_study_progress';
  
  // 預設科目列表
  static const List<String> defaultSubjects = [
    '國文',
    '英文',
    '數學',
    '自然',
    '社會',
  ];
  
  /// 初始化學習進度追蹤器
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 檢查是否已有科目列表，如果沒有則初始化
    if (!prefs.containsKey(_subjectsKey)) {
      await prefs.setStringList(_subjectsKey, defaultSubjects);
      
      // 為每個科目初始化進度為0
      for (final subject in defaultSubjects) {
        await prefs.setInt('$_progressPrefix$subject', 0);
        await prefs.setInt('$_goalsPrefix$subject', 100);
      }
    }
    
    if (!prefs.containsKey(_totalProgressKey)) {
      await prefs.setDouble(_totalProgressKey, 0.0);
    }
  }
  
  /// 獲取所有科目列表
  static Future<List<String>> getSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_subjectsKey) ?? defaultSubjects;
  }
  
  /// 添加新科目
  static Future<bool> addSubject(String subject) async {
    if (subject.isEmpty) return false;
    
    final prefs = await SharedPreferences.getInstance();
    final subjects = prefs.getStringList(_subjectsKey) ?? defaultSubjects;
    
    // 檢查科目是否已存在
    if (subjects.contains(subject)) return false;
    
    // 添加新科目
    subjects.add(subject);
    await prefs.setStringList(_subjectsKey, subjects);
    
    // 初始化新科目的進度
    await prefs.setInt('$_progressPrefix$subject', 0);
    await prefs.setInt('$_goalsPrefix$subject', 100);
    
    return true;
  }
  
  /// 刪除科目
  static Future<bool> removeSubject(String subject) async {
    final prefs = await SharedPreferences.getInstance();
    final subjects = prefs.getStringList(_subjectsKey) ?? defaultSubjects;
    
    // 檢查科目是否存在
    if (!subjects.contains(subject)) return false;
    
    // 移除科目
    subjects.remove(subject);
    await prefs.setStringList(_subjectsKey, subjects);
    
    // 清除相關數據
    await prefs.remove('$_progressPrefix$subject');
    await prefs.remove('$_goalsPrefix$subject');
    await prefs.remove('$_lastStudyDatePrefix$subject');
    
    return true;
  }
  
  /// 獲取科目進度
  static Future<int> getSubjectProgress(String subject) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_progressPrefix$subject') ?? 0;
  }
  
  /// 設置科目進度
  static Future<void> setSubjectProgress(String subject, int progress) async {
    if (progress < 0) progress = 0;
    if (progress > 100) progress = 100;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_progressPrefix$subject', progress);
    
    // 更新最後學習日期
    await prefs.setString(
      '$_lastStudyDatePrefix$subject',
      DateTime.now().toIso8601String(),
    );
  }
  
  /// 增加科目進度
  static Future<int> incrementSubjectProgress(String subject, int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final currentProgress = prefs.getInt('$_progressPrefix$subject') ?? 0;
    
    // 計算新進度
    int newProgress = currentProgress + amount;
    if (newProgress < 0) newProgress = 0;
    if (newProgress > 100) newProgress = 100;
    
    // 儲存新進度
    await prefs.setInt('$_progressPrefix$subject', newProgress);
    
    // 更新最後學習日期
    await prefs.setString(
      '$_lastStudyDatePrefix$subject',
      DateTime.now().toIso8601String(),
    );
    
    return newProgress;
  }
  
  /// 獲取科目目標
  static Future<int> getGoal(String subject) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_goalsPrefix$subject') ?? 100;
  }
  
  /// 設置科目目標
  static Future<void> setGoal(String subject, int goal) async {
    if (goal < 0) goal = 0;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_goalsPrefix$subject', goal);
  }
  
  /// 獲取最後學習日期
  static Future<DateTime?> getLastStudyDate(String subject) async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString('$_lastStudyDatePrefix$subject');
    
    if (dateStr == null) return null;
    
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }
  
  /// 獲取所有科目的進度摘要
  static Future<Map<String, Map<String, dynamic>>> getAllProgressSummary() async {
    final subjects = await getSubjects();
    final Map<String, Map<String, dynamic>> result = {};
    
    for (final subject in subjects) {
      final progress = await getSubjectProgress(subject);
      final goal = await getGoal(subject);
      final lastStudyDate = await getLastStudyDate(subject);
      
      result[subject] = {
        'progress': progress,
        'goal': goal,
        'lastStudyDate': lastStudyDate,
        'percentage': goal > 0 ? (progress / goal * 100).round() : 0,
      };
    }
    
    return result;
  }
  
  /// 計算總體學習進度百分比
  static Future<int> getTotalProgressPercentage() async {
    final subjects = await getSubjects();
    if (subjects.isEmpty) return 0;
    
    int totalProgress = 0;
    
    for (final subject in subjects) {
      final progress = await getSubjectProgress(subject);
      final goal = await getGoal(subject);
      
      if (goal > 0) {
        totalProgress += (progress / goal * 100).round();
      }
    }
    
    return (totalProgress / subjects.length).round();
  }
  
  /// 獲取學習建議
  static Future<List<Map<String, dynamic>>> getStudySuggestions() async {
    final summary = await getAllProgressSummary();
    final List<Map<String, dynamic>> suggestions = [];
    
    // 按進度百分比排序（從低到高）
    final sortedSubjects = summary.keys.toList()
      ..sort((a, b) => 
          (summary[a]!['percentage'] as int).compareTo(summary[b]!['percentage'] as int));
    
    // 為進度較低的科目提供建議
    for (final subject in sortedSubjects) {
      final data = summary[subject]!;
      final percentage = data['percentage'] as int;
      final lastStudyDate = data['lastStudyDate'] as DateTime?;
      
      String suggestion = '';
      int priority = 0; // 0-10，數字越大優先級越高
      
      if (percentage < 30) {
        suggestion = '$subject進度較低，建議加強學習';
        priority = 10;
      } else if (percentage < 60) {
        suggestion = '$subject需要更多練習';
        priority = 7;
      } else if (percentage < 90) {
        suggestion = '$subject進度良好，繼續保持';
        priority = 4;
      } else {
        suggestion = '$subject已接近完成，可以進行總複習';
        priority = 2;
      }
      
      // 檢查最後學習時間
      if (lastStudyDate != null) {
        final daysSinceLastStudy = DateTime.now().difference(lastStudyDate).inDays;
        
        if (daysSinceLastStudy > 7) {
          suggestion += '，已有${daysSinceLastStudy}天未學習';
          priority += 3;
        } else if (daysSinceLastStudy > 3) {
          suggestion += '，已有${daysSinceLastStudy}天未學習';
          priority += 1;
        }
      } else {
        suggestion += '，尚未開始學習';
        priority += 2;
      }
      
      suggestions.add({
        'subject': subject,
        'suggestion': suggestion,
        'priority': priority,
        'percentage': percentage,
      });
    }
    
    // 按優先級排序（從高到低）
    suggestions.sort((a, b) => (b['priority'] as int).compareTo(a['priority'] as int));
    
    return suggestions;
  }
  
  /// 獲取總體進度
  static Future<double> getTotalProgress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_totalProgressKey) ?? 0.0;
  }
  
  /// 更新總體進度
  static Future<void> updateTotalProgress(double progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_totalProgressKey, progress.clamp(0.0, 100.0));
  }
}
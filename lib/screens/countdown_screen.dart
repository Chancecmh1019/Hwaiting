import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../utils/exam_date_calculator.dart';
import '../utils/widget_service.dart';
import '../utils/notification_service.dart';

class CountdownScreen extends StatefulWidget {
  final Function(ThemeMode)? toggleThemeMode;
  
  const CountdownScreen({super.key, this.toggleThemeMode});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  Timer? _timer;
  int _selectedExamYear = 0;
  bool _isFirstLoad = true;
  
  // 通知服務
  final NotificationService _notificationService = NotificationService();
  Map<String, int> _remainingTime = {
    'days': 0,
    'hours': 0,
    'minutes': 0,
    'seconds': 0,
  };
  List<int> _selectableYears = [];
  String _examDateFormatted = '';
  String _examStatus = 'normal';
  DateTime? _examDate;
  
  // 慶祝特效控制器
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 10),
  );
  bool _isConfettiPlaying = false;
  
  @override
  void initState() {
    super.initState();
    _initializeData();
    _initializeNotifications();
  }

  Future<void> _initializeData() async {
    // 創建計算器實例
    final calculator = ExamDateCalculator();
    
    // 獲取可選擇的年份列表
    _selectableYears = calculator.getSelectableExamYears();
    
    // 獲取已儲存的會考年份
    _selectedExamYear = await calculator.getSelectedExamYear();
    
    // 獲取格式化後的會考日期
    _examDateFormatted = await calculator.formatExamDate();
    
    // 獲取會考日期
    _examDate = await calculator.getNextExamDate();
    
    // 獲取會考狀態
    _examStatus = await calculator.getExamStatus();
    
    // 如果是慶祝狀態，啟動慶祝特效
    if (_examStatus == 'after_exam') {
      _startConfetti();
    }
    
    // 獲取第一次的倒數時間
    _remainingTime = await calculator.getRemainingTime();
    
    // 定期更新倒數時間（每秒一次）
    _startTimer();
    
    // 首次載入完成後強制更新小工具
    if (_isFirstLoad) {
      _isFirstLoad = false;
      WidgetService.forceUpdateWidget();
    }
    
    // 使用 setState 更新 UI
    if (mounted) {
      setState(() {});
    }
  }

  void _startTimer() {
    // 取消現有的計時器
    _timer?.cancel();
    
    // 創建每秒更新的計時器
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (mounted) {
        final calculator = ExamDateCalculator();
        _remainingTime = await calculator.getRemainingTime();
        // 檢查會考狀態是否需要更新
        final newStatus = await calculator.getExamStatus();
        
        setState(() {
          _examStatus = newStatus;
          
          // 如果是慶祝狀態且特效未播放，啟動慶祝特效
          if (_examStatus == 'after_exam' && !_isConfettiPlaying) {
            _startConfetti();
          }
        });
      }
    });
  }

  /// 啟動慶祝特效
  void _startConfetti() {
    _confettiController.play();
    _isConfettiPlaying = true;
  }

  // 處理會考年份變更
  Future<void> _handleYearChanged(int? year) async {
    if (year != null && year != _selectedExamYear) {
      // 儲存新選擇的年份
      final calculator = ExamDateCalculator();
      await calculator.saveSelectedExamYear(year);
      
      // 更新狀態
      _selectedExamYear = year;
      _examDateFormatted = await calculator.formatExamDate();
      _examDate = await calculator.getNextExamDate();
      _examStatus = await calculator.getExamStatus();
      _remainingTime = await calculator.getRemainingTime();
      
      // 特效處理
      if (_examStatus == 'after_exam' && !_isConfettiPlaying) {
        _startConfetti();
      } else {
        _confettiController.stop();
        _isConfettiPlaying = false;
      }
      
      // 強制更新小工具確保同步
      await WidgetService.forceUpdateWidget();
      
      if (mounted) {
        setState(() {});
        
        // 顯示提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已切換至 $year 年會考'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  /// 手動更新小工具
  void _updateWidget() async {
    await WidgetService.forceUpdateWidget();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('已更新桌面小工具'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
  
  /// 切換主題模式
  void _toggleTheme() {
    if (widget.toggleThemeMode != null) {
    final currentBrightness = Theme.of(context).brightness;
    final newMode = currentBrightness == Brightness.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
      widget.toggleThemeMode!(newMode);
      
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
              newMode == ThemeMode.dark ? '已切換至深色主題' : '已切換至淺色主題',
            ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            duration: const Duration(seconds: 2),
        ),
      );
      }
    }
  }
  
  /// 初始化通知
  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }
  
  /// 分享倒數計時
  void _shareCountdown() {
    final String shareText = '距離 $_selectedExamYear 年國中教育會考還剩：\n'
        '${_remainingTime['days']} 天 ${_remainingTime['hours']} 小時 '
        '${_remainingTime['minutes']} 分鐘 ${_remainingTime['seconds']} 秒鐘\n'
        '考試日期：$_examDateFormatted\n'
        '加油！你一定行！';
    
    Share.share(shareText, subject: '$_selectedExamYear 年會考倒數');
  }
  
  /// 顯示學習資源
  void _showStudyResources() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '會考學習資源',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildResourceCard(
                    title: '國中教育會考官方網站',
                    description: '查詢最新會考資訊、考試時間、考場規則等官方資料',
                    icon: Icons.school,
                    onTap: () => _launchURL('https://cap.rcpet.edu.tw/'),
                  ),
                  _buildResourceCard(
                    title: '歷年會考試題下載',
                    description: '下載歷年會考試題及解答，進行模擬練習',
                    icon: Icons.history_edu,
                    onTap: () => _launchURL('https://cap.rcpet.edu.tw/exam/'),
                  ),
                  _buildResourceCard(
                    title: '均一教育平台',
                    description: '提供國中各科免費學習資源及練習題',
                    icon: Icons.play_lesson,
                    onTap: () => _launchURL('https://www.junyiacademy.org/'),
                  ),
                  _buildResourceCard(
                    title: '學習吧',
                    description: '豐富的國中會考各科學習資源及影片',
                    icon: Icons.video_library,
                    onTap: () => _launchURL('https://www.learnmode.net/'),
                  ),
                  _buildResourceCard(
                    title: '翰林雲端學院',
                    description: '提供國中各科教學影片及練習題',
                    icon: Icons.cloud,
                    onTap: () => _launchURL('https://www.ehanlin.com.tw/'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 建立資源卡片
  Widget _buildResourceCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 打開URL
  void _launchURL(String url) async {
    try {
      await Share.share('$url\n\n分享自會考倒數App');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('無法開啟連結: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// 設定通知
  Future<void> _setNotification() async {
    if (_examDate == null) return;

    // 顯示通知設定對話框
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('設定會考提醒'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('請選擇要提前幾天收到通知：'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildNotificationOption(1),
                _buildNotificationOption(3),
                _buildNotificationOption(7),
                _buildNotificationOption(14),
                _buildNotificationOption(30),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
    
    if (result != null && _examDate != null) {
      // 計算提醒時間
      final reminderDate = _examDate!.subtract(Duration(days: result));
      
      // 如果提醒時間已經過了，顯示錯誤
      if (reminderDate.isBefore(DateTime.now())) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('無法設定已過期的提醒時間'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      
      // 設定通知
      await _notificationService.scheduleNotification(
        id: 1, // 添加缺少的id參數
        title: '會考提醒',
        body: '距離 $_selectedExamYear 年會考還有 $result 天，請做好準備！',
        scheduledDate: reminderDate,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已設定會考前 $result 天提醒通知'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildNotificationOption(int days) {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context, days),
      child: Text('$days 天'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (_examDate == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primaryContainer,
                colorScheme.surface,
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('會考倒數計時'),
        centerTitle: true,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          // 主題切換按鈕
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.light 
                ? Icons.dark_mode : Icons.light_mode),
            onPressed: _toggleTheme,
            tooltip: '切換主題',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _updateWidget,
            tooltip: '更新小工具',
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // 會考年份資訊和選擇器
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_selectedExamYear年會考',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<int>(
                        icon: Icon(
                          Icons.arrow_drop_down_circle,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        onSelected: _handleYearChanged,
                        itemBuilder: (context) {
                          return _selectableYears.map((year) {
                            return PopupMenuItem<int>(
                              value: year,
                              child: Text('$year年會考'),
                            );
                          }).toList();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 會考日期資訊
                  Text(
                    _examDateFormatted,
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 會考狀態訊息
                  if (_examStatus != 'normal')
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Card(
                        color: _getStatusColor(colorScheme, _examStatus),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                _getStatusIcon(_examStatus),
                                color: _getStatusTextColor(colorScheme, _examStatus),
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _getStatusMessage(_examStatus),
                                  style: TextStyle(
                                    color: _getStatusTextColor(colorScheme, _examStatus),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  // 倒數計時區域（只在正常或考前顯示）
                  if (_examStatus == 'normal' || _examStatus == 'before_exam')
                    Expanded(
                      child: Card(
                        margin: const EdgeInsets.all(16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _examStatus == 'before_exam' 
                                    ? Colors.amber.withOpacity(0.8) 
                                    : colorScheme.primary.withOpacity(0.8),
                                _examStatus == 'before_exam' 
                                    ? Colors.amber 
                                    : colorScheme.primary,
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '距離會考還剩',
                                style: TextStyle(
                                  color: _examStatus == 'before_exam' 
                                      ? Colors.black87 
                                      : colorScheme.onPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 30),
                              // 時間單位顯示區域 - 天、小時、分鐘、秒鐘
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildTimeBlock(
                                      colorScheme,
                                      _remainingTime['days'] ?? 0,
                                      '天',
                                      _examStatus,
                                    ),
                                    _buildTimeBlock(
                                      colorScheme,
                                      _remainingTime['hours'] ?? 0,
                                      '小時',
                                      _examStatus,
                                    ),
                                    _buildTimeBlock(
                                      colorScheme,
                                      _remainingTime['minutes'] ?? 0,
                                      '分鐘',
                                      _examStatus,
                                    ),
                                    _buildTimeBlock(
                                      colorScheme,
                                      _remainingTime['seconds'] ?? 0,
                                      '秒鐘',
                                      _examStatus,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              // 添加學習資源按鈕
                              if (_examStatus == 'normal' || _examStatus == 'before_exam')
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: FilledButton.icon(
                                    onPressed: _showStudyResources,
                                    icon: const Icon(Icons.menu_book),
                                    label: const Text('會考學習資源'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: colorScheme.primaryContainer,
                                      foregroundColor: colorScheme.onPrimaryContainer,
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // 會考進行中或結束後的顯示
                  if (_examStatus == 'during_exam' || _examStatus == 'after_exam')
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _examStatus == 'during_exam' ? Icons.pending_actions : Icons.celebration,
                                size: 80,
                                color: _examStatus == 'during_exam' ? Colors.green : Colors.pink,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _examStatus == 'during_exam' 
                                    ? '$_selectedExamYear年會考正在進行中' 
                                    : '$_selectedExamYear年會考已圓滿結束',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onBackground,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _examStatus == 'during_exam' 
                                    ? '專心考試，相信自己，你一定行！' 
                                    : '恭喜你完成這重要的一步，未來將更加精彩！',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colorScheme.onBackground.withOpacity(0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // 操作按鈕區 - 使用Material 3設計
                  if (_examStatus == 'normal' || _examStatus == 'before_exam')
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: FilledButton.tonalIcon(
                              onPressed: _updateWidget,
                              icon: const Icon(Icons.refresh),
                              label: const Text('更新小工具'),
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.primaryContainer,
                                foregroundColor: colorScheme.onPrimaryContainer,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton.tonalIcon(
                              onPressed: _shareCountdown,
                              icon: const Icon(Icons.share),
                              label: const Text('分享倒數'),
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.secondaryContainer,
                                foregroundColor: colorScheme.onSecondaryContainer,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton.tonalIcon(
                              onPressed: _setNotification,
                              icon: const Icon(Icons.notifications),
                              label: const Text('設定提醒'),
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.tertiaryContainer,
                                foregroundColor: colorScheme.onTertiaryContainer,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // 提示資訊
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 0,
                      color: colorScheme.secondaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: colorScheme.onSecondaryContainer,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '會考時間為每年五月的第三個週六與週日',
                                style: TextStyle(
                                  color: colorScheme.onSecondaryContainer,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 慶祝特效
          if (_examStatus == 'after_exam')
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: math.pi / 2, // 下方
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                maxBlastForce: 20,
                minBlastForce: 5,
                gravity: 0.1,
              ),
            ),
        ],
      ),
    );
  }

  /// 建立時間區塊顯示元件
  Widget _buildTimeBlock(ColorScheme colorScheme, int value, String unit, String examStatus) {
    final bool isBeforeExam = examStatus == 'before_exam';
    
    return Expanded(
      child: Card(
            elevation: 2,
            shadowColor: colorScheme.shadow.withOpacity(0.2),
            shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
              side: isBeforeExam 
              ? BorderSide(color: colorScheme.tertiary, width: 1) 
                  : BorderSide.none,
            ),
            child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                gradient: isBeforeExam
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.tertiaryContainer,
                          colorScheme.tertiary.withOpacity(0.7),
                        ],
                      )
                    : null,
                color: isBeforeExam ? null : colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
              ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isBeforeExam 
                      ? colorScheme.onTertiaryContainer 
                      : colorScheme.onSurfaceVariant,
                  letterSpacing: 1,
            ),
          ),
              const SizedBox(height: 4),
              Text(
              unit,
              style: TextStyle(
                  fontSize: 12,
                color: isBeforeExam 
                    ? colorScheme.onTertiaryContainer 
                      : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
  
  // 獲取狀態消息
  String _getStatusMessage(String status) {
    switch (status) {
      case 'before_exam':
        return '今天會考開始！加油，相信自己的準備！';
      case 'during_exam':
        return '會考進行中，沉著冷靜，發揮最佳水平！';
      case 'after_exam':
        return '恭喜！會考已結束，你已經戰勝了挑戰！';
      default:
        return '';
    }
  }
  
  // 獲取狀態圖標
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'before_exam':
        return Icons.flag;
      case 'during_exam':
        return Icons.pending_actions;
      case 'after_exam':
        return Icons.celebration;
      default:
        return Icons.info_outline;
    }
  }
  
  // 獲取狀態背景顏色
  Color _getStatusColor(ColorScheme colorScheme, String status) {
    switch (status) {
      case 'before_exam':
        return Colors.amber.shade100;
      case 'during_exam':
        return Colors.green.shade100;
      case 'after_exam':
        return Colors.pink.shade100;
      default:
        return colorScheme.secondaryContainer;
    }
  }
  
  // 獲取狀態文字顏色
  Color _getStatusTextColor(ColorScheme colorScheme, String status) {
    switch (status) {
      case 'before_exam':
        return Colors.amber.shade900;
      case 'during_exam':
        return Colors.green.shade900;
      case 'after_exam':
        return Colors.pink.shade900;
      default:
        return colorScheme.onSecondaryContainer;
    }
  }
}
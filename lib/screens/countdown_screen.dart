import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../utils/exam_date_calculator.dart';
import '../utils/widget_service.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  Timer? _timer;
  int _selectedExamYear = 0;
  bool _isFirstLoad = true;
  Map<String, int> _remainingTime = {
    'years': 0,
    'months': 0,
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
  }

  Future<void> _initializeData() async {
    // 獲取可選擇的年份列表
    _selectableYears = ExamDateCalculator.getSelectableExamYears();
    
    // 獲取已儲存的會考年份
    _selectedExamYear = await ExamDateCalculator.getSelectedExamYear();
    
    // 獲取格式化後的會考日期
    _examDateFormatted = await ExamDateCalculator.formatExamDate();
    
    // 獲取會考日期
    _examDate = await ExamDateCalculator.getNextExamDate();
    
    // 獲取會考狀態
    _examStatus = await ExamDateCalculator.getExamStatus();
    
    // 如果是慶祝狀態，啟動慶祝特效
    if (_examStatus == 'after_exam') {
      _startConfetti();
    }
    
    // 獲取第一次的倒數時間
    _remainingTime = await ExamDateCalculator.getRemainingTime();
    
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
        _remainingTime = await ExamDateCalculator.getRemainingTime();
        // 檢查會考狀態是否需要更新
        final newStatus = await ExamDateCalculator.getExamStatus();
        
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
      await ExamDateCalculator.saveSelectedExamYear(year);
      
      // 更新狀態
      _selectedExamYear = year;
      _examDateFormatted = await ExamDateCalculator.formatExamDate();
      _examDate = await ExamDateCalculator.getNextExamDate();
      _examStatus = await ExamDateCalculator.getExamStatus();
      _remainingTime = await ExamDateCalculator.getRemainingTime();
      
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
                              // 時間單位顯示區域 - 年、月、日
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildTimeUnit(colorScheme, '年', _remainingTime['years'] ?? 0, _examStatus),
                                    _buildTimeUnit(colorScheme, '月', _remainingTime['months'] ?? 0, _examStatus),
                                    _buildTimeUnit(colorScheme, '日', _remainingTime['days'] ?? 0, _examStatus),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              // 時間單位顯示區域 - 時、分、秒
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildTimeUnit(colorScheme, '時', _remainingTime['hours'] ?? 0, _examStatus),
                                    _buildTimeUnit(colorScheme, '分', _remainingTime['minutes'] ?? 0, _examStatus),
                                    _buildTimeUnit(colorScheme, '秒', _remainingTime['seconds'] ?? 0, _examStatus),
                                  ],
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
                  // 操作按鈕區
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: _updateWidget,
                          icon: const Icon(Icons.refresh),
                          label: const Text('更新小工具'),
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                                '會考時間為台灣每年5月第三個週六早上8:20開始',
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

  /// 建立時間單位顯示元件
  Widget _buildTimeUnit(ColorScheme colorScheme, String unit, int value, String examStatus) {
    final bool isBeforeExam = examStatus == 'before_exam';
    
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isBeforeExam ? Colors.white : colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: isBeforeExam ? Border.all(color: Colors.amber, width: 2) : null,
            ),
            child: Text(
              value.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isBeforeExam ? Colors.amber.shade900 : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isBeforeExam 
                  ? Colors.amber.withOpacity(0.3) 
                  : colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              unit,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isBeforeExam ? Colors.amber.shade900 : colorScheme.onPrimary,
              ),
            ),
          ),
        ],
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
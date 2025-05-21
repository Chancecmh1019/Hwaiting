import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'screens/countdown_screen.dart';
import 'screens/study_progress_screen.dart';
import 'screens/main_screen.dart';
import 'utils/widget_service.dart';
import 'utils/study_progress_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 設定錯誤處理
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('錯誤: ${details.exception}');
    debugPrint('堆疊追蹤: ${details.stack}');
  };
  
  // 設定全域異常處理
  runZonedGuarded(() async {
    // 初始化服務
    await _initializeServices();
    
    // 運行應用程式
    runApp(const MyApp());
  }, (error, stack) {
    debugPrint('未處理的錯誤: $error');
    debugPrint('錯誤堆疊: $stack');
  });
}

Future<void> _initializeServices() async {
  try {
    // 初始化 SharedPreferences
    await SharedPreferences.getInstance();
    
    // 初始化小工具服務
    await WidgetService.init();
    
    // 初始化學習進度追蹤
    await StudyProgressTracker.initialize();
    
    // 設定系統UI
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    
    // 設定螢幕方向
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    debugPrint('初始化服務失敗: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  // 從SharedPreferences加載主題模式設置
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
    setState(() {
      _themeMode = ThemeMode.values[themeModeIndex];
    });
  }

  // 保存主題模式設置到SharedPreferences
  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  // 切換主題模式
  void _toggleThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    _saveThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '會考倒數',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: MainScreen(toggleThemeMode: _toggleThemeMode),
      debugShowCheckedModeBanner: false,
    );
  }
}

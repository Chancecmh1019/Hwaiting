import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'screens/countdown_screen.dart';
import 'utils/widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化桌面小工具服務
  await WidgetService.init();
  
  // 啟動後立即強制更新小工具
  await WidgetService.forceUpdateWidget();
  
  // 監聽小工具點擊事件
  HomeWidget.widgetClicked.listen((uri) {
    // 處理小工具點擊事件
    print('小工具被點擊: $uri');
    // 點擊後立即更新
    WidgetService.forceUpdateWidget();
  });
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '國中教育會考倒數計時',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
          secondary: Colors.amber,
          secondaryContainer: const Color(0xFFE0F7FA), // 淺藍色背景
          onSecondaryContainer: const Color(0xFF00565E), // 深藍色文字
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const CountdownScreen(),
    );
  }
}

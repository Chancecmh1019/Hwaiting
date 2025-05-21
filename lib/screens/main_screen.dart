import 'package:flutter/material.dart';
import 'countdown_screen.dart';
import 'study_progress_screen.dart';
import 'grade_prediction_screen.dart';
import 'learning_resources_screen.dart';

class MainScreen extends StatefulWidget {
  final Function(ThemeMode)? toggleThemeMode;
  
  const MainScreen({super.key, this.toggleThemeMode});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  bool _isTransitioning = false;
  
  @override
  void initState() {
    super.initState();
    _screens = [
      CountdownScreen(toggleThemeMode: widget.toggleThemeMode),
      const StudyProgressScreen(),
      const GradePredictionScreen(),
      const LearningResourcesScreen(),
    ];
  }

  void _onTabChanged(int index) {
    if (_isTransitioning) return;
    
    setState(() {
      _isTransitioning = true;
      _currentIndex = index;
    });

    // 延遲重置過渡狀態
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isTransitioning = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabChanged,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: '倒數',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: '進度',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: '預測',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: '資源',
          ),
        ],
      ),
    );
  }
}
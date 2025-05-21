import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ExamIntroScreen extends StatefulWidget {
  const ExamIntroScreen({super.key});

  @override
  State<ExamIntroScreen> createState() => _ExamIntroScreenState();
}

class _ExamIntroScreenState extends State<ExamIntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<IntroPage> _pages = [
    IntroPage(
      title: '什麼是會考？',
      description: '國中教育會考是全國性的學力測驗，\n用來評估國中畢業生的基本學力。',
      animationPath: 'assets/animations/exam_intro_1.json',
    ),
    IntroPage(
      title: '考試科目',
      description: '包含國文、英文、數學、社會、自然五科，\n以及寫作測驗。',
      animationPath: 'assets/animations/exam_intro_2.json',
    ),
    IntroPage(
      title: '成績等級',
      description: '分為精熟(A++、A+、A)、\n基礎(B++、B+、B)和待加強(C)三個等級。',
      animationPath: 'assets/animations/exam_intro_3.json',
    ),
    IntroPage(
      title: '升學管道',
      description: '會考成績可用於：\n1. 免試入學\n2. 特色招生\n3. 技職教育',
      animationPath: 'assets/animations/exam_intro_4.json',
    ),
    IntroPage(
      title: '考前準備',
      description: '1. 了解考試範圍\n2. 制定讀書計畫\n3. 多做模擬試題\n4. 保持規律作息',
      animationPath: 'assets/animations/exam_intro_5.json',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 進度指示器
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ),
              // 內容頁面
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 動畫
                          Expanded(
                            flex: 3,
                            child: Lottie.asset(
                              page.animationPath,
                              width: 200,
                              height: 200,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.error_outline,
                                  size: 100,
                                  color: Theme.of(context).colorScheme.error,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                          // 標題
                          Text(
                            page.title,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          // 描述
                          Text(
                            page.description,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          // 最後一頁顯示確認按鈕
                          if (index == _pages.length - 1)
                            FilledButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('我了解了'),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // 導航按鈕
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('上一頁'),
                      )
                    else
                      const SizedBox(width: 80),
                    if (_currentPage < _pages.length - 1)
                      TextButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('下一頁'),
                      )
                    else
                      const SizedBox(width: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IntroPage {
  final String title;
  final String description;
  final String animationPath;

  IntroPage({
    required this.title,
    required this.description,
    required this.animationPath,
  });
} 
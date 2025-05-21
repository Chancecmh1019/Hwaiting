import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComprehensiveExamIntroScreen extends StatefulWidget {
  const ComprehensiveExamIntroScreen({super.key});

  @override
  State<ComprehensiveExamIntroScreen> createState() => _ComprehensiveExamIntroScreenState();
}

class _ComprehensiveExamIntroScreenState extends State<ComprehensiveExamIntroScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late TabController _tabController;
  int _currentPage = 0;
  bool _showSkipButton = true;
  
  // 控制動畫播放
  bool _playAnimation = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pages.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentPage = _tabController.index;
      });
    });
    
    // 檢查是否首次查看介紹
    _checkFirstView();
  }

  Future<void> _checkFirstView() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstView = prefs.getBool('first_view_comprehensive_exam') ?? true;
    
    if (!isFirstView) {
      setState(() {
        _showSkipButton = false;
      });
    } else {
      await prefs.setBool('first_view_comprehensive_exam', false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  final List<ExamIntroPage> _pages = [
    ExamIntroPage(
      title: '國中教育會考簡介',
      description: '國中教育會考是臺灣教育部為國民中學畢業生所舉辦的全國性學力檢測，'
          '於每年5月中旬舉行，是國中畢業生升學高中、高職的重要依據。',
      animationPath: 'assets/animations/comprehensive_exam_intro_1.json',
      detailSections: [
        DetailSection(
          title: '會考目的',
          content: '1. 檢測國中畢業生的學力水準\n'
              '2. 作為高中、高職及五專多元入學管道的參考依據\n'
              '3. 促進國民中學的教學正常化與品質提升',
        ),
        DetailSection(
          title: '實施時間',
          content: '每年5月中旬的星期六、日兩天舉行',
        ),
        DetailSection(
          title: '參加對象',
          content: '國中應屆畢業生及非應屆畢業生',
        ),
      ],
    ),
    ExamIntroPage(
      title: '考試科目與時間',
      description: '會考包含五個考科及一項寫作測驗，各科測驗時間不同。',
      animationPath: 'assets/animations/comprehensive_exam_intro_2.json',
      detailSections: [
        DetailSection(
          title: '考試科目',
          content: '1. 國文（含寫作測驗）\n'
              '2. 英語（含聽力測驗）\n'
              '3. 數學\n'
              '4. 社會\n'
              '5. 自然\n'
              '6. 寫作測驗',
        ),
        DetailSection(
          title: '考試時間',
          content: '國文：70分鐘\n'
              '英語：80分鐘（含聽力測驗20分鐘）\n'
              '數學：80分鐘\n'
              '社會：70分鐘\n'
              '自然：70分鐘\n'
              '寫作測驗：50分鐘',
        ),
        DetailSection(
          title: '題型',
          content: '選擇題：單選題、多選題\n'
              '非選擇題：填充、計算、繪圖等\n'
              '寫作測驗：引導寫作',
        ),
      ],
    ),
    ExamIntroPage(
      title: '成績等級與計算',
      description: '會考各科成績採等級制，分為精熟、基礎及待加強三個等級。',
      animationPath: 'assets/animations/comprehensive_exam_intro_3.json',
      detailSections: [
        DetailSection(
          title: '等級標準',
          content: '精熟（A++、A+、A）：熟練掌握該科目的學習內容\n'
              '基礎（B++、B+、B）：具備該科目的基本學力\n'
              '待加強（C）：尚未具備該科目的基本學力',
        ),
        DetailSection(
          title: '寫作測驗評分',
          content: '寫作測驗分為六級分，從一級分至六級分\n'
              '評分項目包括：\n'
              '- 立意取材\n'
              '- 結構組織\n'
              '- 遣詞造句\n'
              '- 錯別字與格式',
        ),
        DetailSection(
          title: '成績應用',
          content: '會考成績是免試入學超額比序的重要項目\n'
              '各高中職校可依據會考成績設定入學門檻',
        ),
      ],
    ),
    ExamIntroPage(
      title: '升學管道與應用',
      description: '會考成績可用於多元入學管道，包括免試入學、特色招生等。',
      animationPath: 'assets/animations/comprehensive_exam_intro_4.json',
      detailSections: [
        DetailSection(
          title: '免試入學',
          content: '依據「全國高級中等學校免試入學作業要點」\n'
              '各就學區可訂定超額比序項目，如多元學習表現、會考成績等\n'
              '占全國入學管道約85%的名額',
        ),
        DetailSection(
          title: '特色招生',
          content: '分為考試分發入學和甄選入學\n'
              '考試分發入學：採計國中會考成績作為門檻，再採計特色招生考試分數\n'
              '甄選入學：採計國中會考成績作為門檻，再採計術科測驗或面試等',
        ),
        DetailSection(
          title: '其他管道',
          content: '技優甄審入學\n'
              '實用技能學程\n'
              '建教合作班\n'
              '產學攜手合作計畫',
        ),
      ],
    ),
    ExamIntroPage(
      title: '考前準備策略',
      description: '有效的準備策略可以幫助考生在會考中取得好成績。',
      animationPath: 'assets/animations/comprehensive_exam_intro_5.json',
      detailSections: [
        DetailSection(
          title: '學習計畫',
          content: '制定合理的讀書計畫\n'
              '掌握各科重點\n'
              '定期複習與自我測驗',
        ),
        DetailSection(
          title: '模擬測驗',
          content: '參加學校或坊間舉辦的模擬考\n'
              '熟悉考試時間與題型\n'
              '分析錯題並加強弱點',
        ),
        DetailSection(
          title: '身心調適',
          content: '保持規律作息\n'
              '適度運動紓解壓力\n'
              '均衡飲食與充足睡眠\n'
              '培養正向思考的態度',
        ),
      ],
    ),
    ExamIntroPage(
      title: '重要日程與資源',
      description: '了解會考相關的重要日期與準備資源。',
      animationPath: 'assets/animations/comprehensive_exam_intro_6.json',
      detailSections: [
        DetailSection(
          title: '重要日程',
          content: '報名時間：每年3月初\n'
              '考試日期：每年5月中旬（星期六、日）\n'
              '成績公布：考後約一個月\n'
              '志願選填：成績公布後約一週',
        ),
        DetailSection(
          title: '官方資源',
          content: '國中教育會考網站：提供歷年試題、簡章等資訊\n'
              '國家教育研究院：提供學習資源與試題\n'
              '各縣市教育局：提供當地升學資訊',
        ),
        DetailSection(
          title: '學習資源',
          content: '歷年試題與解析\n'
              '各科複習講義\n'
              '線上學習平台\n'
              '教育部因材網',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('國中教育會考完整介紹'),
        centerTitle: true,
        actions: [
          if (_showSkipButton)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('跳過'),
            ),
        ],
      ),
      body: Column(
        children: [
          // 頂部標籤導航
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: _pages.map((page) => Tab(text: page.title)).toList(),
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            indicatorColor: Theme.of(context).colorScheme.primary,
          ),
          // 主要內容區域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _pages.map((page) => _buildPageContent(page)).toList(),
            ),
          ),
          // 底部導航按鈕
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  ElevatedButton(
                    onPressed: () {
                      _tabController.animateTo(_currentPage - 1);
                    },
                    child: const Text('上一頁'),
                  )
                else
                  const SizedBox(width: 80),
                Row(
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
                if (_currentPage < _pages.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      _tabController.animateTo(_currentPage + 1);
                    },
                    child: const Text('下一頁'),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('完成'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(ExamIntroPage page) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 動畫區域
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _playAnimation = !_playAnimation;
                  });
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Lottie.asset(
                    page.animationPath,
                    animate: _playAnimation,
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 描述文字
            Text(
              page.description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // 詳細內容區域
            ...page.detailSections.map((section) => _buildDetailSection(section)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(DetailSection section) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          section.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              section.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class ExamIntroPage {
  final String title;
  final String description;
  final String animationPath;
  final List<DetailSection> detailSections;

  ExamIntroPage({
    required this.title,
    required this.description,
    required this.animationPath,
    required this.detailSections,
  });
}

class DetailSection {
  final String title;
  final String content;

  DetailSection({
    required this.title,
    required this.content,
  });
}
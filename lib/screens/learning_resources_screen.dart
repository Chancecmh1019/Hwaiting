import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'comprehensive_exam_intro_screen.dart';

class LearningResourcesScreen extends StatelessWidget {
  const LearningResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('學習資源'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildCategoryCard(
            context,
            '官方資源',
            [
              ResourceItem(
                title: '國中教育會考網站',
                description: '官方會考資訊、簡章下載、歷屆試題',
                url: 'https://cap.rcpet.edu.tw/',
                icon: Icons.school,
              ),
              ResourceItem(
                title: '教育部十二年國教資訊網',
                description: '十二年國教相關政策與資訊',
                url: 'https://12basic.edu.tw/',
                icon: Icons.policy,
              ),
              ResourceItem(
                title: '國民中學學生基本學力測驗網站',
                description: '歷年會考試題與解答',
                url: 'https://cap.rcpet.edu.tw/exam/',
                icon: Icons.history_edu,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCategoryCard(
            context,
            '學科資源',
            [
              ResourceItem(
                title: '均一教育平台',
                description: '免費線上學習平台，包含各科教學影片與練習',
                url: 'https://www.junyiacademy.org/',
                icon: Icons.play_circle_filled,
              ),
              ResourceItem(
                title: '學習吧',
                description: '提供各科學習資源與互動練習',
                url: 'https://www.learnmode.net/',
                icon: Icons.book,
              ),
              ResourceItem(
                title: '翰林雲端學院',
                description: '提供國中各科教學影片與資源',
                url: 'https://www.ehanlin.com.tw/',
                icon: Icons.video_library,
              ),
              ResourceItem(
                title: '康軒文教',
                description: '提供國中各科學習資源與模擬試題',
                url: 'https://www.knsh.com.tw/',
                icon: Icons.menu_book,
              ),
              ResourceItem(
                title: '南一書局',
                description: '提供國中各科學習資源與模擬試題',
                url: 'https://www.nani.com.tw/',
                icon: Icons.book_online,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCategoryCard(
            context,
            '模擬測驗',
            [
              ResourceItem(
                title: '康軒模擬測驗',
                description: '提供國中會考模擬試題',
                url: 'https://www.knsh.com.tw/',
                icon: Icons.quiz,
              ),
              ResourceItem(
                title: '南一模擬測驗',
                description: '提供國中會考模擬試題與解析',
                url: 'https://www.nani.com.tw/',
                icon: Icons.assignment,
              ),
              ResourceItem(
                title: '翰林模擬測驗',
                description: '提供國中會考模擬試題與解析',
                url: 'https://www.ehanlin.com.tw/',
                icon: Icons.assignment_turned_in,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 會考介紹動畫卡片
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ComprehensiveExamIntroScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.animation,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '國中教育會考完整介紹',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.play_circle_filled),
                      ),
                      title: Text('互動式會考介紹動畫'),
                      subtitle: Text('了解會考科目、評分標準、重要日期等完整資訊'),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildCategoryCard(
            context,
            '學習方法',
            [
              ResourceItem(
                title: '高效學習技巧',
                description: '提供高效學習方法與時間管理技巧',
                url: 'https://shan-wealth.com/efficient-learning/',
                icon: Icons.lightbulb,
              ),
              ResourceItem(
                title: '考試減壓技巧',
                description: '提供考試前減壓與心理調適方法',
                url: 'https://flipedu.parenting.com.tw/article/005391',
                icon: Icons.spa,
              ),
              ResourceItem(
                title: '會考準備攻略',
                description: '提供會考準備策略與技巧',
                url: 'https://flipedu.parenting.com.tw/article/008187',
                icon: Icons.tips_and_updates,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, List<ResourceItem> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            ...items.map((item) => _buildResourceItem(context, item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceItem(BuildContext context, ResourceItem item) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(item.icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(item.title),
      subtitle: Text(item.description),
      trailing: const Icon(Icons.open_in_new),
      onTap: () async {
        final Uri url = Uri.parse(item.url);
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('無法開啟連結: ${item.url}')),
            );
          }
        }
      },
    );
  }
}

class ResourceItem {
  final String title;
  final String description;
  final String url;
  final IconData icon;

  ResourceItem({
    required this.title,
    required this.description,
    required this.url,
    required this.icon,
  });
}
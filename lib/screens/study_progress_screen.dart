import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart';

class StudyProgressScreen extends StatefulWidget {
  const StudyProgressScreen({super.key});

  @override
  State<StudyProgressScreen> createState() => _StudyProgressScreenState();
}

class _StudyProgressScreenState extends State<StudyProgressScreen> {
  final Map<String, double> _progress = {
    '國文': 0.0,
    '英文': 0.0,
    '數學': 0.0,
    '社會': 0.0,
    '自然': 0.0,
  };

  // 新增：每個科目的學習目標
  final Map<String, String> _goals = {
    '國文': '',
    '英文': '',
    '數學': '',
    '社會': '',
    '自然': '',
  };

  // 新增：每個科目的學習筆記
  final Map<String, String> _notes = {
    '國文': '',
    '英文': '',
    '數學': '',
    '社會': '',
    '自然': '',
  };

  // 新增：每個科目的最近更新時間
  final Map<String, DateTime?> _lastUpdated = {
    '國文': null,
    '英文': null,
    '數學': null,
    '社會': null,
    '自然': null,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadProgress();
    await _loadGoals();
    await _loadNotes();
    await _loadLastUpdated();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var subject in _progress.keys) {
        _progress[subject] = prefs.getDouble('progress_$subject') ?? 0.0;
      }
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    for (var entry in _progress.entries) {
      await prefs.setDouble('progress_${entry.key}', entry.value);
    }
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var subject in _goals.keys) {
        _goals[subject] = prefs.getString('goal_$subject') ?? '';
      }
    });
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    for (var entry in _goals.entries) {
      await prefs.setString('goal_${entry.key}', entry.value);
    }
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var subject in _notes.keys) {
        _notes[subject] = prefs.getString('note_$subject') ?? '';
      }
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    for (var entry in _notes.entries) {
      await prefs.setString('note_${entry.key}', entry.value);
    }
  }

  Future<void> _loadLastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var subject in _lastUpdated.keys) {
        final timestamp = prefs.getInt('lastUpdated_$subject');
        _lastUpdated[subject] = timestamp != null 
            ? DateTime.fromMillisecondsSinceEpoch(timestamp) 
            : null;
      }
    });
  }

  Future<void> _saveLastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    for (var entry in _lastUpdated.entries) {
      if (entry.value != null) {
        await prefs.setInt('lastUpdated_${entry.key}', entry.value!.millisecondsSinceEpoch);
      }
    }
  }

  void _updateProgress(String subject, double value) {
    setState(() {
      _progress[subject] = value;
      _lastUpdated[subject] = DateTime.now();
    });
    _saveProgress();
    _saveLastUpdated();
  }

  void _updateGoal(String subject, String goal) {
    setState(() {
      _goals[subject] = goal;
    });
    _saveGoals();
  }

  void _updateNote(String subject, String note) {
    setState(() {
      _notes[subject] = note;
    });
    _saveNotes();
  }

  // 計算總體進度
  double _calculateOverallProgress() {
    if (_progress.isEmpty) return 0.0;
    double sum = 0.0;
    for (var progress in _progress.values) {
      sum += progress;
    }
    return sum / _progress.length;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final overallProgress = _calculateOverallProgress();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('學習進度追蹤'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog(context);
            },
            tooltip: '使用說明',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 總體進度卡片
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '總體進度',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '${overallProgress.toInt()}%',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CircularPercentIndicator(
                      radius: 80.0,
                      lineWidth: 16.0,
                      percent: overallProgress / 100,
                      center: Text(
                        '${overallProgress.toInt()}%',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      progressColor: colorScheme.primary,
                      backgroundColor: colorScheme.surfaceVariant,
                      circularStrokeCap: CircularStrokeCap.round,
                      animation: true,
                      animationDuration: 1000,
                    ),
                    const SizedBox(height: 16),
                    const Text('各科目進度概覽：'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  '${rod.toY.toInt()}%',
                                  TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final subjects = _progress.keys.toList();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      subjects[value.toInt()],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                          barGroups: _progress.entries.map((entry) {
                            final index = _progress.keys.toList().indexOf(entry.key);
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value,
                                  color: _getSubjectColor(entry.key, colorScheme),
                                  width: 20,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 各科目進度卡片
            ..._progress.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildSubjectCard(context, entry.key, colorScheme),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, String subject, ColorScheme colorScheme) {
    final progress = _progress[subject] ?? 0.0;
    final lastUpdated = _lastUpdated[subject];
    final formattedDate = lastUpdated != null 
        ? '${lastUpdated.year}/${lastUpdated.month}/${lastUpdated.day}'
        : '尚未更新';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        title: Text(
          subject,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text('最後更新: $formattedDate'),
        trailing: Text(
          '${progress.toInt()}%',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: _getSubjectColor(subject, colorScheme),
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 進度條
                LinearPercentIndicator(
                  lineHeight: 20.0,
                  percent: progress / 100,
                  center: Text(
                    '${progress.toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  progressColor: _getSubjectColor(subject, colorScheme),
                  backgroundColor: colorScheme.surfaceVariant,
                  barRadius: const Radius.circular(10),
                  animation: true,
                  animationDuration: 1000,
                ),
                const SizedBox(height: 16),
                // 進度調整滑桿
                Slider(
                  value: progress,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${progress.toInt()}%',
                  onChanged: (value) => _updateProgress(subject, value),
                  activeColor: _getSubjectColor(subject, colorScheme),
                ),
                const SizedBox(height: 16),
                // 學習目標
                TextField(
                  decoration: InputDecoration(
                    labelText: '學習目標',
                    hintText: '設定你的$subject學習目標',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 2,
                  controller: TextEditingController(text: _goals[subject]),
                  onChanged: (value) => _updateGoal(subject, value),
                ),
                const SizedBox(height: 16),
                // 學習筆記
                TextField(
                  decoration: InputDecoration(
                    labelText: '學習筆記',
                    hintText: '記錄你的$subject學習心得',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                  controller: TextEditingController(text: _notes[subject]),
                  onChanged: (value) => _updateNote(subject, value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('使用說明'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. 拖動滑桿調整各科目的學習進度'),
              SizedBox(height: 8),
              Text('2. 點擊科目卡片展開更多選項'),
              SizedBox(height: 8),
              Text('3. 設定學習目標幫助你更有方向'),
              SizedBox(height: 8),
              Text('4. 記錄學習筆記以追蹤你的學習歷程'),
              SizedBox(height: 8),
              Text('5. 總體進度會自動計算所有科目的平均值'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('了解'),
          ),
        ],
      ),
    );
  }

  Color _getSubjectColor(String subject, ColorScheme colorScheme) {
    switch (subject) {
      case '國文': return Colors.red;
      case '英文': return Colors.blue;
      case '數學': return Colors.green;
      case '社會': return Colors.orange;
      case '自然': return Colors.purple;
      default: return colorScheme.primary;
    }
  }
}
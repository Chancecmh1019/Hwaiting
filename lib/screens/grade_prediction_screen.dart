import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GradePredictionScreen extends StatefulWidget {
  const GradePredictionScreen({super.key});

  @override
  State<GradePredictionScreen> createState() => _GradePredictionScreenState();
}

class _GradePredictionScreenState extends State<GradePredictionScreen> {
  final List<String> _subjects = ['國文', '英文', '數學', '社會', '自然'];
  final List<String> _exams = ['第一次模擬考', '第二次模擬考', '第三次模擬考', '第四次模擬考'];
  
  // 成績等級與分數對應表
  final Map<String, double> _gradePoints = {
    'A++': 7.0,
    'A+': 6.0,
    'A': 5.0,
    'B++': 4.0,
    'B+': 3.0,
    'B': 2.0,
    'C': 1.0,
  };
  
  // 作文級分與積分對應表
  final Map<int, double> _writingPoints = {
    6: 1.0,
    5: 0.8,
    4: 0.6,
    3: 0.4,
    2: 0.2,
    1: 0.1,
    0: 0.0,
  };
  
  // 儲存各科成績等級
  final Map<String, Map<String, String>> _grades = {};
  // 儲存作文級分
  final Map<String, int> _writingGrades = {};
  
  int _selectedExamIndex = 0;
  bool _showPrediction = false;

  @override
  void initState() {
    super.initState();
    _initializeGrades();
    _loadGrades();
  }

  void _initializeGrades() {
    for (var exam in _exams) {
      _grades[exam] = {};
      for (var subject in _subjects) {
        _grades[exam]![subject] = 'C';
      }
      _writingGrades[exam] = 0;
    }
  }

  Future<void> _saveGrades() async {
    final prefs = await SharedPreferences.getInstance();
    for (var exam in _exams) {
      for (var subject in _subjects) {
        await prefs.setString('grade_${exam}_$subject', _grades[exam]![subject]!);
      }
      await prefs.setInt('writing_${exam}', _writingGrades[exam]!);
    }
  }

  Future<void> _loadGrades() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var exam in _exams) {
        for (var subject in _subjects) {
          _grades[exam]![subject] = prefs.getString('grade_${exam}_$subject') ?? 'C';
        }
        _writingGrades[exam] = prefs.getInt('writing_${exam}') ?? 0;
      }
    });
  }

  // 計算單次模擬考總分
  double _calculateExamScore(String exam) {
    double total = 0.0;
    
    // 計算五科成績
    for (var subject in _subjects) {
      String grade = _grades[exam]![subject]!;
      total += _gradePoints[grade] ?? 1.0;
    }
    
    // 加上作文分數
    int writingGrade = _writingGrades[exam] ?? 0;
    total += _writingPoints[writingGrade] ?? 0.0;
    
    return total;
  }
  
  // 預測會考成績
  double _predictFinalScore() {
    if (_exams.isEmpty) return 0.0;
    
    // 計算所有模擬考的平均分數
    double totalScore = 0.0;
    int validExams = 0;
    
    for (var exam in _exams) {
      // 檢查是否有任何科目不是預設值
      bool hasValidGrade = false;
      for (var subject in _subjects) {
        if (_grades[exam]![subject] != 'C') {
          hasValidGrade = true;
          break;
        }
      }
      
      if (hasValidGrade || _writingGrades[exam]! > 0) {
        totalScore += _calculateExamScore(exam);
        validExams++;
      }
    }
    
    if (validExams == 0) return 0.0;
    return totalScore / validExams;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('會考成績預測'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: () {
              setState(() {
                _showPrediction = !_showPrediction;
              });
            },
            tooltip: '顯示預測結果',
          ),
        ],
      ),
      body: Column(
        children: [
          // 模擬考選擇器
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _exams.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedExamIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ChoiceChip(
                    label: Text(_exams[index]),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedExamIndex = index);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          
          // 預測結果顯示
          if (_showPrediction)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      '會考預測成績',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_predictFinalScore().toStringAsFixed(1)}分',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '根據您的模擬考成績計算',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          
          // 當次模擬考總分顯示
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '${_exams[_selectedExamIndex]}總分',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_calculateExamScore(_exams[_selectedExamIndex]).toStringAsFixed(1)}分',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 作文級分設定
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '作文級分',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _writingGrades[_exams[_selectedExamIndex]]!.toDouble(),
                          min: 0,
                          max: 6,
                          divisions: 6,
                          label: '${_writingGrades[_exams[_selectedExamIndex]]}級分',
                          onChanged: (value) {
                            setState(() {
                              _writingGrades[_exams[_selectedExamIndex]] = value.toInt();
                            });
                            _saveGrades();
                          },
                        ),
                      ),
                      Text(
                        '${_writingGrades[_exams[_selectedExamIndex]]}級分',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  Text(
                    '積分: ${_writingPoints[_writingGrades[_exams[_selectedExamIndex]]]?.toStringAsFixed(1) ?? '0.0'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          
          // 各科成績輸入
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                final subject = _subjects[index];
                final grade = _grades[_exams[_selectedExamIndex]]![subject]!;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _gradePoints.keys.map((gradeKey) {
                            return ChoiceChip(
                              label: Text(gradeKey),
                              selected: grade == gradeKey,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _grades[_exams[_selectedExamIndex]]![subject] = gradeKey;
                                  });
                                  _saveGrades();
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '積分: ${_gradePoints[grade]?.toStringAsFixed(1) ?? '0.0'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
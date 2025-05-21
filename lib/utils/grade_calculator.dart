class GradeCalculator {
  // 成績等級對應分數
  static const Map<String, double> gradePoints = {
    'A++': 7.0,
    'A+': 6.0,
    'A': 5.0,
    'B++': 4.0,
    'B+': 3.0,
    'B': 2.0,
    'C': 1.0,
  };

  // 作文級分對應分數
  static const Map<int, double> essayPoints = {
    6: 1.0,
    5: 0.8,
    4: 0.6,
    3: 0.4,
    2: 0.2,
    1: 0.1,
    0: 0.0,
  };

  // 計算總分
  static double calculateTotalScore({
    required Map<String, String> subjectGrades,
    required int essayGrade,
  }) {
    double total = 0.0;

    // 計算各科分數
    for (var grade in subjectGrades.values) {
      total += gradePoints[grade] ?? 0.0;
    }

    // 加上作文分數
    total += essayPoints[essayGrade] ?? 0.0;

    return total;
  }

  // 獲取成績等級說明
  static String getGradeDescription(String grade) {
    switch (grade) {
      case 'A++':
        return '精熟';
      case 'A+':
        return '精熟';
      case 'A':
        return '精熟';
      case 'B++':
        return '基礎';
      case 'B+':
        return '基礎';
      case 'B':
        return '基礎';
      case 'C':
        return '待加強';
      default:
        return '未知';
    }
  }

  // 獲取作文級分說明
  static String getEssayGradeDescription(int grade) {
    switch (grade) {
      case 6:
        return '特優';
      case 5:
        return '優等';
      case 4:
        return '良好';
      case 3:
        return '尚可';
      case 2:
        return '待改進';
      case 1:
        return '待改進';
      case 0:
        return '零分';
      default:
        return '未知';
    }
  }
} 
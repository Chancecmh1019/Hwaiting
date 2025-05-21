class GradePrediction {
  static Future<Map<String, double>> calculatePredictions(Map<String, double> scores) async {
    // 簡單的預測邏輯：根據模擬考成績預測會考成績
    // 這裡使用一個簡單的線性轉換，實際應用中可以根據歷史數據調整
    final Map<String, double> predictions = {};
    
    for (var entry in scores.entries) {
      final score = entry.value;
      // 假設會考成績會比模擬考高 5-10 分
      final prediction = score + 5 + (score * 0.05);
      predictions[entry.key] = prediction.clamp(0, 100);
    }
    
    return predictions;
  }
} 
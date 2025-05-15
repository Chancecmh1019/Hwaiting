import 'package:flutter/material.dart';

class ExamCountdownCard extends StatelessWidget {
  final String title;
  final Map<String, int> remainingTime;
  final String statusMessage;
  final VoidCallback? onTap;

  const ExamCountdownCard({
    Key? key,
    required this.title,
    required this.remainingTime,
    required this.statusMessage,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 標題置中顯示
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // 時間單位置中顯示，使用Row確保排成一行
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimeCard(context, '天', remainingTime['days'] ?? 0),
                  const SizedBox(width: 4),
                  _buildTimeCard(context, '小時', remainingTime['hours'] ?? 0),
                  const SizedBox(width: 4),
                  _buildTimeCard(context, '分鐘', remainingTime['minutes'] ?? 0),
                  const SizedBox(width: 4),
                  _buildTimeCard(context, '秒鐘', remainingTime['seconds'] ?? 0),
                ],
              ),
              // 如果有狀態訊息但不為空，才顯示
              if (statusMessage.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  statusMessage,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard(BuildContext context, String unit, int value) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // 縮小容器寬度，使四個卡片能排成一行
    double width = 65.0;
    if (unit == '天') width = 70.0;
    else if (unit == '小時') width = 68.0;
    else if (unit == '分鐘') width = 67.0;
    
    // 調整字體大小
    double valueFontSize = 22.0;
    if (unit == '天') {
      if (value >= 1000) valueFontSize = 18.0;
      else if (value >= 100) valueFontSize = 20.0;
    } else if (value >= 10) {
      valueFontSize = 20.0;
    }
    
    return Container(
      width: width,
      height: 90, // 稍微縮小高度
      margin: const EdgeInsets.symmetric(horizontal: 2), // 減小外邊距
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 數字顯示更大
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // 單位顯示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              unit,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
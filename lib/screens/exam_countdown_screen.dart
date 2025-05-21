import 'package:flutter/material.dart';
import 'dart:async';

class ExamCountdownScreen extends StatefulWidget {
  const ExamCountdownScreen({super.key});

  @override
  State<ExamCountdownScreen> createState() => _ExamCountdownScreenState();
}

class _ExamCountdownScreenState extends State<ExamCountdownScreen> {
  int _selectedYear = DateTime.now().year;
  int _daysLeft = 0;
  int _hoursLeft = 0;
  int _minutesLeft = 0;
  int _secondsLeft = 0;
  Timer? _timer;

  DateTime _calculateExamDate(int year) {
    DateTime date = DateTime(year, 5, 1);
    while (date.weekday != DateTime.saturday) {
      date = date.add(const Duration(days: 1));
    }
    date = date.add(const Duration(days: 14));
    return date;
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final examDate = _calculateExamDate(_selectedYear);
    final difference = examDate.difference(now);

    setState(() {
      _daysLeft = difference.inDays;
      _hoursLeft = difference.inHours.remainder(24);
      _minutesLeft = difference.inMinutes.remainder(60);
      _secondsLeft = difference.inSeconds.remainder(60);
    });
  }

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateCountdown());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('會考倒數'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<int>(
              value: _selectedYear,
              items: List.generate(5, (index) {
                final year = DateTime.now().year + index;
                return DropdownMenuItem(
                  value: year,
                  child: Text('$year年'),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedYear = value);
                  _updateCountdown();
                }
              },
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '距離$_selectedYear年會考還有',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTimeCard(_daysLeft, '天'),
                      _buildTimeCard(_hoursLeft, '時'),
                      _buildTimeCard(_minutesLeft, '分'),
                      _buildTimeCard(_secondsLeft, '秒'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(int value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value.toString().padLeft(2, '0'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
} 
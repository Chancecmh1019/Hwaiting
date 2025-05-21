import 'package:flutter/material.dart';

class MockExam {
  final String id;
  final String title;
  final DateTime examDate;
  final Map<String, int> scores; // 科目 -> 分數
  final Map<String, List<String>> mistakes; // 科目 -> 錯誤題目列表
  final String notes;
  final int totalScore;
  final double averageScore;

  MockExam({
    required this.id,
    required this.title,
    required this.examDate,
    required this.scores,
    this.mistakes = const {},
    this.notes = '',
  }) : totalScore = scores.values.fold(0, (sum, score) => sum + score),
       averageScore = scores.values.isEmpty ? 0 : scores.values.reduce((a, b) => a + b) / scores.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'examDate': examDate.toIso8601String(),
    'scores': scores,
    'mistakes': mistakes,
    'notes': notes,
  };

  factory MockExam.fromJson(Map<String, dynamic> json) => MockExam(
    id: json['id'],
    title: json['title'],
    examDate: DateTime.parse(json['examDate']),
    scores: Map<String, int>.from(json['scores']),
    mistakes: Map<String, List<String>>.from(
      json['mistakes'].map((key, value) => MapEntry(key, List<String>.from(value)))
    ),
    notes: json['notes'],
  );
} 
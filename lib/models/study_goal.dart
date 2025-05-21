import 'package:flutter/material.dart';

class StudyGoal {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime targetDate;
  final int targetHours;
  final int currentHours;
  final bool isCompleted;
  final List<String> subjects;
  final int priority; // 1-5 分

  StudyGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.targetDate,
    required this.targetHours,
    this.currentHours = 0,
    this.isCompleted = false,
    this.subjects = const [],
    this.priority = 3,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'startDate': startDate.toIso8601String(),
    'targetDate': targetDate.toIso8601String(),
    'targetHours': targetHours,
    'currentHours': currentHours,
    'isCompleted': isCompleted,
    'subjects': subjects,
    'priority': priority,
  };

  factory StudyGoal.fromJson(Map<String, dynamic> json) => StudyGoal(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    startDate: DateTime.parse(json['startDate']),
    targetDate: DateTime.parse(json['targetDate']),
    targetHours: json['targetHours'],
    currentHours: json['currentHours'],
    isCompleted: json['isCompleted'],
    subjects: List<String>.from(json['subjects']),
    priority: json['priority'],
  );

  double get progressPercentage => (currentHours / targetHours) * 100;
} 
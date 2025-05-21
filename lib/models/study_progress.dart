import 'package:flutter/material.dart';

class StudyProgress {
  final String id;
  final String subject;
  final String topic;
  final int timeSpent; // 以分鐘為單位
  final DateTime date;
  final String notes;
  final int confidenceLevel; // 1-5 分
  final List<String> tags;

  StudyProgress({
    required this.id,
    required this.subject,
    required this.topic,
    required this.timeSpent,
    required this.date,
    this.notes = '',
    this.confidenceLevel = 3,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'topic': topic,
    'timeSpent': timeSpent,
    'date': date.toIso8601String(),
    'notes': notes,
    'confidenceLevel': confidenceLevel,
    'tags': tags,
  };

  factory StudyProgress.fromJson(Map<String, dynamic> json) => StudyProgress(
    id: json['id'],
    subject: json['subject'],
    topic: json['topic'],
    timeSpent: json['timeSpent'],
    date: DateTime.parse(json['date']),
    notes: json['notes'],
    confidenceLevel: json['confidenceLevel'],
    tags: List<String>.from(json['tags']),
  );
} 
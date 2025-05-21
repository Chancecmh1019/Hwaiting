import 'package:flutter/material.dart';

class StudyNote {
  final String id;
  final String subject;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final int importance; // 1-5 分
  final List<String> relatedTopics;
  final String? imageUrl;

  StudyNote({
    required this.id,
    required this.subject,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.importance = 3,
    this.relatedTopics = const [],
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'tags': tags,
    'importance': importance,
    'relatedTopics': relatedTopics,
    'imageUrl': imageUrl,
  };

  factory StudyNote.fromJson(Map<String, dynamic> json) => StudyNote(
    id: json['id'],
    subject: json['subject'],
    title: json['title'],
    content: json['content'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    tags: List<String>.from(json['tags']),
    importance: json['importance'],
    relatedTopics: List<String>.from(json['relatedTopics']),
    imageUrl: json['imageUrl'],
  );
} 
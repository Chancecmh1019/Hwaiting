import 'package:flutter/material.dart';

class StudyResource {
  final String id;
  final String title;
  final String description;
  final String url;
  final String type; // 影片、文章、題庫等
  final String subject;
  final List<String> tags;
  final double rating;
  final int viewCount;
  final DateTime createdAt;
  final bool isRecommended;
  final String? thumbnailUrl;

  StudyResource({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.type,
    required this.subject,
    this.tags = const [],
    this.rating = 0.0,
    this.viewCount = 0,
    required this.createdAt,
    this.isRecommended = false,
    this.thumbnailUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'url': url,
    'type': type,
    'subject': subject,
    'tags': tags,
    'rating': rating,
    'viewCount': viewCount,
    'createdAt': createdAt.toIso8601String(),
    'isRecommended': isRecommended,
    'thumbnailUrl': thumbnailUrl,
  };

  factory StudyResource.fromJson(Map<String, dynamic> json) => StudyResource(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    url: json['url'],
    type: json['type'],
    subject: json['subject'],
    tags: List<String>.from(json['tags']),
    rating: json['rating'],
    viewCount: json['viewCount'],
    createdAt: DateTime.parse(json['createdAt']),
    isRecommended: json['isRecommended'],
    thumbnailUrl: json['thumbnailUrl'],
  );
} 
import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String id;
  final String title;
  final String body;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Article({
    required this.id,
    required this.title,
    required this.body,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'authorId': authorId,
        'authorName': authorName,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Article.fromMapLocal(Map<String, dynamic> m) {
    return Article(
      id: m['id'] ?? '',
      title: m['title'] ?? '',
      body: m['body'] ?? '',
      authorId: m['authorId'] ?? '',
      authorName: m['authorName'] ?? '',
      createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(m['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  factory Article.fromFirestore(Map<String, dynamic> m, String docId) {
    final created = m['createdAt'] is String
        ? DateTime.tryParse(m['createdAt']) ?? DateTime.now()
        : (m['createdAt']?.toDate?.call() ?? DateTime.now());
    final updated = m['updatedAt'] is String
        ? DateTime.tryParse(m['updatedAt']) ?? created
        : (m['updatedAt']?.toDate?.call() ?? created);
    return Article(
      id: docId,
      title: m['title'] ?? '',
      body: m['body'] ?? '',
      authorId: m['authorId'] ?? '',
      authorName: m['authorName'] ?? '',
      createdAt: created,
      updatedAt: updated,
    );
  }

  Article copyWith({
    String? id,
    String? title,
    String? body,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 🔹 Add fromJson / toJson if using Firestore
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
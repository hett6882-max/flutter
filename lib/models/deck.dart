import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Deck {
  final String id;
  String name;
  String description;
  String category;
  int colorValue;
  DateTime createdAt;

  Deck({
    String? id,
    required this.name,
    this.description = '',
    this.category = 'General',
    this.colorValue = 0xFF3F51B5,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category,
        'colorValue': colorValue,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Deck.fromJson(Map<String, dynamic> json) => Deck(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        category: json['category'] as String? ?? 'General',
        colorValue: json['colorValue'] as int? ?? 0xFF3F51B5,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

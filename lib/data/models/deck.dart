class Deck {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? createdBy;
  final int createdAt;
  final int updatedAt;

  const Deck({
    required this.id,
    required this.title,
    this.description = '',
    this.category = 'General',
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'created_by': createdBy,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  factory Deck.fromMap(Map<String, dynamic> map) => Deck(
        id: map['id'] as String,
        title: map['title'] as String,
        description: (map['description'] ?? '') as String,
        category: (map['category'] ?? 'General') as String,
        createdBy: map['created_by'] as String?,
        createdAt: map['created_at'] as int,
        updatedAt: map['updated_at'] as int,
      );

  Deck copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? createdBy,
    int? createdAt,
    int? updatedAt,
  }) {
    return Deck(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

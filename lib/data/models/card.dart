class FlashCard {
  final String id;
  final String deckId;
  final String front;
  final String back;
  final int createdAt;
  final int updatedAt;

  const FlashCard({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'deck_id': deckId,
        'front': front,
        'back': back,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  factory FlashCard.fromMap(Map<String, dynamic> map) => FlashCard(
        id: map['id'] as String,
        deckId: map['deck_id'] as String,
        front: map['front'] as String,
        back: map['back'] as String,
        createdAt: map['created_at'] as int,
        updatedAt: map['updated_at'] as int,
      );

  FlashCard copyWith({
    String? id,
    String? deckId,
    String? front,
    String? back,
    int? createdAt,
    int? updatedAt,
  }) {
    return FlashCard(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

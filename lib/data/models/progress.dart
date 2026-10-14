class CardProgress {
  final String id;
  final String userId;
  final String cardId;
  final String status; // unseen, known, unknown
  final int reviewCount;
  final int? lastReviewed;

  const CardProgress({
    required this.id,
    required this.userId,
    required this.cardId,
    this.status = 'unseen',
    this.reviewCount = 0,
    this.lastReviewed,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'card_id': cardId,
        'status': status,
        'review_count': reviewCount,
        'last_reviewed': lastReviewed,
      };

  factory CardProgress.fromMap(Map<String, dynamic> map) => CardProgress(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        cardId: map['card_id'] as String,
        status: (map['status'] ?? 'unseen') as String,
        reviewCount: (map['review_count'] ?? 0) as int,
        lastReviewed: map['last_reviewed'] as int?,
      );
}

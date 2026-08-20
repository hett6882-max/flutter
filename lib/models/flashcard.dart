import 'package:uuid/uuid.dart';

class Flashcard {
  final String id;
  String question;
  String answer;
  String deckId;
  List<String> tags;
  bool isFavorite;
  int box; // Leitner box 0-5
  double easeFactor; // SM-2 style
  int repetitions;
  int intervalDays;
  DateTime nextReview;
  DateTime createdAt;
  int timesCorrect;
  int timesWrong;

  Flashcard({
    String? id,
    required this.question,
    required this.answer,
    required this.deckId,
    List<String>? tags,
    this.isFavorite = false,
    this.box = 0,
    this.easeFactor = 2.5,
    this.repetitions = 0,
    this.intervalDays = 0,
    DateTime? nextReview,
    DateTime? createdAt,
    this.timesCorrect = 0,
    this.timesWrong = 0,
  })  : id = id ?? const Uuid().v4(),
        tags = tags ?? [],
        nextReview = nextReview ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  bool get isDue =>
      !nextReview.isAfter(DateTime.now().add(const Duration(seconds: 1)));

  double get mastery {
    final total = timesCorrect + timesWrong;
    if (total == 0) return 0;
    return timesCorrect / total;
  }

  Flashcard copyWith({
    String? question,
    String? answer,
    String? deckId,
    List<String>? tags,
    bool? isFavorite,
    int? box,
    double? easeFactor,
    int? repetitions,
    int? intervalDays,
    DateTime? nextReview,
    int? timesCorrect,
    int? timesWrong,
  }) {
    return Flashcard(
      id: id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      deckId: deckId ?? this.deckId,
      tags: tags ?? List.of(this.tags),
      isFavorite: isFavorite ?? this.isFavorite,
      box: box ?? this.box,
      easeFactor: easeFactor ?? this.easeFactor,
      repetitions: repetitions ?? this.repetitions,
      intervalDays: intervalDays ?? this.intervalDays,
      nextReview: nextReview ?? this.nextReview,
      createdAt: createdAt,
      timesCorrect: timesCorrect ?? this.timesCorrect,
      timesWrong: timesWrong ?? this.timesWrong,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'answer': answer,
        'deckId': deckId,
        'tags': tags,
        'isFavorite': isFavorite,
        'box': box,
        'easeFactor': easeFactor,
        'repetitions': repetitions,
        'intervalDays': intervalDays,
        'nextReview': nextReview.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'timesCorrect': timesCorrect,
        'timesWrong': timesWrong,
      };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
        id: json['id'] as String,
        question: json['question'] as String,
        answer: json['answer'] as String,
        deckId: json['deckId'] as String,
        tags: (json['tags'] as List?)?.cast<String>() ?? [],
        isFavorite: json['isFavorite'] as bool? ?? false,
        box: json['box'] as int? ?? 0,
        easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
        repetitions: json['repetitions'] as int? ?? 0,
        intervalDays: json['intervalDays'] as int? ?? 0,
        nextReview: DateTime.tryParse(json['nextReview'] as String? ?? '') ??
            DateTime.now(),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        timesCorrect: json['timesCorrect'] as int? ?? 0,
        timesWrong: json['timesWrong'] as int? ?? 0,
      );
}

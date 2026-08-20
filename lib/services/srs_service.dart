import '../models/flashcard.dart';

/// Review quality: 0 Again, 1 Hard, 2 Good, 3 Easy (SM-2 inspired + Leitner box).
enum ReviewQuality { again, hard, good, easy }

class SrsService {
  static Flashcard applyReview(Flashcard card, ReviewQuality quality) {
    var ease = card.easeFactor;
    var reps = card.repetitions;
    var interval = card.intervalDays;
    var box = card.box;
    var correct = card.timesCorrect;
    var wrong = card.timesWrong;

    switch (quality) {
      case ReviewQuality.again:
        reps = 0;
        interval = 0;
        box = 0;
        ease = (ease - 0.2).clamp(1.3, 3.0);
        wrong++;
        break;
      case ReviewQuality.hard:
        if (reps == 0) {
          interval = 1;
        } else {
          interval = (interval * 1.2).round().clamp(1, 3650);
        }
        reps++;
        box = (box + 1).clamp(0, 5);
        ease = (ease - 0.15).clamp(1.3, 3.0);
        correct++;
        break;
      case ReviewQuality.good:
        if (reps == 0) {
          interval = 1;
        } else if (reps == 1) {
          interval = 3;
        } else {
          interval = (interval * ease).round().clamp(1, 3650);
        }
        reps++;
        box = (box + 1).clamp(0, 5);
        correct++;
        break;
      case ReviewQuality.easy:
        if (reps == 0) {
          interval = 3;
        } else if (reps == 1) {
          interval = 7;
        } else {
          interval = (interval * ease * 1.3).round().clamp(1, 3650);
        }
        reps++;
        box = (box + 2).clamp(0, 5);
        ease = (ease + 0.15).clamp(1.3, 3.0);
        correct++;
        break;
    }

    final next = DateTime.now().add(Duration(days: interval == 0 ? 0 : interval));
    // Again => review again soon (10 minutes)
    final nextReview = quality == ReviewQuality.again
        ? DateTime.now().add(const Duration(minutes: 10))
        : next;

    return card.copyWith(
      easeFactor: ease,
      repetitions: reps,
      intervalDays: interval,
      box: box,
      nextReview: nextReview,
      timesCorrect: correct,
      timesWrong: wrong,
    );
  }
}

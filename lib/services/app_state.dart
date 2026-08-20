import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import 'srs_service.dart';
import 'storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Deck> decks = [];
  List<Flashcard> cards = [];
  ThemeMode themeMode = ThemeMode.system;
  int streak = 0;
  int dailyGoal = 20;
  int studiedToday = 0;
  bool isLoaded = false;

  Future<void> load() async {
    decks = await _storage.loadDecks();
    cards = await _storage.loadCards();
    final theme = await _storage.loadThemeMode();
    themeMode = switch (theme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    streak = await _storage.loadStreak();
    dailyGoal = await _storage.loadDailyGoal();
    studiedToday = await _storage.loadStudiedToday();
    await _refreshStreakOnLoad();

    if (decks.isEmpty) {
      await _seedSampleData();
    }
    isLoaded = true;
    notifyListeners();
  }

  Future<void> _refreshStreakOnLoad() async {
    final last = await _storage.loadLastStudyDate();
    if (last == null) return;
    final lastDate = DateTime.tryParse(last);
    if (lastDate == null) return;
    final today = DateTime.now();
    final diff = DateTime(today.year, today.month, today.day)
        .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
        .inDays;
    if (diff > 1) {
      streak = 0;
      await _storage.saveStreak(streak);
    }
  }

  Future<void> _seedSampleData() async {
    final flutter = Deck(
      name: 'Flutter Basics',
      description: 'Core Flutter & Dart concepts',
      category: 'Programming',
      colorValue: 0xFF3F51B5,
    );
    final vocab = Deck(
      name: 'English Vocab',
      description: 'Useful English words',
      category: 'Language',
      colorValue: 0xFF00897B,
    );
    final science = Deck(
      name: 'Science Facts',
      description: 'Quick science revision',
      category: 'School',
      colorValue: 0xFFE65100,
    );

    decks = [flutter, vocab, science];
    cards = [
      Flashcard(
        question: 'What is Flutter?',
        answer: 'A UI toolkit by Google for building natively compiled apps.',
        deckId: flutter.id,
        tags: ['basics', 'flutter'],
      ),
      Flashcard(
        question: 'What is a Widget?',
        answer: 'The basic building block of a Flutter UI.',
        deckId: flutter.id,
        tags: ['basics', 'ui'],
      ),
      Flashcard(
        question: 'What does StatelessWidget mean?',
        answer: 'A widget that does not store mutable state.',
        deckId: flutter.id,
        tags: ['widgets'],
      ),
      Flashcard(
        question: 'What is Hot Reload?',
        answer: 'Updating the UI instantly without losing app state.',
        deckId: flutter.id,
        tags: ['devtools'],
      ),
      Flashcard(
        question: 'Eloquent',
        answer: 'Fluent or persuasive in speaking or writing.',
        deckId: vocab.id,
        tags: ['adjective'],
      ),
      Flashcard(
        question: 'Resilient',
        answer: 'Able to recover quickly from difficulties.',
        deckId: vocab.id,
        tags: ['adjective'],
      ),
      Flashcard(
        question: 'Photosynthesis',
        answer: 'Process by which plants convert light into chemical energy.',
        deckId: science.id,
        tags: ['biology'],
      ),
      Flashcard(
        question: 'Gravity',
        answer: 'The force that attracts objects toward each other.',
        deckId: science.id,
        tags: ['physics'],
      ),
    ];
    await _persistAll();
  }

  Future<void> _persistAll() async {
    await _storage.saveDecks(decks);
    await _storage.saveCards(cards);
  }

  List<Flashcard> cardsForDeck(String deckId) =>
      cards.where((c) => c.deckId == deckId).toList();

  List<Flashcard> get dueCards => cards.where((c) => c.isDue).toList();

  List<Flashcard> get favorites => cards.where((c) => c.isFavorite).toList();

  int dueCountForDeck(String deckId) =>
      cards.where((c) => c.deckId == deckId && c.isDue).length;

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _storage.saveThemeMode(value);
    notifyListeners();
  }

  Future<void> setDailyGoal(int goal) async {
    dailyGoal = goal.clamp(5, 200);
    await _storage.saveDailyGoal(dailyGoal);
    notifyListeners();
  }

  Future<void> addDeck(Deck deck) async {
    decks = [...decks, deck];
    await _storage.saveDecks(decks);
    notifyListeners();
  }

  Future<void> updateDeck(Deck deck) async {
    decks = [for (final d in decks) d.id == deck.id ? deck : d];
    await _storage.saveDecks(decks);
    notifyListeners();
  }

  Future<void> deleteDeck(String deckId) async {
    decks = decks.where((d) => d.id != deckId).toList();
    cards = cards.where((c) => c.deckId != deckId).toList();
    await _persistAll();
    notifyListeners();
  }

  Future<void> addCard(Flashcard card) async {
    cards = [...cards, card];
    await _storage.saveCards(cards);
    notifyListeners();
  }

  Future<void> updateCard(Flashcard card) async {
    cards = [for (final c in cards) c.id == card.id ? card : c];
    await _storage.saveCards(cards);
    notifyListeners();
  }

  Future<void> deleteCard(String cardId) async {
    cards = cards.where((c) => c.id != cardId).toList();
    await _storage.saveCards(cards);
    notifyListeners();
  }

  Future<void> toggleFavorite(String cardId) async {
    cards = [
      for (final c in cards)
        c.id == cardId ? c.copyWith(isFavorite: !c.isFavorite) : c,
    ];
    await _storage.saveCards(cards);
    notifyListeners();
  }

  Future<void> applyReview(String cardId, ReviewQuality quality) async {
    cards = [
      for (final c in cards)
        c.id == cardId ? SrsService.applyReview(c, quality) : c,
    ];
    studiedToday++;
    await _storage.saveCards(cards);
    await _storage.saveStudiedToday(studiedToday);
    await _updateStreak();
    notifyListeners();
  }

  Future<void> _updateStreak() async {
    final today = DateTime.now();
    final todayStr =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final last = await _storage.loadLastStudyDate();
    if (last == todayStr) {
      // already counted today
    } else if (last != null) {
      final lastDate = DateTime.tryParse(last);
      if (lastDate != null) {
        final diff = DateTime(today.year, today.month, today.day)
            .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
            .inDays;
        streak = diff == 1 ? streak + 1 : 1;
      } else {
        streak = 1;
      }
    } else {
      streak = 1;
    }
    await _storage.saveLastStudyDate(todayStr);
    await _storage.saveStreak(streak);
  }

  List<Flashcard> search(String query, {String? deckId, String? tag}) {
    final q = query.trim().toLowerCase();
    return cards.where((c) {
      if (deckId != null && c.deckId != deckId) return false;
      if (tag != null && !c.tags.contains(tag)) return false;
      if (q.isEmpty) return true;
      return c.question.toLowerCase().contains(q) ||
          c.answer.toLowerCase().contains(q) ||
          c.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  double overallMastery() {
    if (cards.isEmpty) return 0;
    final sum = cards.fold<double>(0, (a, c) => a + c.mastery);
    return sum / cards.length;
  }
}

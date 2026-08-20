import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';

class StorageService {
  static const _decksKey = 'fm_decks';
  static const _cardsKey = 'fm_cards';
  static const _themeKey = 'fm_theme';
  static const _streakKey = 'fm_streak';
  static const _lastStudyKey = 'fm_last_study';
  static const _dailyGoalKey = 'fm_daily_goal';
  static const _studiedTodayKey = 'fm_studied_today';
  static const _studiedDateKey = 'fm_studied_date';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<Deck>> loadDecks() async {
    final raw = (await _prefs).getString(_decksKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => Deck.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> saveDecks(List<Deck> decks) async {
    final raw = jsonEncode(decks.map((d) => d.toJson()).toList());
    await (await _prefs).setString(_decksKey, raw);
  }

  Future<List<Flashcard>> loadCards() async {
    final raw = (await _prefs).getString(_cardsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => Flashcard.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> saveCards(List<Flashcard> cards) async {
    final raw = jsonEncode(cards.map((c) => c.toJson()).toList());
    await (await _prefs).setString(_cardsKey, raw);
  }

  Future<String> loadThemeMode() async =>
      (await _prefs).getString(_themeKey) ?? 'system';

  Future<void> saveThemeMode(String mode) async =>
      (await _prefs).setString(_themeKey, mode);

  Future<int> loadStreak() async => (await _prefs).getInt(_streakKey) ?? 0;

  Future<void> saveStreak(int streak) async =>
      (await _prefs).setInt(_streakKey, streak);

  Future<String?> loadLastStudyDate() async =>
      (await _prefs).getString(_lastStudyKey);

  Future<void> saveLastStudyDate(String isoDate) async =>
      (await _prefs).setString(_lastStudyKey, isoDate);

  Future<int> loadDailyGoal() async =>
      (await _prefs).getInt(_dailyGoalKey) ?? 20;

  Future<void> saveDailyGoal(int goal) async =>
      (await _prefs).setInt(_dailyGoalKey, goal);

  Future<int> loadStudiedToday() async {
    final prefs = await _prefs;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final stored = prefs.getString(_studiedDateKey);
    if (stored != today) return 0;
    return prefs.getInt(_studiedTodayKey) ?? 0;
  }

  Future<void> saveStudiedToday(int count) async {
    final prefs = await _prefs;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(_studiedDateKey, today);
    await prefs.setInt(_studiedTodayKey, count);
  }
}

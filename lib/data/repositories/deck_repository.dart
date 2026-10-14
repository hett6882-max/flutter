import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../database/database_helper.dart';
import '../models/deck.dart';

class DeckRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final _uuid = const Uuid();

  Future<Database> get _db async => _dbHelper.database;

  Future<List<Deck>> getAll({String? query}) async {
    final db = await _db;
    if (query != null && query.trim().isNotEmpty) {
      final q = '%${query.trim()}%';
      final rows = await db.query('decks',
          where: 'title LIKE ? OR description LIKE ? OR category LIKE ?',
          whereArgs: [q, q, q],
          orderBy: 'updated_at DESC');
      return rows.map(Deck.fromMap).toList();
    }
    final rows = await db.query('decks', orderBy: 'updated_at DESC');
    return rows.map(Deck.fromMap).toList();
  }

  Future<Deck?> getById(String id) async {
    final db = await _db;
    final rows =
        await db.query('decks', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Deck.fromMap(rows.first);
  }

  Future<Deck> create({
    required String title,
    String description = '',
    String category = 'General',
    String? createdBy,
  }) async {
    final db = await _db;
    final now = DateTime.now().millisecondsSinceEpoch;
    final deck = Deck(
      id: _uuid.v4(),
      title: title.trim(),
      description: description.trim(),
      category: category.trim().isEmpty ? 'General' : category.trim(),
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );
    await db.insert('decks', deck.toMap());
    return deck;
  }

  Future<Deck> update(Deck deck) async {
    final db = await _db;
    final updated = deck.copyWith(updatedAt: DateTime.now().millisecondsSinceEpoch);
    await db.update('decks', updated.toMap(),
        where: 'id = ?', whereArgs: [updated.id]);
    return updated;
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('decks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> count() async {
    final db = await _db;
    final r = await db.rawQuery('SELECT COUNT(*) as c FROM decks');
    return (r.first['c'] as int?) ?? 0;
  }
}

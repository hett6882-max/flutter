import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../database/database_helper.dart';
import '../models/card.dart' as m;

class CardRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final _uuid = const Uuid();

  Future<Database> get _db async => _dbHelper.database;

  Future<List<m.FlashCard>> getByDeck(String deckId) async {
    final db = await _db;
    final rows = await db.query('cards',
        where: 'deck_id = ?', whereArgs: [deckId], orderBy: 'created_at ASC');
    return rows.map(m.FlashCard.fromMap).toList();
  }

  Future<m.FlashCard?> getById(String id) async {
    final db = await _db;
    final rows =
        await db.query('cards', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return m.FlashCard.fromMap(rows.first);
  }

  Future<m.FlashCard> create({
    required String deckId,
    required String front,
    required String back,
  }) async {
    final db = await _db;
    final now = DateTime.now().millisecondsSinceEpoch;
    final card = m.FlashCard(
      id: _uuid.v4(),
      deckId: deckId,
      front: front.trim(),
      back: back.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await db.insert('cards', card.toMap());
    return card;
  }

  Future<m.FlashCard> update(m.FlashCard card) async {
    final db = await _db;
    final updated =
        card.copyWith(updatedAt: DateTime.now().millisecondsSinceEpoch);
    await db.update('cards', updated.toMap(),
        where: 'id = ?', whereArgs: [updated.id]);
    return updated;
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countByDeck(String deckId) async {
    final db = await _db;
    final r = await db.rawQuery(
        'SELECT COUNT(*) as c FROM cards WHERE deck_id = ?', [deckId]);
    return (r.first['c'] as int?) ?? 0;
  }

  Future<int> count() async {
    final db = await _db;
    final r = await db.rawQuery('SELECT COUNT(*) as c FROM cards');
    return (r.first['c'] as int?) ?? 0;
  }
}

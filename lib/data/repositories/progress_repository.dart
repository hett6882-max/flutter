import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants.dart';
import '../database/database_helper.dart';


class ProgressRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final _uuid = const Uuid();

  Future<Database> get _db async => _dbHelper.database;

  Future<void> setStatus({
    required String userId,
    required String cardId,
    required String status,
  }) async {
    final db = await _db;
    final existing = await db.query('card_progress',
        where: 'user_id = ? AND card_id = ?',
        whereArgs: [userId, cardId],
        limit: 1);
    final now = DateTime.now().millisecondsSinceEpoch;
    if (existing.isEmpty) {
      await db.insert('card_progress', {
        'id': _uuid.v4(),
        'user_id': userId,
        'card_id': cardId,
        'status': status,
        'review_count': 1,
        'last_reviewed': now,
      });
    } else {
      final row = existing.first;
      await db.update(
        'card_progress',
        {
          'status': status,
          'review_count': ((row['review_count'] as int?) ?? 0) + 1,
          'last_reviewed': now,
        },
        where: 'user_id = ? AND card_id = ?',
        whereArgs: [userId, cardId],
      );
    }
  }

  Future<Map<String, String>> statusByCardForUser(
      String userId, List<String> cardIds) async {
    if (cardIds.isEmpty) return {};
    final db = await _db;
    final placeholders = List.filled(cardIds.length, '?').join(',');
    final rows = await db.query(
      'card_progress',
      where: 'user_id = ? AND card_id IN ($placeholders)',
      whereArgs: [userId, ...cardIds],
    );
    final map = <String, String>{};
    for (final r in rows) {
      map[r['card_id'] as String] = r['status'] as String;
    }
    return map;
  }

  Future<Map<String, int>> deckProgress(String userId, String deckId) async {
    final db = await _db;
    // total cards in deck
    final totalRes = await db.rawQuery(
        'SELECT COUNT(*) as c FROM cards WHERE deck_id = ?', [deckId]);
    final total = (totalRes.first['c'] as int?) ?? 0;
    final knownRes = await db.rawQuery(
        '''SELECT COUNT(*) as c FROM card_progress cp
           JOIN cards c ON c.id = cp.card_id
           WHERE cp.user_id = ? AND c.deck_id = ? AND cp.status = ?''',
        [userId, deckId, AppConstants.statusKnown]);
    final known = (knownRes.first['c'] as int?) ?? 0;
    final reviewedRes = await db.rawQuery(
        '''SELECT COUNT(*) as c FROM card_progress cp
           JOIN cards c ON c.id = cp.card_id
           WHERE cp.user_id = ? AND c.deck_id = ?''',
        [userId, deckId]);
    final reviewed = (reviewedRes.first['c'] as int?) ?? 0;
    return {'total': total, 'known': known, 'reviewed': reviewed};
  }

  Future<Map<String, int>> userOverall(String userId) async {
    final db = await _db;
    final totalRes =
        await db.rawQuery('SELECT COUNT(*) as c FROM cards');
    final total = (totalRes.first['c'] as int?) ?? 0;
    final knownRes = await db.rawQuery(
        'SELECT COUNT(*) as c FROM card_progress WHERE user_id = ? AND status = ?',
        [userId, AppConstants.statusKnown]);
    final known = (knownRes.first['c'] as int?) ?? 0;
    final reviewedRes = await db.rawQuery(
        'SELECT COUNT(*) as c FROM card_progress WHERE user_id = ?',
        [userId]);
    final reviewed = (reviewedRes.first['c'] as int?) ?? 0;
    return {'total': total, 'known': known, 'reviewed': reviewed};
  }

  Future<void> resetForUser(String userId) async {
    final db = await _db;
    await db.delete('card_progress', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> globalStudiedCount() async {
    final db = await _db;
    final r = await db.rawQuery('SELECT COUNT(*) as c FROM card_progress');
    return (r.first['c'] as int?) ?? 0;
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../database/database_helper.dart';
import '../models/user.dart';

class AuthRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final _uuid = const Uuid();

  Future<Database> get _db async => _dbHelper.database;

  Future<User?> findByUsername(String username) async {
    final db = await _db;
    final rows = await db.query('users',
        where: 'username = ?', whereArgs: [username.trim()], limit: 1);
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  Future<User?> findById(String id) async {
    final db = await _db;
    final rows =
        await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  Future<User> createUser({
    required String username,
    required String password,
    required String role,
  }) async {
    final db = await _db;
    final user = User(
      id: _uuid.v4(),
      username: username.trim(),
      passwordHash: _dbHelper.hashPassword(password),
      role: role,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await db.insert('users', user.toMap());
    return user;
  }

  Future<bool> verifyPassword(User user, String password) async {
    return user.passwordHash == _dbHelper.hashPassword(password);
  }

  Future<List<User>> listUsers() async {
    final db = await _db;
    final rows = await db.query('users', orderBy: 'created_at ASC');
    return rows.map(User.fromMap).toList();
  }

  Future<int> countUsers() async {
    final db = await _db;
    final r = await db.rawQuery('SELECT COUNT(*) as c FROM users');
    return (r.first['c'] as int?) ?? 0;
  }

  Future<void> deleteUser(String id) async {
    final db = await _db;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}

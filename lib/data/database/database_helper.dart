import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/constants.dart';


class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'flashmaster.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final docsDir = await getDatabasesPath();
    final path = join(docsDir, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE decks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT,
        created_by TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY(created_by) REFERENCES users(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE cards (
        id TEXT PRIMARY KEY,
        deck_id TEXT NOT NULL,
        front TEXT NOT NULL,
        back TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY(deck_id) REFERENCES decks(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE card_progress (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        card_id TEXT NOT NULL,
        status TEXT NOT NULL,
        review_count INTEGER NOT NULL DEFAULT 0,
        last_reviewed INTEGER,
        UNIQUE(user_id, card_id),
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(card_id) REFERENCES cards(id) ON DELETE CASCADE
      )
    ''');

    await _seed(db);
  }

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<void> _seed(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final adminId = 'admin-001';
    final userId = 'user-001';
    await db.insert('users', {
      'id': adminId,
      'username': AppConstants.defaultAdminUsername,
      'password_hash': hashPassword(AppConstants.defaultAdminPassword),
      'role': AppConstants.roleAdmin,
      'created_at': now,
    });
    await db.insert('users', {
      'id': userId,
      'username': AppConstants.defaultUserUsername,
      'password_hash': hashPassword(AppConstants.defaultUserPassword),
      'role': AppConstants.roleUser,
      'created_at': now,
    });

    // Sample decks/cards
    final deck1 = 'deck-001';
    final deck2 = 'deck-002';
    await db.insert('decks', {
      'id': deck1,
      'title': 'English Vocabulary',
      'description': 'Common English words and meanings',
      'category': 'Language',
      'created_by': adminId,
      'created_at': now,
      'updated_at': now,
    });
    await db.insert('decks', {
      'id': deck2,
      'title': 'Capital Cities',
      'description': 'Match countries to their capitals',
      'category': 'Geography',
      'created_by': adminId,
      'created_at': now,
      'updated_at': now,
    });

    final cards1 = [
      ('Hello', 'A greeting; used when meeting someone'),
      ('Goodbye', 'A farewell; used when leaving'),
      ('Thank you', 'Expression of gratitude'),
    ];
    for (var i = 0; i < cards1.length; i++) {
      final c = cards1[i];
      await db.insert('cards', {
        'id': 'card-00${i + 1}',
        'deck_id': deck1,
        'front': c.$1,
        'back': c.$2,
        'created_at': now,
        'updated_at': now,
      });
    }
    final cards2 = [
      ('France', 'Paris'),
      ('Japan', 'Tokyo'),
      ('India', 'New Delhi'),
    ];
    for (var i = 0; i < cards2.length; i++) {
      final c = cards2[i];
      await db.insert('cards', {
        'id': 'card-01${i + 1}',
        'deck_id': deck2,
        'front': c.$1,
        'back': c.$2,
        'created_at': now,
        'updated_at': now,
      });
    }
  }
}

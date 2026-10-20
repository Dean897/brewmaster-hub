import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  DbHelper._internal();

  static final DbHelper instance = DbHelper._internal();
  static const String _databaseName = 'kopi_quiz.db';
  static const String _tableName = 'questions';

  Database? _database;

  static const List<Map<String, dynamic>> _dummyQuestions = [
    {
      'question': 'Apa bahan utama dalam minuman espresso?',
      'option_a': 'Daun teh',
      'option_b': 'Biji kopi',
      'option_c': 'Cokelat',
      'option_d': 'Susu',
      'correct_answer': 'B',
    },
    {
      'question': 'Metode seduh yang menggunakan kertas filter berbentuk kerucut adalah?',
      'option_a': 'French Press',
      'option_b': 'Moka Pot',
      'option_c': 'V60',
      'option_d': 'Espresso',
      'correct_answer': 'C',
    },
    {
      'question': 'Apa rasa yang biasanya muncul dari kopi dengan tingkat sangrai gelap?',
      'option_a': 'Rasa gosong dan pahit',
      'option_b': 'Rasa sangat asam',
      'option_c': 'Rasa seperti teh',
      'option_d': 'Rasa asin',
      'correct_answer': 'A',
    },
  ];

  Future<List<Map<String, dynamic>>> getQuestions() async {
    if (kIsWeb) {
      return List<Map<String, dynamic>>.from(_dummyQuestions);
    }

    final db = await _getDatabase();
    final questions = await db.query(_tableName);

    if (questions.isEmpty) {
      await db.transaction((transaction) async {
        for (final question in _dummyQuestions) {
          await transaction.insert(_tableName, question);
        }
      });
      return db.query(_tableName);
    }

    return questions;
  }

  Future<Database> _getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    final databasePath = join(await getDatabasesPath(), _databaseName);
    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            question TEXT NOT NULL,
            option_a TEXT NOT NULL,
            option_b TEXT NOT NULL,
            option_c TEXT NOT NULL,
            option_d TEXT NOT NULL,
            correct_answer TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }
}

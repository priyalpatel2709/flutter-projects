// database_helper.dart

import 'dart:async';
import 'dart:developer';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }
  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'quiz_database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    print('i am V3');

    await db.execute(
      "CREATE TABLE questions(id INTEGER PRIMARY KEY, question TEXT, option1 TEXT, option2 TEXT, option3 TEXT, option4 TEXT, correctAnswer TEXT)",
    );

    // Insert sample questions during initialization
    await _insertSampleQuestions(db);
  }

  Future<void> _insertSampleQuestions(Database db) async {
    print('i am-------->');
    await db.insert('questions', {
      'question': 'Who is the Prime Minister of India?',
      'option1': 'Narendra Modi',
      'option2': 'Rahul Gandhi',
      'option3': 'Manmohan Singh',
      'option4': 'Amit Shah',
      'correctAnswer': 'Narendra Modi',
    });

    await db.insert('questions', {
      'question': 'What is the capital of India?',
      'option1': 'Mumbai',
      'option2': 'Chennai',
      'option3': 'Delhi',
      'option4': 'Ahmedabad',
      'correctAnswer': 'Delhi',
    });

    // Add more questions as needed
  }

  Future<void> insertQuestion(Map<String, dynamic> question) async {
    Database? db = await database;
    await db?.insert('questions', question);
  }

  Future<List<Map<String, dynamic>>?> getQuestions() async {
    Database? db = await database;
    return await db?.query('questions');
  }
}

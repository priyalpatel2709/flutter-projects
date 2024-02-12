import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
    await db.execute(
      "CREATE TABLE questions(id INTEGER PRIMARY KEY, question TEXT, option1 TEXT, option2 TEXT, option3 TEXT, option4 TEXT, correctAnswer TEXT)",
    );

    // Insert sample questions during initialization
    await _insertSampleQuestions(db);
  }

  Future<void> _insertSampleQuestions(Database db) async {
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

    await db.insert('questions', {
      'question': 'What is sum of 15 + 25?',
      'option1': '5',
      'option2': '25',
      'option3': '40',
      'option4': 'None',
      'correctAnswer': '40',
    });

    await db.insert('questions', {
      'question': 'Which one is maximum? 25, 11, 17, 18, 40, 42',
      'option1': '11',
      'option2': '42',
      'option3': '17',
      'option4': 'None',
      'correctAnswer': '42',
    });

    await db.insert('questions', {
      'question': 'What is the official language of Gujarat?',
      'option1': 'Hindi',
      'option2': 'Gujarati',
      'option3': 'Marathi',
      'option4': 'None',
      'correctAnswer': 'Gujarati',
    });

    await db.insert('questions', {
      'question': 'What is multiplication of 12 * 12?',
      'option1': '124',
      'option2': '12',
      'option3': '24',
      'option4': 'None',
      'correctAnswer': '144',
    });

    await db.insert('questions', {
      'question': 'Which state of India has the largest population?',
      'option1': 'UP',
      'option2': 'Bihar',
      'option3': 'Gujarat',
      'option4': 'Maharashtra',
      'correctAnswer': 'UP',
    });

    await db.insert('questions', {
      'question': 'Who is the Home Minister of India?',
      'option1': 'Amit Shah',
      'option2': 'Rajnath Singh',
      'option3': 'Narendra Modi',
      'option4': 'None',
      'correctAnswer': 'Amit Shah',
    });

    await db.insert('questions', {
      'question': 'What is the capital of Gujarat?',
      'option1': 'Vadodara',
      'option2': 'Ahmedabad',
      'option3': 'Gandhinagar',
      'option4': 'Rajkot',
      'correctAnswer': 'Gandhinagar',
    });

    await db.insert('questions', {
      'question': 'Which number will be next in series? 1, 4, 9, 16, 25',
      'option1': '21',
      'option2': '36',
      'option3': '49',
      'option4': '32',
      'correctAnswer': '36',
    });

    await db.insert('questions', {
      'question': 'Which one is minimum? 5, 0, -20, 11',
      'option1': '0',
      'option2': '11',
      'option3': '-20',
      'option4': 'None',
      'correctAnswer': '-20',
    });

    await db.insert('questions', {
      'question': 'What is sum of 10, 12 and 15?',
      'option1': '37',
      'option2': '25',
      'option3': '10',
      'option4': '12',
      'correctAnswer': '37',
    });

    await db.insert('questions', {
      'question': 'What is the official language of the Government of India?',
      'option1': 'Hindi',
      'option2': 'English',
      'option3': 'Gujarati',
      'option4': 'None',
      'correctAnswer': 'Hindi',
    });

    await db.insert('questions', {
      'question': 'Which country is located in Asia?',
      'option1': 'India',
      'option2': 'USA',
      'option3': 'UK',
      'option4': 'None',
      'correctAnswer': 'India',
    });

    await db.insert('questions', {
      'question': 'Which language(s) is/are used for Android app development?',
      'option1': 'Java',
      'option2': 'Java & Kotlin',
      'option3': 'Kotlin',
      'option4': 'Swift',
      'correctAnswer': 'Java & Kotlin',
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

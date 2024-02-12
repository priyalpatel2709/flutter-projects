import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  DatabaseHelper databaseHelper = DatabaseHelper();
  await databaseHelper.initDatabase();

  runApp(MyApp());
}

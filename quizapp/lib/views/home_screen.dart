import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import '../viewmodels/app_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppViewModel.primaryColor,
        title: const Text('Quiz App'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizScreen(),
              ),
            );
          },
          child: const Text('Play Game'),
        ),
      ),
    );
  }
}

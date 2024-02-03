// views/result_screen.dart

import 'package:flutter/material.dart';

import '../viewmodels/app_viewmodel.dart';
import 'home_screen.dart';
// import 'package:your_project_name/views/home_screen.dart';
// import 'package:your_project_name/viewmodels/app_viewmodel.dart';

class ResultScreen extends StatelessWidget {
  final int totalScore;
  final int correctAnswers;

  ResultScreen({required this.totalScore, required this.correctAnswers});

  String _getResultMessage() {
    if (correctAnswers == 10) {
      return 'Awesome. You are Genius. Congratulations you won the Game.';
    } else if (correctAnswers >= 9) {
      return 'You Won! Congratulations and Well Done.';
    } else if (correctAnswers >= 7) {
      return 'You Won! Congratulations.';
    } else if (correctAnswers >= 5) {
      return 'You Won!';
    } else if (correctAnswers >= 3) {
      return 'Well played but you failed. All The Best for Next Game.';
    } else {
      return 'Sorry, You failed.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Total Score: $totalScore',
            style: TextStyle(fontSize: 20, color: AppViewModel.primaryColor),
          ),
          const SizedBox(height: 20),
          Text(
            _getResultMessage(),
            style: TextStyle(fontSize: 18, color: AppViewModel.primaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              primary: AppViewModel.accentColor,
            ),
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }
}

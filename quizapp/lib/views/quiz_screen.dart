// views/quiz_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';

import '../models/question.dart';
import '../viewmodels/app_viewmodel.dart';
import '../viewmodels/quiz_viewmodel.dart';
import 'result_screen.dart';
// import 'package:your_project_name/models/question.dart';
// import 'package:your_project_name/viewmodels/quiz_viewmodel.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizViewModel _viewModel = QuizViewModel();
  int currentQuestionIndex = 0;
  int totalScore = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    await _viewModel.fetchQuestions();
    setState(() {});
  }

  void _handleAnswer(String selectedOption) {
    // Add logic to handle user's answer and calculate score
    Question currentQuestion = _viewModel.questions[currentQuestionIndex];

    if (selectedOption == currentQuestion.correctAnswer) {
      // Correct Answer
      int score = 10 + (20 - _secondsLeft);
      totalScore += score;
      _showSnackBar('Correct! Score: $score');
    } else {
      // Wrong Answer
      _showSnackBar('Wrong Answer! Score: 0');
    }

    _nextQuestion();
  }

  void _nextQuestion() {
    if (currentQuestionIndex < _viewModel.questions.length - 1) {
      // Move to the next question
      currentQuestionIndex++;
      _resetTimer();
    } else {
      // End of quiz, navigate to the result screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            totalScore: totalScore,
            correctAnswers: _correctAnswersCount(),
          ),
        ),
      );
    }
  }

  int _correctAnswersCount() {
    int count = 0;
    // for (Question question in _viewModel.questions) {
    //   if (question.isCorrect) {
    //     count++;
    //   }
    // }
    return 5;
  }

  // Add timer related logic
  int _secondsLeft = 20;
  late Timer _timer;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          // Time is up, move to the next question
          _nextQuestion();
        }
      });
    });
  }

  void _resetTimer() {
    _timer.cancel();
    _secondsLeft = 20;
    _startTimer();
  }

  // Add UI code here

  @override
  Widget build(BuildContext context) {
    if (_viewModel.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppViewModel.primaryColor,
          title: const Text('Quiz Game'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    Question currentQuestion = _viewModel.questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Game'),
        actions: [
          Text('Timer: $_secondsLeft s',
              style: TextStyle(color: AppViewModel.primaryColor)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Question ${currentQuestionIndex + 1}/${_viewModel.questions.length}'),
            Text(
              currentQuestion.question,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            _buildOptionButton(currentQuestion.option1),
            _buildOptionButton(currentQuestion.option2),
            _buildOptionButton(currentQuestion.option3),
            _buildOptionButton(currentQuestion.option4),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          _handleAnswer(option);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppViewModel.accentColor,
        ),
        child: Text(option),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

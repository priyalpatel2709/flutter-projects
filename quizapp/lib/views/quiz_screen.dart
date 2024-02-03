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
  int correctAnswer = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
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
      correctAnswer++;
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
            correctAnswers: correctAnswer,
          ),
        ),
      );
    }
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
        backgroundColor: AppViewModel.primaryColor,
        actions: [
          Text(
            'Timer: $_secondsLeft s',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: 500,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${currentQuestionIndex + 1}/${_viewModel.questions.length}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                currentQuestion.question,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildOptionButton(currentQuestion.displayOptions[0]),
              _buildOptionButton(currentQuestion.displayOptions[1]),
              _buildOptionButton(currentQuestion.displayOptions[2]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(String option) {
    Question currentQuestion = _viewModel.questions[currentQuestionIndex];
    bool isCorrectOption = option == currentQuestion.correctAnswer;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          _handleAnswer(option);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return isCorrectOption
                    ? AppViewModel.accentColor
                    : AppViewModel.errorColor;
              }
              return AppViewModel.backgroundColor;
            },
          ),
        ),
        child: Text(option, style: const TextStyle(fontSize: 16)),
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

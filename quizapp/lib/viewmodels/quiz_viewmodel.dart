// viewmodels/quiz_viewmodel.dart

// import 'package:your_project_name/database_helper.dart';
// import 'package:your_project_name/models/question.dart';

import '../database/database_helper.dart';
import '../models/question.dart';

class QuizViewModel {
  List<Question> questions = [];

  Future<void> fetchQuestions() async {
    DatabaseHelper databaseHelper = DatabaseHelper();
    List<Map<String, dynamic>>? questionMaps =
        await databaseHelper.getQuestions();

    // Convert the read-only list to a mutable list
    List<Map<String, dynamic>> mutableQuestionMaps =
        List<Map<String, dynamic>>.from(questionMaps ?? []);

    // Shuffle the mutable list of questions
    mutableQuestionMaps.shuffle();

    // Select the first 10 questions
    List<Map<String, dynamic>> selectedQuestionMaps =
        mutableQuestionMaps.take(10).toList();

    // Convert the selected questions to Question objects
    questions = List.generate(selectedQuestionMaps.length, (index) {
      // Extract correct answer and incorrect options
      String correctAnswer = selectedQuestionMaps[index]['correctAnswer'];
      List<String> incorrectOptions = [
        selectedQuestionMaps[index]['option1'],
        selectedQuestionMaps[index]['option2'],
        selectedQuestionMaps[index]['option3'],
        selectedQuestionMaps[index]['option4'],
      ]..remove(correctAnswer);

      // Shuffle the incorrect options
      incorrectOptions.shuffle();

      // Take only 2 random incorrect options
      List<String> displayOptions = [
        correctAnswer,
        incorrectOptions[0],
        incorrectOptions[1],
      ]..shuffle();

      return Question(
        id: selectedQuestionMaps[index]['id'],
        question: selectedQuestionMaps[index]['question'],
        correctAnswer: correctAnswer,
        displayOptions: displayOptions,
      );
    });
  }
}

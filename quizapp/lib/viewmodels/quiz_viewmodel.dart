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

        print('questionMaps=====>$questionMaps');

    questions = List.generate(questionMaps!.length, (index) {
      return Question(
        id: questionMaps[index]['id'],
        question: questionMaps[index]['question'],
        option1: questionMaps[index]['option1'],
        option2: questionMaps[index]['option2'],
        option3: questionMaps[index]['option3'],
        option4: questionMaps[index]['option4'],
        correctAnswer: questionMaps[index]['correctAnswer'],
        // isCorrect: false,
      );
    });
  }
}

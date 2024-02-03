class Question {
  final int id;
  final String question;
  final String correctAnswer;
  final List<String> displayOptions;

  Question({
    required this.id,
    required this.question,
    required this.correctAnswer,
    required this.displayOptions,
  });
}

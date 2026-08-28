class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options']),
      correctIndex: json['correctIndex'] as int,
    );
  }
}

class QuizResult {
  final int score;
  final int total;
  final int streak;

  QuizResult({required this.score, required this.total, required this.streak});
}

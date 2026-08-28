import 'package:flutter/material.dart';
import 'package:perplexity_clone/models/quiz_models.dart';
import 'package:perplexity_clone/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizPage extends StatefulWidget {
  final List<QuizQuestion> questions;

  const QuizPage({super.key, required this.questions});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentIndex = 0;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int? _selectedIndex;
  bool _answered = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _loadBestStreak();
  }

  Future<void> _loadBestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bestStreak = prefs.getInt('best_streak') ?? 0;
    });
  }

  Future<void> _saveBestStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    if (streak > _bestStreak) {
      await prefs.setInt('best_streak', streak);
      setState(() {
        _bestStreak = streak;
      });
    }
  }

  void _selectOption(int index) {
    if (_answered) return;

    setState(() {
      _selectedIndex = index;
      _answered = true;

      if (index == widget.questions[_currentIndex].correctIndex) {
        _score++;
        _streak++;
      } else {
        _streak = 0;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _answered = false;
      });
    } else {
      _saveBestStreak(_streak);
      setState(() {
        _finished = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _streak = 0;
      _selectedIndex = null;
      _answered = false;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return _buildResultScreen();
    }

    final question = widget.questions[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.sideNav,
        title: Text(
          "Question ${_currentIndex + 1} / ${widget.questions.length}",
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: AppColors.iconGrey),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score + Streak
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Score: $_score",
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Streak: $_streak  •  Best: $_bestStreak",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Question
              Text(
                question.question,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Options
              Expanded(
                child: ListView(
                  children: List.generate(question.options.length, (index) {
                    final isCorrect = index == question.correctIndex;
                    final isSelected = index == _selectedIndex;

                    Color borderColor = AppColors.searchBarBorder;
                    Color bgColor = AppColors.card;

                    if (_answered) {
                      if (isCorrect) {
                        borderColor = const Color(0xFF2E7D32);
                        bgColor = const Color(0xFF1B5E20).withOpacity(0.25);
                      } else if (isSelected && !isCorrect) {
                        borderColor = const Color(0xFFC62828);
                        bgColor = const Color(0xFFB71C1C).withOpacity(0.2);
                      }
                    } else if (isSelected) {
                      borderColor = AppColors.accent;
                      bgColor = AppColors.accent.withOpacity(0.12);
                    }

                    return GestureDetector(
                      onTap: () => _selectOption(index),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 1.5),
                        ),
                        child: Text(
                          question.options[index],
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            height: 1.35,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Next button
              if (_answered)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentIndex < widget.questions.length - 1
                          ? "Next Question"
                          : "See Results",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final total = widget.questions.length;
    final percentage = total == 0 ? 0 : (_score / total * 100).round();

    String title;
    String subtitle;

    if (percentage == 100) {
      title = "Perfect!";
      subtitle = "You got every question right.";
    } else if (percentage >= 70) {
      title = "Great job!";
      subtitle = "Solid understanding of the topic.";
    } else if (percentage >= 40) {
      title = "Not bad";
      subtitle = "You’re getting there. Try once more.";
    } else {
      title = "Keep learning";
      subtitle = "Review the answer and try again.";
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const Spacer(),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 36),
              Text(
                "$_score / $total",
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Best streak: $_bestStreak",
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _restartQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Play Again",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.searchBarBorder),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Back to Home",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

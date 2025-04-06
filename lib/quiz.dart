import 'package:flutter/material.dart';
import 'dart:ui';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class Question {
  final String questionText;
  final Map<String, int> options;

  Question({required this.questionText, required this.options});
}

class _QuizPageState extends State<QuizPage>
    with SingleTickerProviderStateMixin {
  final List<Question> _questions = [
    Question(
      questionText: "Little interest or pleasure in doing things?",
      options: {
        "Not at all": 0,
        "Several days": 1,
        "More than half the days": 2,
        "Nearly every day": 3,
      },
    ),
    Question(
      questionText: "Feeling down, depressed, or hopeless?",
      options: {
        "Not at all": 0,
        "Several days": 1,
        "More than half the days": 2,
        "Nearly every day": 3,
      },
    ),
    Question(
      questionText: "Trouble falling or staying asleep, or sleeping too much?",
      options: {
        "Not at all": 0,
        "Several days": 1,
        "More than half the days": 2,
        "Nearly every day": 3,
      },
    ),
    Question(
      questionText: "Feeling tired or having little energy?",
      options: {
        "Not at all": 0,
        "Several days": 1,
        "More than half the days": 2,
        "Nearly every day": 3,
      },
    ),
    Question(
      questionText: "Poor appetite or overeating?",
      options: {
        "Not at all": 0,
        "Several days": 1,
        "More than half the days": 2,
        "Nearly every day": 3,
      },
    ),
    Question(
      questionText: "Feeling bad about yourself or that you are a failure?",
      options: {
        "Not at all": 0,
        "Several days": 1,
        "More than half the days": 2,
        "Nearly every day": 3,
      },
    ),
    Question(
      questionText: "Trouble concentrating on things?",
      options: {
        "Not at all": 0,
        "Several days": 1,
        "More than half the days": 2,
        "Nearly every day": 3,
      },
    ),
    Question(
      questionText: "Moving or speaking slowly, or being overly fidgety?",
      options: {
        "Not at all": 0,
        "Several days": 1,
        "More than half the days": 2,
        "Nearly every day": 3,
      },
    ),
    Question(
      questionText:
          "Thoughts that you would be better off dead or hurting yourself?",
      options: {
        "Not at all": 0,
        "Several days": 1,
        "More than half the days": 2,
        "Nearly every day": 3,
      },
    ),
    Question(
      questionText: "Difficulty making decisions or feeling overwhelmed?",
      options: {
        "Not at all": 0,
        "Several days": 1,
        "More than half the days": 2,
        "Nearly every day": 3,
      },
    ),
  ];

  int _currentQuestionIndex = 0;
  int? _selectedScore;
  int _totalScore = 0;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _selectAnswer(int score) {
    setState(() {
      _selectedScore = score;
    });
  }

  void _nextQuestion() {
    if (_selectedScore == null) return;
    _totalScore += _selectedScore!;

    _animController.forward(from: 0).then((_) {
      setState(() {
        _selectedScore = null;
        if (_currentQuestionIndex < _questions.length - 1) {
          _currentQuestionIndex++;
        } else {
          _showResult();
        }
      });
    });
  }

  String _getDepressionSeverity(int score) {
    if (score <= 4) {
      return "Minimal or no depression";
    } else if (score <= 9) {
      return "Mild depression";
    } else if (score <= 14) {
      return "Moderate depression";
    } else if (score <= 19) {
      return "Moderately severe depression";
    } else {
      return "Severe depression";
    }
  }

  void _showResult() {
    String severity = _getDepressionSeverity(_totalScore);
    String details =
        "Score: $_totalScore\nSeverity: $severity\n\n"
        "This screening quiz is intended to help you understand your current state. "
        "It is not a diagnosis. If you experience persistent distress or suicidal thoughts, "
        "please seek help from a mental health professional immediately.";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF121212),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFFFD700), width: 2),
            ),
            title: Text(
              "Your Result",
              style: const TextStyle(
                fontFamily: 'AtkinsonHyperlegible',
                fontSize: 24,
                color: Color(0xFFFFFDD0),
              ),
            ),
            content: SingleChildScrollView(
              child: Text(
                details,
                style: const TextStyle(
                  fontFamily: 'OpenDyslexic',
                  fontSize: 18,
                  color: Color(0xFFFFFDD0),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _currentQuestionIndex = 0;
                    _totalScore = 0;
                    _selectedScore = null;
                  });
                },
                child: const Text(
                  "Restart",
                  style: TextStyle(
                    fontFamily: 'AtkinsonHyperlegible',
                    fontSize: 18,
                    color: Color(0xFFFFD700),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF121212);
    const textColor = Color(0xFFFFFDD0);
    const accentGold = Color(0xFFFFD700);

    Question currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -20 * (1 - _animController.value)),
                child: child,
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Depression Screening Quiz",
                  style: const TextStyle(
                    fontFamily: 'AtkinsonHyperlegible',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: accentGold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: accentGold, width: 2),
                  ),
                  elevation: 8,
                  shadowColor: accentGold.withOpacity(0.6),
                  color: bgColor.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Question ${_currentQuestionIndex + 1}/${_questions.length}",
                          style: const TextStyle(
                            fontFamily: 'AtkinsonHyperlegible',
                            fontSize: 22,
                            color: accentGold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          currentQuestion.questionText,
                          style: const TextStyle(
                            fontFamily: 'OpenDyslexic',
                            fontSize: 20,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...currentQuestion.options.entries.map((entry) {
                          bool isSelected = _selectedScore == entry.value;
                          return GestureDetector(
                            onTap: () => _selectAnswer(entry.value),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? accentGold.withOpacity(0.3)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: accentGold.withOpacity(0.5),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentGold.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontFamily: 'OpenDyslexic',
                                  fontSize: 18,
                                  color: textColor,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _selectedScore != null ? _nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGold,
                    foregroundColor: bgColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                    shadowColor: accentGold.withOpacity(0.8),
                  ),
                  child: Text(
                    _currentQuestionIndex < _questions.length - 1
                        ? "Next"
                        : "Submit",
                    style: const TextStyle(
                      fontFamily: 'AtkinsonHyperlegible',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

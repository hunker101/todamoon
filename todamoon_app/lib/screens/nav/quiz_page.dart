// quiz_page.dart - The quiz interface
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todamoon_app/data/quiz_data.dart';

class QuizPage extends StatefulWidget {
  final ModuleQuiz quiz;
  final String uid;
  final String moduleId;

  const QuizPage({
    super.key,
    required this.quiz,
    required this.uid,
    required this.moduleId,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  List<int?> userAnswers = [];
  bool isQuizCompleted = false;
  bool showExplanation = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    userAnswers = List.filled(widget.quiz.questions.length, null);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      userAnswers[currentQuestionIndex] = answerIndex;
      showExplanation = true;
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        showExplanation = false;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() {
    setState(() {
      isQuizCompleted = true;
    });
    _saveQuizResult();
  }

  Future<void> _saveQuizResult() async {
    final score = _calculateScore();
    final passed = score >= widget.quiz.passingScore;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('quiz_results')
          .doc(widget.moduleId)
          .set({
            'moduleId': widget.moduleId,
            'score': score,
            'passed': passed,
            'completedAt': FieldValue.serverTimestamp(),
            'answers': userAnswers,
          });

      // Update user progress to mark quiz as completed
      if (passed) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .update({'progress.${widget.moduleId}_quiz_completed': true});
      }
    } catch (e) {
      print('Error saving quiz result: $e');
    }
  }

  int _calculateScore() {
    int correct = 0;
    for (int i = 0; i < userAnswers.length; i++) {
      if (userAnswers[i] == widget.quiz.questions[i].correctAnswerIndex) {
        correct++;
      }
    }
    return ((correct / userAnswers.length) * 100).round();
  }

  Widget _buildQuestionCard() {
    final question = widget.quiz.questions[currentQuestionIndex];

    return SlideTransition(
      position: _slideAnimation.drive(
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero),
      ),
      child: Card(
        color: const Color(0xFF1C1F2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question counter
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Question ${currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Question text
              Text(
                question.question,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              // Answer options
              ...question.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isSelected = userAnswers[currentQuestionIndex] == index;
                final isCorrect = index == question.correctAnswerIndex;

                Color backgroundColor = const Color(0xFF2A2D3A);
                Color borderColor = Colors.grey.withOpacity(0.3);
                Color textColor = Colors.white;

                if (showExplanation && isSelected) {
                  if (isCorrect) {
                    backgroundColor = Colors.green.withOpacity(0.2);
                    borderColor = Colors.green;
                  } else {
                    backgroundColor = Colors.red.withOpacity(0.2);
                    borderColor = Colors.red;
                  }
                } else if (showExplanation && isCorrect) {
                  backgroundColor = Colors.green.withOpacity(0.2);
                  borderColor = Colors.green;
                } else if (isSelected) {
                  backgroundColor = Colors.blue.withOpacity(0.2);
                  borderColor = Colors.blue;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: showExplanation ? null : () => _selectAnswer(index),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  isSelected || (showExplanation && isCorrect)
                                      ? (isCorrect ? Colors.green : Colors.red)
                                      : Colors.transparent,
                              border: Border.all(
                                color:
                                    isSelected || (showExplanation && isCorrect)
                                        ? Colors.transparent
                                        : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child:
                                (isSelected || (showExplanation && isCorrect))
                                    ? Icon(
                                      isCorrect ? Icons.check : Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                    : Center(
                                      child: Text(
                                        String.fromCharCode(
                                          65 + index,
                                        ), // A, B, C, D
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(color: textColor, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),

              // Explanation
              if (showExplanation) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Explanation',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.explanation,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final score = _calculateScore();
    final passed = score >= widget.quiz.passingScore;

    return Card(
      color: const Color(0xFF1C1F2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              passed ? Icons.emoji_events : Icons.refresh,
              color: passed ? Colors.amber : Colors.orange,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              passed ? 'Congratulations!' : 'Keep Learning!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              passed
                  ? 'You passed the quiz!'
                  : 'You can retake the quiz to improve your score.',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    passed
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '$score%',
                    style: TextStyle(
                      color: passed ? Colors.green : Colors.orange,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Your Score',
                    style: TextStyle(
                      color: passed ? Colors.green : Colors.orange,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Passing Score: ${widget.quiz.passingScore}%',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (!passed)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          currentQuestionIndex = 0;
                          userAnswers = List.filled(
                            widget.quiz.questions.length,
                            null,
                          );
                          isQuizCompleted = false;
                          showExplanation = false;
                        });
                        _animationController.reset();
                        _animationController.forward();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retake Quiz'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (!passed) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, passed),
                    icon: const Icon(Icons.check),
                    label: Text(passed ? 'Complete' : 'Continue'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: passed ? Colors.green : Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1F2A),
        elevation: 0,
        title: Text(widget.quiz.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress bar
            if (!isQuizCompleted) ...[
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor:
                      (currentQuestionIndex + 1) / widget.quiz.questions.length,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.lightBlue],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            Expanded(
              child:
                  isQuizCompleted ? _buildResultCard() : _buildQuestionCard(),
            ),

            // Next button
            if (!isQuizCompleted && showExplanation)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    currentQuestionIndex < widget.quiz.questions.length - 1
                        ? 'Next Question'
                        : 'Complete Quiz',
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
    );
  }
}

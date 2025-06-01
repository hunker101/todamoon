import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todamoon_app/data/quiz_data.dart';


class QuizPage extends StatefulWidget {
  final String? moduleId; // Make optional - null means comprehensive quiz

  const QuizPage({super.key, this.moduleId});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestion = 0;
  int score = 0;
  List<QuizQuestion> quizQuestions = [];
  bool isLoading = true;
  String? selectedAnswer;
  bool showResult = false;
  List<String> completedModules = [];

  @override
  void initState() {
    super.initState();
    loadQuizQuestions();
  }

  Future<void> loadQuizQuestions() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      // Get user's completed modules
      Set<String> userCompletedModules = {};
      
      if (userDoc.exists) {
        final data = userDoc.data();
        final progressData = data?['progress'] as Map<String, dynamic>? ?? {};
        
        // Check each module to see if it has completed lessons
        for (String moduleId in progressData.keys) {
          final moduleProgress = progressData[moduleId] as List<dynamic>? ?? [];
          if (moduleProgress.isNotEmpty) {
            userCompletedModules.add(moduleId);
          }
        }
      }

      // Also check for modules with quiz scores (alternative completion indicator)
      final quizProgressQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('quiz_progress')
          .get();
      
      for (var doc in quizProgressQuery.docs) {
        userCompletedModules.add(doc.id);
      }

      List<QuizQuestion> questions = [];
      
      if (widget.moduleId != null) {
        // Single module quiz
        questions = moduleQuizQuestions[widget.moduleId] ?? [];
      } else {
        // Comprehensive quiz from all completed modules
        for (String moduleId in userCompletedModules) {
          final moduleQuestions = moduleQuizQuestions[moduleId] ?? [];
          questions.addAll(moduleQuestions);
        }
        
        // Shuffle questions for variety
        questions.shuffle();
        
        // Limit to 15 questions max for comprehensive quiz
        if (questions.length > 15) {
          questions = questions.take(15).toList();
        }
      }

      setState(() {
        quizQuestions = questions;
        completedModules = userCompletedModules.toList();
        isLoading = false;
      });
      
    } catch (e) {
      debugPrint('Error loading quiz: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void selectAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
    });
  }

  void nextQuestion() {
    if (selectedAnswer == null) return;
    
    // FIX: Check bounds before accessing the array
    if (currentQuestion < quizQuestions.length) {
      final correct = quizQuestions[currentQuestion].correctAnswer;
      if (selectedAnswer == correct) {
        score++;
      }
    }

    // FIX: Check if we're at the last question before incrementing
    if (currentQuestion + 1 >= quizQuestions.length) {
      finishQuiz();
      return;
    }

    setState(() {
      currentQuestion++;
      selectedAnswer = null;
      showResult = false;
    });
  }

  void showAnswerResult() {
    setState(() {
      showResult = true;
    });
  }

  Future<void> finishQuiz() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final quizType = widget.moduleId ?? 'comprehensive';
    
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('quiz_progress')
          .doc(quizType)
          .set({
        'score': score,
        'total_questions': quizQuestions.length,
        'timestamp': FieldValue.serverTimestamp(),
        'modules_included': widget.moduleId != null 
            ? [widget.moduleId] 
            : completedModules,
      });

      showDialog(
  context: context,
  barrierDismissible: false,
  builder: (_) => Dialog(
    backgroundColor: Colors.transparent,
    child: Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D26),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success Icon with Animation-ready Container
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (score >= quizQuestions.length * 0.7 
                  ? Colors.green 
                  : score >= quizQuestions.length * 0.5
                      ? Colors.orange
                      : Colors.red).withOpacity(0.1),
              border: Border.all(
                color: score >= quizQuestions.length * 0.7 
                    ? Colors.green 
                    : score >= quizQuestions.length * 0.5
                        ? Colors.orange
                        : Colors.red,
                width: 2,
              ),
            ),
            child: Icon(
              score >= quizQuestions.length * 0.7 
                  ? Icons.check_circle_outline
                  : score >= quizQuestions.length * 0.5
                      ? Icons.star_outline
                      : Icons.close_outlined,
              color: score >= quizQuestions.length * 0.7 
                  ? Colors.green 
                  : score >= quizQuestions.length * 0.5
                      ? Colors.orange
                      : Colors.red,
              size: 36,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Title
          const Text(
            'Quiz Complete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            widget.moduleId != null 
                ? 'Module Assessment'
                : '${completedModules.length} Modules Combined',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Score Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF252936),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$score/${quizQuestions.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (score >= quizQuestions.length * 0.7 
                        ? Colors.green 
                        : score >= quizQuestions.length * 0.5
                            ? Colors.orange
                            : Colors.red).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${((score / quizQuestions.length) * 100).toInt()}%',
                    style: TextStyle(
                      color: score >= quizQuestions.length * 0.7 
                          ? Colors.green 
                          : score >= quizQuestions.length * 0.5
                              ? Colors.orange
                              : Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 28),
          
          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
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
    } catch (e) {
      debugPrint('Error saving quiz: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1D23),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF9500),
          title: const Text('Loading Quiz...', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF9500)),
        ),
      );
    }

    if (quizQuestions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1D23),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF9500),
          title: const Text('Quiz', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No quiz questions available',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Complete some lessons first!',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // FIX: Add bounds checking here too
    if (currentQuestion >= quizQuestions.length) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1D23),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF9500)),
        ),
      );
    }

    final question = quizQuestions[currentQuestion];
    final progress = (currentQuestion + 1) / quizQuestions.length;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1D23),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9500),
        title: Text(
          widget.moduleId != null ? 'Module Quiz' : 'Comprehensive Quiz',
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${currentQuestion + 1} of ${quizQuestions.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      'Score: $score',
                      style: const TextStyle(color: Color(0xFFFF9500), fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[800],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9500)),
                ),
              ],
            ),
          ),
          
          // Question
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2F36),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      question.question,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Options
                  Expanded(
                    child: ListView.builder(
                      itemCount: question.options.length,
                      itemBuilder: (context, index) {
                        final option = question.options[index];
                        final isSelected = selectedAnswer == option;
                        final isCorrect = option == question.correctAnswer;
                        
                        Color backgroundColor = const Color(0xFF2C2F36);
                        Color borderColor = Colors.transparent;
                        Color textColor = Colors.white;
                        
                        if (showResult) {
                          if (isCorrect) {
                            backgroundColor = Colors.green.withOpacity(0.2);
                            borderColor = Colors.green;
                          } else if (isSelected && !isCorrect) {
                            backgroundColor = Colors.red.withOpacity(0.2);
                            borderColor = Colors.red;
                          }
                        } else if (isSelected) {
                          backgroundColor = const Color(0xFFFF9500).withOpacity(0.2);
                          borderColor = const Color(0xFFFF9500);
                        }
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: showResult ? null : () => selectAnswer(option),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                border: Border.all(color: borderColor, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.grey),
                                      color: isSelected || (showResult && isCorrect) 
                                          ? (showResult && isCorrect ? Colors.green : const Color(0xFFFF9500))
                                          : Colors.transparent,
                                    ),
                                    child: isSelected || (showResult && isCorrect)
                                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Next button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedAnswer == null 
                    ? null 
                    : showResult 
                        ? nextQuestion 
                        : showAnswerResult,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9500),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  showResult 
                      ? (currentQuestion + 1 >= quizQuestions.length ? 'Finish Quiz' : 'Next Question')
                      : 'Check Answer',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
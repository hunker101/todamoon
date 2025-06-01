import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todamoon_app/screens/nav/lesson_content_page.dart';
import '../../data/modules_data.dart';
import 'quiz_page.dart';

class ModuleDetailPage extends StatefulWidget {
  final String moduleId;
  final String title;
  final String description;

  const ModuleDetailPage({
    super.key,
    required this.moduleId,
    required this.title,
    required this.description,
  });

  @override
  State<ModuleDetailPage> createState() => _ModuleDetailPageState();
}

class _ModuleDetailPageState extends State<ModuleDetailPage>
    with TickerProviderStateMixin {
  int? savedScore;
  bool loading = true;
  List<String> completedLessons = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    fetchQuizProgress();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchQuizProgress() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      
      // Fetch quiz progress
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('quiz_progress')
          .doc(widget.moduleId)
          .get();

      // Fetch lesson progress
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      List<String> lessons = [];
      if (userDoc.exists) {
        final data = userDoc.data();
        final progressData = data?['progress'] as Map<String, dynamic>? ?? {};
        lessons = List<String>.from(progressData[widget.moduleId] ?? []);
      }

      setState(() {
        savedScore = doc.exists ? doc['score'] : null;
        completedLessons = lessons;
        loading = false;
      });
      _animationController.forward();
    } catch (e) {
      debugPrint('Error fetching progress: $e');
      setState(() {
        loading = false;
      });
      _animationController.forward();
    }
  }

  Module? get currentModule {
    try {
      return modules.firstWhere((module) => module.id == widget.moduleId);
    } catch (e) {
      return null;
    }
  }

  double get lessonProgress {
    final module = currentModule;
    if (module == null || module.lessons.isEmpty) return 0.0;
    return completedLessons.length / module.lessons.length;
  }

  bool get isModuleComplete {
    return savedScore != null;
  }

  Widget _buildModuleHeader() {
    final module = currentModule;
    final progressPercent = (lessonProgress * 100).toInt();
    final totalLessons = module?.lessons.length ?? 0;
    final completedCount = completedLessons.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9500), Color(0xFFFFB84D)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Module Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              // Module Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalLessons lessons',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              // Progress Percentage
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: lessonProgress,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonItem(dynamic lesson, int index) {
    final isCompleted = completedLessons.contains(lesson.id);
    final lessonNumber = index + 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F36),
        borderRadius: BorderRadius.circular(12),
        border: isCompleted 
            ? Border.all(color: const Color(0xFF4CAF50), width: 1.5)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isCompleted 
                ? const Color(0xFF4CAF50) 
                : const Color(0xFF424242),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.play_arrow,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Lesson $lessonNumber',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
        trailing: isCompleted
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Completed',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonContentPage(
                lesson: lesson,
                module: currentModule!,
                uid: FirebaseAuth.instance.currentUser!.uid,
                onComplete: () {
                  fetchQuizProgress();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTakeQuizButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizPage(moduleId: widget.moduleId),
            ),
          );
          if (result == true) {
            fetchQuizProgress();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isModuleComplete ? Colors.green : const Color(0xFFFF9500),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          isModuleComplete ? 'Retake Quiz' : 'Take Quiz',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final module = currentModule;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1D23),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9500),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF9500),
                strokeWidth: 3,
              ),
            )
          : SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    
                    _buildModuleHeader(),
                    
                  
                    Expanded(
                      child: module != null && module.lessons.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: module.lessons.length,
                              itemBuilder: (context, index) {
                                return _buildLessonItem(module.lessons[index], index);
                              },
                            )
                          : const Center(
                              child: Text(
                                'No lessons available',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                    ),
                    
                    
                    _buildTakeQuizButton(),
                  ],
                ),
              ),
            ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todamoon_app/screens/nav/lesson_content_page.dart';
import '../../data/modules_data.dart';

// Module Detail Page - Shows list of lessons
class ModuleDetailPage extends StatefulWidget {
  final Module module;
  final String uid;

  const ModuleDetailPage({
    Key? key,
    required this.module, // Changed parameter name
    required this.uid,
  }) : super(key: key);

  @override
  State<ModuleDetailPage> createState() => _ModuleDetailPageState();
}

class _ModuleDetailPageState extends State<ModuleDetailPage> {
  List<String> completedLessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .get();

      final progress = doc.data()?['progress'] ?? {};
      final moduleProgress = progress[widget.module.id] ?? [];

      setState(() {
        completedLessons = List<String>.from(moduleProgress);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  bool isLessonCompleted(String lessonId) {
    return completedLessons.contains(lessonId);
  }

  int get completedCount => completedLessons.length;
  double get progressPercentage =>
      widget.module.lessons.isEmpty
          ? 0.0
          : completedCount / widget.module.lessons.length;

  Widget _buildProgressHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange.shade400, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    widget.module.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.module.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.module.lessons.length} lessons',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '${(progressPercentage * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$completedCount/${widget.module.lessons.length}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressPercentage,
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

  Widget _buildLessonTile(Lesson lesson, int index) {
    final isCompleted = isLessonCompleted(lesson.id);
    final isLocked =
        index > 0 && !isLessonCompleted(widget.module.lessons[index - 1].id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F2A),
        borderRadius: BorderRadius.circular(12),
        border:
            isCompleted
                ? Border.all(color: Colors.green.withOpacity(0.5), width: 1)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                isCompleted
                    ? Colors.green
                    : isLocked
                    ? Colors.grey.shade600
                    : Colors.orange.shade400,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            isCompleted
                ? Icons.check
                : isLocked
                ? Icons.lock
                : Icons.play_arrow,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          lesson.title,
          style: TextStyle(
            color: isLocked ? Colors.grey.shade400 : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          lesson.description ?? 'Tap to start learning',
          style: TextStyle(
            color: isLocked ? Colors.grey.shade600 : Colors.grey.shade400,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing:
            isCompleted
                ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                : isLocked
                ? null
                : const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                ),
        onTap:
            isLocked
                ? null
                : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => LessonContentPage(
                            lesson: lesson,
                            module: widget.module,
                            uid: widget.uid,
                            onComplete: () {
                              loadProgress(); // Refresh progress when lesson is completed
                            },
                          ),
                    ),
                  );
                },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.orange.shade400,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.module.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              )
              : Column(
                children: [
                  _buildProgressHeader(),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: widget.module.lessons.length,
                      itemBuilder: (context, index) {
                        return _buildLessonTile(
                          widget.module.lessons[index],
                          index,
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}

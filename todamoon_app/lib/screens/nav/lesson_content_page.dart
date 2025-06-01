import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todamoon_app/data/modules_data.dart';

class LessonContentPage extends StatefulWidget {
  final Lesson lesson;
  final Module module;
  final String uid;
  final VoidCallback onComplete;

  const LessonContentPage({
    super.key,
    required this.lesson,
    required this.module,
    required this.uid,
    required this.onComplete,
  });

  @override
  State<LessonContentPage> createState() => _LessonContentPageState();
}

class _LessonContentPageState extends State<LessonContentPage> {
  bool _isCompleted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkCompletionStatus();
  }

  Future<void> _checkCompletionStatus() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final progress = data?['progress'] as Map<String, dynamic>? ?? {};
        final moduleProgress = progress[widget.module.id] as List<dynamic>? ?? [];

        setState(() {
          _isCompleted = moduleProgress.contains(widget.lesson.id);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isCompleted = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking completion status: $e');
      setState(() {
        _isCompleted = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsCompleted() async {
    if (_isCompleted) return;

    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        
        Map<String, dynamic> progress;
        if (doc.exists) {
          final data = doc.data() ?? {};
          progress = Map<String, dynamic>.from(data['progress'] ?? {});
        } else {
          progress = {};
          // Create user document if it doesn't exist
          transaction.set(docRef, {'progress': {}});
        }

        final moduleProgress = List<String>.from(
          progress[widget.module.id] ?? [],
        );

        if (!moduleProgress.contains(widget.lesson.id)) {
          moduleProgress.add(widget.lesson.id);
          progress[widget.module.id] = moduleProgress;
          
          if (doc.exists) {
            transaction.update(docRef, {'progress': progress});
          } else {
            transaction.set(docRef, {'progress': progress});
          }
        }
      });

      setState(() => _isCompleted = true);
      widget.onComplete();

      // Show completion message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Lesson completed! 🎉'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error marking lesson as complete: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking lesson as complete: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Widget _buildLessonContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lesson header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.orange.shade400, Colors.orange.shade600],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lesson.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.lesson.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.lesson.description!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Lesson content (simplified - no more sections)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1F2A),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              widget.lesson.content,
              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 16,
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
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
          widget.lesson.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isCompleted)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.check, color: Colors.green, size: 20),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            )
          : _buildLessonContent(),
      bottomNavigationBar: _isLoading
          ? null
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1F2A),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isCompleted ? null : _markAsCompleted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isCompleted
                          ? Colors.green
                          : Colors.orange.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: Colors.green,
                      disabledForegroundColor: Colors.white,
                    ),
                    child: Text(
                      _isCompleted ? 'Completed ' : 'Mark as Complete',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
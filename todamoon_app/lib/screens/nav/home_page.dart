import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/modules_data.dart';
import 'module_detail_page.dart';

class HomePage extends StatefulWidget {
  final String uid;
  const HomePage({super.key, required this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  Map<String, int> quizScores = {};
  Map<String, List<String>> lessonProgress = {}; // Track lesson completion
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _loadProgress();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? widget.uid;
      
      // Load quiz scores
      final quizSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('quiz_progress')
          .get();
      
      Map<String, int> scores = {};
      for (var doc in quizSnapshot.docs) {
        scores[doc.id] = doc['score'] as int? ?? 0;
      }
      
      // Load lesson progress
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      
      Map<String, List<String>> progress = {};
      if (userDoc.exists) {
        final data = userDoc.data();
        final progressData = data?['progress'] as Map<String, dynamic>? ?? {};
        
        for (var entry in progressData.entries) {
          progress[entry.key] = List<String>.from(entry.value ?? []);
        }
      }
      
      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          quizScores = scores;
          lessonProgress = progress;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      debugPrint('Error loading progress: $e');
      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() => _isLoading = false);
        _animationController.forward();
      }
    }
  }

  int get completedQuizzes {
    return quizScores.length;
  }

  int get totalModules {
    return modules.length;
  }

  double get overallProgress {
    if (totalModules == 0) return 0.0;
    return completedQuizzes / totalModules;
  }

  // Get module progress based on completed lessons
  double _getModuleProgress(Module module) {
    final completedLessons = lessonProgress[module.id] ?? [];
    if (module.lessons.isEmpty) return 0.0;
    return completedLessons.length / module.lessons.length;
  }

  // Helper methods for status display
  String _getStatusText(Module module) {
    final progress = _getModuleProgress(module);
    if (quizScores.containsKey(module.id)) {
      return 'Completed';
    } else if (progress > 0) {
      return 'In Progress';
    }
    return 'Not Started';
  }

  Color _getStatusColor(Module module) {
    final progress = _getModuleProgress(module);
    if (quizScores.containsKey(module.id)) {
      return Colors.green;
    } else if (progress > 0) {
      return Colors.orange;
    }
    return Colors.grey;
  }

  IconData _getStatusIcon(Module module) {
    final progress = _getModuleProgress(module);
    if (quizScores.containsKey(module.id)) {
      return Icons.check_circle;
    } else if (progress > 0) {
      return Icons.play_circle_filled;
    }
    return Icons.play_circle_outline;
  }

  // Get module image path from assets
  String _getModuleImagePath(Module module) {
    // You can customize this logic based on how you've named your assets
    // Option 1: Use module ID to match asset filename
    //return 'assets/images/${module.id}.png';
    
    // Option 2: If you have a specific mapping, you can use a switch statement:
    
    switch (module.id) {
      case 'introduction':
        return 'assets/images/introduction.jpeg';
      case 'bitcoin':
        return 'assets/images/bitcoin.jpeg';
      case 'hashing':
        return 'assets/images/hashing.jpeg';
        case 'blockchain':
        return 'assets/images/blockchain.jpeg';
        case 'altcoins':
        return 'assets/images/altcoin.jpeg';
        case 'crypto_exchanges':
        return 'assets/images/crypto_trading.jpeg';
      default:
        return 'assets/images/bg.png';
    }
    
  }

  Widget _buildWelcomeHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF2196F3), const Color(0xFF21CBF3)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Continue your learning journey',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Progress',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: overallProgress,
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
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(overallProgress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$completedQuizzes/$totalModules modules',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    int completedModules = 0;
    int inProgressModules = 0;
    int notStartedModules = 0;

    for (final module in modules) {
      if (quizScores.containsKey(module.id)) {
        completedModules++;
      } else if (_getModuleProgress(module) > 0) {
        inProgressModules++;
      } else {
        notStartedModules++;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Completed',
              '$completedModules',
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'In Progress',
              '$inProgressModules',
              Icons.play_circle_filled,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Not Started',
              '$notStartedModules',
              Icons.play_circle_outline,
              Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(int index) {
    final module = modules[index];
    final isCompleted = quizScores.containsKey(module.id);
    final score = quizScores[module.id];
    final progress = _getModuleProgress(module);
    final completedLessons = lessonProgress[module.id]?.length ?? 0;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ModuleDetailPage(
              moduleId: module.id,
              title: module.title,
              description: module.description,
            ),
          ),
        );
        // Refresh progress when returning from module detail page
        if (result == true || result == null) {
          _loadProgress();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1F2A),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isCompleted
              ? Border.all(color: Colors.green.withOpacity(0.5), width: 2)
              : progress > 0
                  ? Border.all(color: Colors.orange.withOpacity(0.5), width: 2)
                  : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with completion status
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(module).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusText(module),
                        style: TextStyle(
                          color: _getStatusColor(module),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(module).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getStatusIcon(module),
                      color: _getStatusColor(module),
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Module image from assets
            Expanded(
              child: Center(
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      _getModuleImagePath(module),
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to icon if image not found
                        return Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.school,
                            color: Colors.blue,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Module info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      module.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      isCompleted
                          ? 'Quiz Score: $score'
                          : progress > 0
                              ? '$completedLessons/${module.lessons.length} lessons'
                              : '${module.lessons.length} lessons',
                      style: TextStyle(
                        color: isCompleted
                            ? Colors.green
                            : progress > 0
                                ? Colors.orange
                                : Colors.grey[400],
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Progress indicator
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: isCompleted ? 1.0 : progress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isCompleted
                                ? [Colors.green, Colors.green.shade300]
                                : progress > 0
                                    ? [Colors.orange, Colors.orange.shade300]
                                    : [Colors.grey, Colors.grey],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
        actions: [
          IconButton(onPressed: doLogout, icon: Icon(Icons.logout, color: Colors.red,))
        ],
        backgroundColor: const Color(0xFF1C1F2A),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'ToDaMoon',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.lightBlueAccent,
                strokeWidth: 3,
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator(
                onRefresh: _loadProgress,
                color: Colors.lightBlueAccent,
                backgroundColor: const Color(0xFF1C1F2A),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeHeader(),
                      _buildStatsRow(),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Your Modules',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Handle view all - could show a separate page with all modules
                              },
                              child: const Text(
                                'View All',
                                style: TextStyle(
                                  color: Colors.lightBlueAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: modules.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemBuilder: (context, index) => _buildModuleCard(index),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

   void doLogout() async {
    await FirebaseAuth.instance.signOut();
  }
}
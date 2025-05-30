import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/modules_data.dart';
import 'module_detail_page.dart';

class HomePage extends StatefulWidget {
  final String uid;
  const HomePage({super.key, required this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  Map<String, dynamic> userProgress = {};
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
    loadProgress();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadProgress() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .get();
      setState(() {
        userProgress = doc.data()?['progress'] ?? {};
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      _animationController.forward();
    }
  }

  int get totalCompletedLessons {
    int total = 0;
    for (final module in localModules) {
      final completed = userProgress[module.id] ?? [];
      total += (completed as List).length;
    }
    return total;
  }

  int get totalLessons {
    return localModules.fold(0, (sum, module) => sum + module.lessons.length);
  }

  double get overallProgress {
    if (totalLessons == 0) return 0.0;
    return totalCompletedLessons / totalLessons;
  }

  // Helper methods for status display
  String _getStatusText(int completed, int total) {
    if (completed == 0) return 'Not Started';
    if (completed == total) return 'Completed';
    return 'In Progress';
  }

  Color _getStatusColor(int completed, int total) {
    if (completed == 0) return Colors.grey;
    if (completed == total) return Colors.green;
    return Colors.orange;
  }

  IconData _getStatusIcon(int completed, int total) {
    if (completed == 0) return Icons.play_circle_outline;
    if (completed == total) return Icons.check_circle;
    return Icons.timer;
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
                    '$totalCompletedLessons/$totalLessons lessons',
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

    for (final module in localModules) {
      final completed = userProgress[module.id] ?? [];
      final completedLessons = (completed as List).length;
      final totalLessons = module.lessons.length;

      if (completedLessons == 0) {
        notStartedModules++;
      } else if (completedLessons == totalLessons) {
        completedModules++;
      } else {
        inProgressModules++;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Modules',
              '${localModules.length}',
              Icons.book,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
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
              Icons.timer,
              Colors.orange,
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
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildModuleCard(int index) {
    final moduleItem = localModules[index];
    final completed = userProgress[moduleItem.id] ?? [];
    final completedLessons = (completed as List).length;
    final totalLessons = moduleItem.lessons.length;
    final progress = totalLessons > 0 ? completedLessons / totalLessons : 0.0;
    final isCompleted = completedLessons == totalLessons;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ModuleDetailPage(
                  module: moduleItem.toModule(),
                  uid: widget.uid,
                ),
          ),
        );
        // Refresh progress when returning from module detail page
        if (result == true || result == null) {
          loadProgress();
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
          border:
              isCompleted
                  ? Border.all(color: Colors.green.withOpacity(0.5), width: 2)
                  : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Added this to prevent overflow
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
                        color: _getStatusColor(
                          completedLessons,
                          totalLessons,
                        ).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusText(completedLessons, totalLessons),
                        style: TextStyle(
                          color: _getStatusColor(
                            completedLessons,
                            totalLessons,
                          ),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        completedLessons,
                        totalLessons,
                      ).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getStatusIcon(completedLessons, totalLessons),
                      color: _getStatusColor(completedLessons, totalLessons),
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Module image
            Expanded(
              child: Center(
                child: Container(
                  height: 60, // Reduced height
                  width: 60, // Reduced width
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12), // Reduced radius
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
                    child: Image.asset(moduleItem.imagePath, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),

            // Module info
            Padding(
              padding: const EdgeInsets.all(12), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Added this
                children: [
                  Center(
                    child: Text(
                      moduleItem.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14, // Reduced font size
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4), // Reduced spacing
                  Center(
                    child: Text(
                      '$completedLessons / $totalLessons lessons',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11,
                      ), // Reduced font size
                    ),
                  ),
                  const SizedBox(height: 6), // Reduced spacing
                  // Progress bar
                  Container(
                    height: 4, // Reduced height
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:
                                isCompleted
                                    ? [Colors.green, Colors.green.shade300]
                                    : [Colors.blue, Colors.lightBlue],
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
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.lightBlueAccent,
                  strokeWidth: 3,
                ),
              )
              : FadeTransition(
                opacity: _fadeAnimation,
                child: RefreshIndicator(
                  onRefresh: loadProgress,
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
                                  // Handle view all
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
                            itemCount: localModules.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio:
                                      0.85, // Slightly increased aspect ratio
                                ),
                            itemBuilder:
                                (context, index) => _buildModuleCard(index),
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
}

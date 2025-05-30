// quiz_data.dart - Define quiz questions for each module
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question: map['question'],
      options: List<String>.from(map['options']),
      correctAnswerIndex: map['correctAnswerIndex'],
      explanation: map['explanation'],
    );
  }
}

class ModuleQuiz {
  final String moduleId;
  final String title;
  final List<QuizQuestion> questions;
  final int passingScore; // percentage needed to pass

  ModuleQuiz({
    required this.moduleId,
    required this.title,
    required this.questions,
    this.passingScore = 70,
  });
}

// Sample quiz data - you can expand this based on your modules
final Map<String, ModuleQuiz> moduleQuizzes = {
  'basic_flutter': ModuleQuiz(
    moduleId: 'basic_flutter',
    title: 'Flutter Basics Quiz',
    questions: [
      QuizQuestion(
        question: 'What is Flutter?',
        options: [
          'A JavaScript framework',
          'A UI toolkit for building cross-platform apps',
          'A database management system',
          'A web browser',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Flutter is Google\'s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.',
      ),
      QuizQuestion(
        question: 'Which programming language is primarily used in Flutter?',
        options: ['Java', 'Swift', 'Dart', 'JavaScript'],
        correctAnswerIndex: 2,
        explanation:
            'Flutter uses Dart programming language, which was also developed by Google.',
      ),
      QuizQuestion(
        question: 'What is a Widget in Flutter?',
        options: [
          'A small application',
          'A building block of the UI',
          'A type of variable',
          'A database table',
        ],
        correctAnswerIndex: 1,
        explanation:
            'In Flutter, everything is a widget. Widgets are the building blocks of Flutter applications that describe what their view should look like.',
      ),
      QuizQuestion(
        question: 'Which widget is used to create a scrollable list?',
        options: ['Container', 'ListView', 'Row', 'Stack'],
        correctAnswerIndex: 1,
        explanation:
            'ListView is the widget used to create scrollable lists in Flutter.',
      ),
      QuizQuestion(
        question:
            'What does StatefulWidget provide that StatelessWidget doesn\'t?',
        options: [
          'Better performance',
          'Ability to change state during runtime',
          'More styling options',
          'Database connectivity',
        ],
        correctAnswerIndex: 1,
        explanation:
            'StatefulWidget can maintain state that can change during the widget\'s lifetime, while StatelessWidget is immutable.',
      ),
      QuizQuestion(
        question:
            'Which method is called when a StatefulWidget is first created?',
        options: ['build()', 'dispose()', 'initState()', 'setState()'],
        correctAnswerIndex: 2,
        explanation:
            'initState() is called once when the StatefulWidget is first created and inserted into the widget tree.',
      ),
      QuizQuestion(
        question: 'What is the purpose of the build() method?',
        options: [
          'To compile the app',
          'To describe the UI of the widget',
          'To handle user input',
          'To manage app state',
        ],
        correctAnswerIndex: 1,
        explanation:
            'The build() method describes the part of the user interface represented by the widget.',
      ),
      QuizQuestion(
        question:
            'Which widget is used for layout with children in a vertical arrangement?',
        options: ['Row', 'Column', 'Stack', 'Wrap'],
        correctAnswerIndex: 1,
        explanation: 'Column widget arranges its children vertically.',
      ),
      QuizQuestion(
        question: 'What is Hot Reload in Flutter?',
        options: [
          'A debugging tool',
          'A feature that allows instant code changes preview',
          'A testing framework',
          'A deployment method',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Hot Reload allows developers to see changes in code instantly without losing the app state.',
      ),
      QuizQuestion(
        question: 'Which file contains the main entry point of a Flutter app?',
        options: ['index.dart', 'app.dart', 'main.dart', 'flutter.dart'],
        correctAnswerIndex: 2,
        explanation:
            'main.dart contains the main() function which is the entry point of every Flutter application.',
      ),
      QuizQuestion(
        question:
            'What is the difference between mainAxisAlignment and crossAxisAlignment?',
        options: [
          'No difference, they are the same',
          'mainAxis is horizontal, crossAxis is vertical',
          'mainAxis is the primary direction, crossAxis is perpendicular',
          'mainAxis is for positioning, crossAxis is for sizing',
        ],
        correctAnswerIndex: 2,
        explanation:
            'mainAxisAlignment controls alignment along the main axis (vertical for Column, horizontal for Row), while crossAxisAlignment controls alignment along the cross axis (perpendicular to main axis).',
      ),
      QuizQuestion(
        question: 'Which widget provides material design styling?',
        options: ['CupertinoApp', 'MaterialApp', 'WidgetsApp', 'FlutterApp'],
        correctAnswerIndex: 1,
        explanation:
            'MaterialApp provides Material Design styling and navigation features for Flutter apps.',
      ),
      QuizQuestion(
        question: 'What is the purpose of the Scaffold widget?',
        options: [
          'To create animations',
          'To provide basic layout structure for screens',
          'To handle user input',
          'To manage app state',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Scaffold provides the basic material design visual layout structure including AppBar, Body, FloatingActionButton, etc.',
      ),
      QuizQuestion(
        question: 'How do you navigate to a new screen in Flutter?',
        options: [
          'Navigator.push()',
          'Screen.navigate()',
          'Route.change()',
          'App.goto()',
        ],
        correctAnswerIndex: 0,
        explanation:
            'Navigator.push() is used to navigate to a new screen by pushing a new route onto the navigation stack.',
      ),
      QuizQuestion(
        question:
            'What is the recommended way to manage simple state in Flutter?',
        options: ['Redux', 'setState()', 'BLoC', 'Provider'],
        correctAnswerIndex: 1,
        explanation:
            'For simple state management within a single widget, setState() is the recommended approach.',
      ),
    ],
  ),
  // Add more module quizzes here for other modules
  'advanced_widgets': ModuleQuiz(
    moduleId: 'advanced_widgets',
    title: 'Advanced Widgets Quiz',
    questions: [
      QuizQuestion(
        question: 'What is the purpose of the FutureBuilder widget?',
        options: [
          'To build UI based on Future results',
          'To create animations',
          'To handle user input',
          'To manage routes',
        ],
        correctAnswerIndex: 0,
        explanation:
            'FutureBuilder builds UI based on the latest snapshot of interaction with a Future.',
      ),
      // Add more questions for advanced widgets...
    ],
  ),
};

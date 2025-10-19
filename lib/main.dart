import 'package:flutter/material.dart';
import 'backend.dart'; // Your updated backend.dart file
import 'dart:async';
import 'dart:ui'; // Needed for the glass blur effect

// Create an instance of your backend logic
Backend backend = Backend();

void main() => runApp(const IQTesterApp());

class IQTesterApp extends StatelessWidget {
  const IQTesterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the top-right debug banner
      home: const PreloadPage(),
    );
  }
}

// --- 1. PRELOAD PAGE / SPLASH SCREEN (No changes needed) ---
class PreloadPage extends StatefulWidget {
  const PreloadPage({super.key});

  @override
  State<PreloadPage> createState() => _PreloadPageState();
}

class _PreloadPageState extends State<PreloadPage> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
          () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const QuizScreen()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D2671), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.psychology_alt, size: 100, color: Colors.white70),
              const SizedBox(height: 30),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
              const SizedBox(height: 20),
              Text(
                'Quizler The Real Iq Checker...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 18.0,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text('© Rakshak',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14.0,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
              ),),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 2. MAIN QUIZ SCREEN (No changes needed) ---
class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D2671), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: QuizPage(),
          ),
        ),
      ),
    );
  }
}

// --- 3. THE REDEFINED QUIZ PAGE UI WITH NEW TIMER UI ---
class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with WidgetsBindingObserver {
  List<bool> answerStatus = [];
  bool _wasPaused = false;

  // --- Timer state variables ---
  Timer? _timer;
  int _timeRemaining = 15;
  static const int _questionTimeLimit = 15;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    startTimer(); // Start the timer for the first question
  }

  @override
  void dispose() {
    _timer?.cancel(); // Ensure the timer is cancelled when the widget is removed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // --- Method to start the question timer ---
  void startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    setState(() {
      _timeRemaining = _questionTimeLimit;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          // Time is up, cancel timer and process as a wrong answer
          timer.cancel();
          processUserAnswer(false); // Assume false for unanswered questions
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      if (!backend.isFinished()) {
        _wasPaused = true;
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_wasPaused) {
        endQuizAndShowResults(interrupted: true);
        _wasPaused = false;
      }
    }
  }

  void endQuizAndShowResults({bool interrupted = false}) {
    _timer?.cancel(); // Stop the timer when the quiz ends
    int finalScore = backend.getScore();
    int iqScore = backend.calculateIQ();
    final title = interrupted ? 'Test Interrupted' : 'Test Complete';
    final message = interrupted ? 'The test was ended because you left the app.\n\n' : '';

    if (ModalRoute.of(context)?.isCurrent != true) {
      Navigator.of(context).pop();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2c3e50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Text(
              '$message'
                  'You scored $finalScore out of ${backend.getTotalQuestions()}.\n\n'
                  'Estimated IQ Score: $iqScore',
              style: const TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: const Text('RETAKE TEST', style: TextStyle(color: Color(0xFF3498db))),
              onPressed: () {
                setState(() {
                  backend.reset();
                  answerStatus = [];
                  _wasPaused = false;
                });
                Navigator.of(context).pop();
                startTimer(); // Restart timer for the new quiz
              },
            ),
          ],
        );
      },
    );
  }

  void processUserAnswer(bool userAnswer) {
    _timer?.cancel(); // Stop the timer as soon as an answer is given
    bool isCorrect = userAnswer == backend.getQuestionAnswer();
    backend.processAnswer(userAnswer);

    setState(() {
      answerStatus.add(isCorrect);
      if (backend.isFinished()) {
        endQuizAndShowResults(interrupted: false);
      } else {
        backend.nextQuestion();
        startTimer(); // Start a new timer for the next question
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // --- TOP BAR (Title and Progress) ---
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quizler IQ',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: List.generate(backend.getTotalQuestions(), (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 5,
                      decoration: BoxDecoration(
                        color: index < answerStatus.length
                            ? (answerStatus[index] ? Colors.greenAccent : Colors.redAccent)
                            : Colors.white24,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        // --- QUESTION AREA with Integrated Timer ---
        Expanded(
          flex: 3,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(25.0),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            backend.getQuestionText(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24.0,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                                height: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // --- NEW: Integrated Linear Timer ---
                      Row(
                        children: [
                          Text(
                            '${_timeRemaining}s',
                            style: TextStyle(
                              color: _timeRemaining > 5 ? Colors.white70 : Colors.redAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: _timeRemaining / _questionTimeLimit,
                                minHeight: 10,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    _timeRemaining > 5 ? Colors.lightBlueAccent : Colors.redAccent),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // --- BUTTONS AREA: Takes up 2 parts of the available space ---
        Expanded(
          flex: 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAnswerButton(
                  text: 'True', onPressed: () => processUserAnswer(true)),
              _buildAnswerButton(
                  text: 'False', onPressed: () => processUserAnswer(false)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerButton({required String text, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 140,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF1D2671),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            const BoxShadow(
                color: Colors.black54,
                offset: Offset(5, 5),
                blurRadius: 15,
                spreadRadius: 1),
            BoxShadow(
                color: Colors.white.withOpacity(0.1),
                offset: const Offset(-5, -5),
                blurRadius: 15,
                spreadRadius: 1),
          ],
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22.0,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}


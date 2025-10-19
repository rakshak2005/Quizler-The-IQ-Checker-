import 'questions.dart';

class Backend {
  int _questionNumber = 0;
  int _score = 0; // To track the number of correct answers

  final List<Question> _questionBank = [
    Question('A is the father of B. But B is not the son of A. This is possible.', true), // B is the daughter
    Question('If you rearrange the letters "CIFAIPC", you would have the name of an Ocean.', true), // PACIFIC
    Question('A farmer has 17 sheep. All but 9 die. He has 9 sheep left.', true),
    Question('Divide 30 by 1/2 and add 10. The result is 70.', true), // 30 / 0.5 = 60; 60 + 10 = 70
    Question('A doctor gives you 3 pills to take one every half hour. You will run out in 1.5 hours.', false), // 0, 30, 60 mins = 1 hour total
    Question('Which word does not belong: Apple, Banana, Rose, Orange? The word is Rose.', true), // Flower vs Fruits
    Question("A man looks at a portrait and says, 'Brothers and sisters I have none, but that man's father is my father's son.' He is looking at his son's portrait.", true),
    Question('A plane crashes on the border of the USA and Canada. Survivors are buried in Canada.', false), // You don't bury survivors
    Question("Mary's father has five daughters: Nana, Nene, Nini, Nono. The fifth daughter's name is Mary.", true),
    Question("Forward I am heavy, but backward I am not. What am I? The answer is 'ton'.", true),
    Question("What is the next number in the series: 1, 4, 9, 16, 25, ...? The next number is 36.", true), // Square numbers
    Question("A man in a house with four sides, all facing south, sees a bear. The bear must be white.", true), // It's the North Pole
    Question("How many months have 28 days? All 12 of them.", true),
    Question("If there are 6 apples and you take away 4, you have 4 apples.", true), // You took 4, so you have 4
    Question("What occurs once in a minute, twice in a moment, but never in a thousand years? The letter 'M'.", true),
  ];

  // This method now also handles scoring
  void processAnswer(bool userAnswer) {
    if (userAnswer == _questionBank[_questionNumber].questionAnswer) {
      _score++;
    }
  }

  void nextQuestion() {
    if (_questionNumber < _questionBank.length - 1) {
      _questionNumber++;
    }
  }

  String getQuestionText() {
    return _questionBank[_questionNumber].questionText;
  }

  bool getQuestionAnswer() {
    return _questionBank[_questionNumber].questionAnswer;
  }

  int getQuestionIndex() {
    return _questionNumber;
  }

  int getTotalQuestions() {
    return _questionBank.length;
  }

  // New method to get the current score
  int getScore() {
    return _score;
  }

  // New method to calculate a simulated IQ score
  int calculateIQ() {
    if (getTotalQuestions() == 0) return 100; // Avoid division by zero
    double percentage = _score / getTotalQuestions();
    // This formula maps a 0% score to an IQ of 80 and a 100% score to 160.
    int iq = (80 + (percentage * 80)).round();
    return iq;
  }

  bool isFinished() {
    return _questionNumber >= _questionBank.length - 1;
  }

  void reset() {
    _questionNumber = 0;
    _score = 0; // Reset the score as well
  }
}


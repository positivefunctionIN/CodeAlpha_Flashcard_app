import 'package:flutter/foundation.dart';
import '../models/flashcard.dart';

class FlashcardProvider extends ChangeNotifier {


  List<Flashcard> _cards = [
    // Some starter cards so your app isn't empty on first run
    Flashcard(id: '1', question: 'What is Flutter?', answer: 'A UI toolkit by Google for building cross-platform apps'),
    Flashcard(id: '2', question: 'What language does Flutter use?', answer: 'Dart'),
    Flashcard(id: '3', question: 'What is a Widget?', answer: 'The basic building block of Flutter UI'),
  ];

  int _currentIndex = 0;
  bool _isAnswerVisible = false;

  List<Flashcard> get cards => _cards;
  int get currentIndex => _currentIndex;
  bool get isAnswerVisible => _isAnswerVisible;

Flashcard? get currentCard => _cards.isEmpty ? null : _cards[_currentIndex];

int get totalCards => _cards.length;

void nextCard() {
if (_cards.isEmpty) return;
_currentIndex = (_currentIndex + 1) % _cards.length; // loops back to 0
_isAnswerVisible = false; // hide answer when moving to next card
notifyListeners(); // tells all widgets listening to rebuild
}

void previousCard() {
if (_cards.isEmpty) return;
_currentIndex = (_currentIndex - 1 + _cards.length) % _cards.length;
_isAnswerVisible = false;
notifyListeners();
}

void toggleAnswer() {
_isAnswerVisible = !_isAnswerVisible;
notifyListeners();
}

  void addCard(String question, String answer) {
    final newCard = Flashcard(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // unique id using timestamp
      question: question,
      answer: answer,
    );
    _cards.add(newCard);
    notifyListeners();
  }

  void editCard(String id, String newQuestion, String newAnswer) {
    final index = _cards.indexWhere((card) => card.id == id);
    if (index != -1) {
      _cards[index] = Flashcard(id: id, question: newQuestion, answer: newAnswer);
      notifyListeners();
    }
  }

  void deleteCard(String id) {
    _cards.removeWhere((card) => card.id == id);
    // Make sure currentIndex doesn't go out of bounds after deletion
    if (_currentIndex >= _cards.length && _currentIndex > 0) {
      _currentIndex = _cards.length - 1;
    }
    notifyListeners();
  }
}
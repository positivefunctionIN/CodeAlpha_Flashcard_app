import 'package:flutter/foundation.dart';
import '../models/flashcard.dart';

class FlashcardProvider extends ChangeNotifier {


  List<Flashcard> _cards = [
    // Some starter cards so your app isn't empty on first run
    Flashcard(id: '1', question: 'What is Flutter?', answer: 'A UI toolkit by Google for building cross-platform apps'),
    Flashcard(id: '2', question: 'What language does Flutter use?', answer: 'Dart'),
    Flashcard(id: '3', question: 'What is a Widget?', answer: 'The basic building block of Flutter UI'),
  ];


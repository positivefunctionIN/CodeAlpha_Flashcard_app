class Flashcard {
  final String id;
  final String question;
  final String answer;

  // Constructor — 'required' means you MUST pass these when creating a Flashcard
  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
  });

  // Converts a Flashcard object → Map (needed to save to storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
    };
  }

  // Converts a Map → Flashcard object (needed to load from storage)
  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
    );
  }
}
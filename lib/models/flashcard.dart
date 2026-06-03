class Flashcard {
  final String id;
  final String question;
  final String answer;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
    };
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
    );
  }
}
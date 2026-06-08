import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/flashcard_provider.dart';
import 'manage_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FlashcardProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Flashcard Quiz'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              IconButton(
                icon: const Icon(Icons.menu_book),
                tooltip: 'Manage Cards',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ManageScreen()),
                  );
                },
              ),
            ],
          ),
          body: provider.cards.isEmpty
              ? _buildEmptyState(context)
              : _buildQuizView(context, provider),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.style_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No flashcards yet!', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Tap the book icon to add cards'),
        ],
      ),
    );
  }

  Widget _buildQuizView(BuildContext context, FlashcardProvider provider) {
    final card = provider.currentCard!;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text('Card ${provider.currentIndex + 1} of ${provider.totalCards}'),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: (provider.currentIndex + 1) / provider.totalCards),
          const SizedBox(height: 32),
          Expanded(
            child: GestureDetector(
              onTap: provider.toggleAnswer,
              child: Card(
                child: Center(
                  child: Text(
                    provider.isAnswerVisible ? card.answer : card.question,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: provider.previousCard, child: const Text('Prev')),
              ElevatedButton(onPressed: provider.toggleAnswer, child: Text(provider.isAnswerVisible ? 'Hide Answer' : 'Show Answer')),
              ElevatedButton(onPressed: provider.nextCard, child: const Text('Next')),
            ],
          ),
        ],
      ),
    );
  }
}

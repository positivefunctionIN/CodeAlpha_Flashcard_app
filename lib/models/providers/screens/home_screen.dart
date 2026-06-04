import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import 'manage_screen.dart';

class HomeScreen extends StatelessWidget {
const HomeScreen({super.key});

@override
Widget build(BuildContext context) {
// Consumer listens to FlashcardProvider — rebuilds whenever notifyListeners() is called
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
// Navigate to the manage screen
Navigator.push(
context,
MaterialPageRoute(builder: (_) => const ManageScreen()),
);
},
),
],
),
body: provider.cards.isEmpty
? _buildEmptyState(context, provider)  // show this if no cards
: _buildQuizView(context, provider),   // show this if cards exist
);
},
);
}

Widget _buildEmptyState(BuildContext context, FlashcardProvider provider) {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.style_outlined, size: 80, color: Colors.grey[400]),
const SizedBox(height: 16),
Text(
'No flashcards yet!',
style: Theme.of(context).textTheme.headlineSmall,
),
const SizedBox(height: 8),
const Text('Tap the menu icon above to add cards'),
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
// Progress indicator  e.g. "Card 2 of 5"
Text(
'Card ${provider.currentIndex + 1} of ${provider.totalCards}',
style: Theme.of(context).textTheme.bodyMedium?.copyWith(
color: Colors.grey[600],
),
),
const SizedBox(height: 8),
LinearProgressIndicator(
value: (provider.currentIndex + 1) / provider.totalCards,
backgroundColor: Colors.grey[200],
),
const SizedBox(height: 32),

Expanded(
child: GestureDetector(
onTap: provider.toggleAnswer, // tap the card to flip it
child: AnimatedSwitcher(
duration: const Duration(milliseconds: 300),
child: Container(
key: ValueKey(provider.isAnswerVisible), // key tells Flutter this is a new widget
width: double.infinity,
decoration: BoxDecoration(
color: provider.isAnswerVisible
? Colors.indigo[50]   // light blue when showing answer
: Colors.white,
borderRadius: BorderRadius.circular(20),
border: Border.all(
color: provider.isAnswerVisible
? Colors.indigo
: Colors.grey[300]!,
width: 2,
),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.08),
blurRadius: 12,
offset: const Offset(0, 4),
),
],
),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
// Label at the top of the card
Text(
provider.isAnswerVisible ? 'ANSWER' : 'QUESTION',
style: TextStyle(
fontSize: 12,
fontWeight: FontWeight.bold,
letterSpacing: 2,
color: provider.isAnswerVisible
? Colors.indigo
: Colors.grey[500],
),
),
const SizedBox(height: 20),
// The actual question or answer text
Padding(
padding: const EdgeInsets.symmetric(horizontal: 24),
child: Text(
provider.isAnswerVisible ? card.answer : card.question,
textAlign: TextAlign.center,
style: Theme.of(context).textTheme.titleLarge,
),
),
const SizedBox(height: 24),
// Hint shown only on question side
if (!provider.isAnswerVisible)
Text(
'Tap to reveal answer',
style: TextStyle(
color: Colors.grey[400],
fontSize: 13,
),
),
],
),
),
),
),
),

const SizedBox(height: 24),

if (!provider.isAnswerVisible)
SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: provider.toggleAnswer,
style: ElevatedButton.styleFrom(
padding: const EdgeInsets.symmetric(vertical: 16),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
),
child: const Text('Show Answer', fontSize: 16),
),
),

const SizedBox(height: 16),

  Row(
    children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: provider.previousCard,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Previous'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: FilledButton.icon(
          onPressed: provider.nextCard,
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Next'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    ],
  ),
  const SizedBox(height: 16),
],
),
);
}
}
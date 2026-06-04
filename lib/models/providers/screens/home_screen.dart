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
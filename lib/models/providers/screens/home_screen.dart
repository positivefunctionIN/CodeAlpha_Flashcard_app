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
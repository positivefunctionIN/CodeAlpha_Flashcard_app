import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/flashcard_provider.dart';
import 'add_edit_screen.dart';

class ManageScreen extends StatelessWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FlashcardProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Manage Cards'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditScreen()),
              );
            },
            child: const Icon(Icons.add),
          ),
          body: provider.cards.isEmpty
              ? const Center(child: Text('No cards yet. Tap + to add one!'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.cards.length,
                  itemBuilder: (context, index) {
                    final card = provider.cards[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          card.question,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            card.answer,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              color: Colors.indigo,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditScreen(cardToEdit: card),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                              onPressed: () => _confirmDelete(context, provider, card.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, FlashcardProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete card?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.deleteCard(id);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

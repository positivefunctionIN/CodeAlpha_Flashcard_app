import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard.dart';
import '../providers/flashcard_provider.dart';

class AddEditScreen extends StatefulWidget {
  // cardToEdit is null when adding, has a value when editing
  final Flashcard? cardToEdit;

  const AddEditScreen({super.key, this.cardToEdit});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

// StatefulWidget is used here because the form has local state (text controllers)
class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>(); // used to validate the form
  late TextEditingController _questionController;
  late TextEditingController _answerController;

  bool get _isEditing => widget.cardToEdit != null;

  @override
  void initState() {
    super.initState();
    // Pre-fill the fields if we're editing an existing card
    _questionController = TextEditingController(
      text: _isEditing ? widget.cardToEdit!.question : '',
    );
    _answerController = TextEditingController(
      text: _isEditing ? widget.cardToEdit!.answer : '',
    );
  }

  @override
  void dispose() {
    // Always dispose controllers to free memory
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _saveCard() {
    // validate() runs all the validator functions in the form
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<FlashcardProvider>();

    if (_isEditing) {
      provider.editCard(
        widget.cardToEdit!.id,
        _questionController.text.trim(),
        _answerController.text.trim(),
      );
    } else {
      provider.addCard(
        _questionController.text.trim(),
        _answerController.text.trim(),
      );
    }

    Navigator.pop(context); // go back after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Card' : 'Add New Card'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView( // prevents overflow when keyboard opens
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _questionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter your question here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a question'; // shown below the field
                  }
                  return null; // null means valid
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Answer',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _answerController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter the answer here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an answer';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveCard,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Save Changes' : 'Add Card',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
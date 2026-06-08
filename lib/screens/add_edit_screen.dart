import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/flashcard_provider.dart';
import '../models/flashcard.dart';

class AddEditScreen extends StatefulWidget {
  final Flashcard? cardToEdit;

  const AddEditScreen({super.key, this.cardToEdit});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _answerController;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.cardToEdit?.question ?? '');
    _answerController = TextEditingController(text: widget.cardToEdit?.answer ?? '');
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<FlashcardProvider>(context, listen: false);
      if (widget.cardToEdit == null) {
        provider.addCard(_questionController.text, _answerController.text);
      } else {
        provider.editCard(widget.cardToEdit!.id, _questionController.text, _answerController.text);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.cardToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Card' : 'Add New Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Question', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a question' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(labelText: 'Answer', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Please enter an answer' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(isEditing ? 'Save Changes' : 'Add Card'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

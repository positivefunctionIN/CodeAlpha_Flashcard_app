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
        provider.addCard(_questionController.text.trim(), _answerController.text.trim());
      } else {
        provider.editCard(widget.cardToEdit!.id, _questionController.text.trim(), _answerController.text.trim());
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.cardToEdit != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Card' : 'Add New Card',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0F0E17),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'QUESTION',
                style: TextStyle(
                  color: Color(0xFF6C63FF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _questionController,
                hint: 'Enter your question...',
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              const Text(
                'ANSWER',
                style: TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _answerController,
                hint: 'Enter the answer...',
                maxLines: 4,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isEditing ? 'Save Changes' : 'Add Card',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: const Color(0xFF1E1D2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(20),
      ),
      validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
    );
  }
}

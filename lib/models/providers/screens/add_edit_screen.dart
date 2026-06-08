import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard.dart';
import '../providers/flashcard_provider.dart';

class AddEditScreen extends StatefulWidget {
  // cardToEdit is null when adding, has a value when editing
  final Flashcard? cardToEdit;

  const AddEditScreen({super.key, this.cardToEdit});


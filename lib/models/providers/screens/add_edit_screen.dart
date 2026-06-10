import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/flashcard.dart';
import '../providers/flashcard_provider.dart';

class AddEditScreen extends StatefulWidget {
  final Flashcard? cardToEdit;
  const AddEditScreen({super.key, this.cardToEdit});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen>
    with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _qCtrl, _aCtrl;
  late AnimationController _enterCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool get _isEditing => widget.cardToEdit != null;

  static const _bg      = Color(0xFF070714);
  static const _surface = Color(0xFF10101F);
  static const _cyan    = Color(0xFF00F5FF);
  static const _magenta = Color(0xFFFF2D78);
  static const _yellow  = Color(0xFFFFE033);

  @override
  void initState() {
    super.initState();
    _qCtrl = TextEditingController(text: widget.cardToEdit?.question ?? '');
    _aCtrl = TextEditingController(text: widget.cardToEdit?.answer ?? '');

    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
        begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));
    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _qCtrl.dispose();
    _aCtrl.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    final p = context.read<FlashcardProvider>();
    if (_isEditing) {
      p.editCard(widget.cardToEdit!.id, _qCtrl.text.trim(), _aCtrl.text.trim());
    } else {
      p.addCard(_qCtrl.text.trim(), _aCtrl.text.trim());
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Live preview card
                          _buildPreview(),
                          const SizedBox(height: 32),
                          _buildFieldLabel('Question', _cyan, Icons.help_outline_rounded),
                          const SizedBox(height: 10),
                          _buildField(
                            controller: _qCtrl,
                            hint: 'What do you want to remember?',
                            accent: _cyan,
                            validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Add a question' : null,
                          ),
                          const SizedBox(height: 24),
                          _buildFieldLabel('Answer', _magenta, Icons.lightbulb_outline_rounded),
                          const SizedBox(height: 10),
                          _buildField(
                            controller: _aCtrl,
                            hint: 'The answer to remember...',
                            accent: _magenta,
                            validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Add an answer' : null,
                          ),
                          const SizedBox(height: 36),
                          _buildSaveButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white54, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            _isEditing ? 'Edit Card' : 'New Card',
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  // Live preview updates as user types
  Widget _buildPreview() {
    return AnimatedBuilder(
      animation: Listenable.merge([_qCtrl, _aCtrl]),
      builder: (_, __) {
        final q = _qCtrl.text.isEmpty ? 'Your question appears here...' : _qCtrl.text;
        final a = _aCtrl.text.isEmpty ? 'Your answer appears here...' : _aCtrl.text;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: _cyan),
                ),
                const SizedBox(width: 8),
                Text('Preview',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 11, fontWeight: FontWeight.w700,
                        letterSpacing: 1.5)),
              ]),
              const SizedBox(height: 16),
              // Q side mini preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _cyan.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _cyan.withOpacity(0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Q', style: TextStyle(
                        color: _cyan.withOpacity(0.6), fontSize: 10,
                        fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(q,
                          style: TextStyle(
                              color: _qCtrl.text.isEmpty
                                  ? Colors.white24
                                  : Colors.white70,
                              fontSize: 13, height: 1.4)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // A side mini preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _magenta.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _magenta.withOpacity(0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('A', style: TextStyle(
                        color: _magenta.withOpacity(0.6), fontSize: 10,
                        fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(a,
                          style: TextStyle(
                              color: _aCtrl.text.isEmpty
                                  ? Colors.white24
                                  : Colors.white70,
                              fontSize: 13, height: 1.4)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFieldLabel(String label, Color color, IconData icon) {
    return Row(children: [
      Icon(icon, color: color, size: 15),
      const SizedBox(width: 7),
      Text(label,
          style: TextStyle(
              color: color, fontSize: 13,
              fontWeight: FontWeight.w700, letterSpacing: 0.5)),
    ]);
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required Color accent,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 14),
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent.withOpacity(0.6), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _magenta, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _magenta, width: 1.5),
        ),
        errorStyle: const TextStyle(color: _magenta, fontSize: 12),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _save,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [_cyan, Color(0xFF0088FF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
                color: _cyan.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Center(
          child: Text(
            _isEditing ? '✓  Save Changes' : '✦  Add to Deck',
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                letterSpacing: 0.3),
          ),
        ),
      ),
    );
  }
}
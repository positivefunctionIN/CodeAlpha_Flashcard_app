import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../provider/flashcard_provider.dart';
import 'add_edit_screen.dart';

class ManageScreen extends StatelessWidget {
  const ManageScreen({super.key});

  static const _bg      = Color(0xFF0F0E17); // Updated to requested dark theme
  static const _surface = Color(0xFF10101F);
  static const _cyan    = Color(0xFF00F5FF);
  static const _magenta = Color(0xFFFF2D78);

  @override
  Widget build(BuildContext context) {
    return Consumer<FlashcardProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, provider),
                Expanded(
                  child: provider.cards.isEmpty
                      ? _buildEmpty(context)
                      : _buildList(context, provider),
                ),
              ],
            ),
          ),
          floatingActionButton: _buildFAB(context),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, FlashcardProvider p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white54, size: 14),
            ),
          ),
          const SizedBox(width: 14),
          const Text('Your Deck',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _cyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _cyan.withValues(alpha: 0.3)),
            ),
            child: Text('${p.totalCards} cards',
                style: const TextStyle(
                    color: _cyan, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, FlashcardProvider p) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: p.cards.length,
      itemBuilder: (context, i) {
        final card = p.cards[i];
        return _CardTile(
          index: i,
          question: card.question,
          answer: card.answer,
          onEdit: () => Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) => AddEditScreen(cardToEdit: card))),
          onDelete: () => _confirmDelete(context, p, card.id),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_outlined, size: 64, color: Colors.white12),
          SizedBox(height: 16),
          Text('No cards yet',
              style: TextStyle(color: Colors.white38, fontSize: 18)),
          SizedBox(height: 8),
          Text('Tap + to create your first flashcard',
              style: TextStyle(color: Colors.white24, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddEditScreen()));
      },
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
              colors: [_cyan, Color(0xFF0099FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          boxShadow: [
            BoxShadow(
                color: _cyan.withValues(alpha: 0.45),
                blurRadius: 20,
                offset: const Offset(0, 6))
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.black, size: 26),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, FlashcardProvider p, String id) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF13132A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _magenta.withValues(alpha: 0.15)),
              child: const Icon(Icons.delete_outline_rounded,
                  color: _magenta, size: 28),
            ),
            const SizedBox(height: 16),
            const Text('Delete this card?',
                style: TextStyle(color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text("You can't undo this.",
                style: TextStyle(color: Colors.white38, fontSize: 13)),
            const SizedBox(height: 28),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white.withValues(alpha: 0.06),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Center(
                        child: Text('Cancel',
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    p.deleteCard(id);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: _magenta.withValues(alpha: 0.15),
                      border: Border.all(color: _magenta.withValues(alpha: 0.5)),
                    ),
                    child: const Center(
                        child: Text('Delete',
                            style: TextStyle(
                                color: _magenta,
                                fontWeight: FontWeight.w700))),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Individual card tile ─────────────────────────────────────────────────────
class _CardTile extends StatefulWidget {
  final int index;
  final String question, answer;
  final VoidCallback onEdit, onDelete;

  const _CardTile({
    required this.index, required this.question,
    required this.answer, required this.onEdit, required this.onDelete,
  });

  @override
  State<_CardTile> createState() => _CardTileState();
}

class _CardTileState extends State<_CardTile> {
  bool _expanded = false;

  static const _cyan    = Color(0xFF00F5FF);
  static const _magenta = Color(0xFFFF2D78);
  static const _surface = Color(0xFF10101F);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _expanded ? _cyan.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.06),
          ),
          boxShadow: _expanded
              ? [BoxShadow(color: _cyan.withValues(alpha: 0.08), blurRadius: 20)]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _cyan.withValues(alpha: 0.1),
                      border: Border.all(color: _cyan.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: Text('${widget.index + 1}',
                          style: const TextStyle(
                              color: _cyan, fontSize: 11,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(widget.question,
                        maxLines: _expanded ? null : 1,
                        overflow: _expanded ? null : TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  Icon(_expanded ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white24, size: 20),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _magenta.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _magenta.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ANSWER',
                          style: TextStyle(
                              color: _magenta.withValues(alpha: 0.7),
                              fontSize: 9, fontWeight: FontWeight.w800,
                              letterSpacing: 2)),
                      const SizedBox(height: 6),
                      Text(widget.answer,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13, height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ActionChip(
                      label: 'Edit',
                      icon: Icons.edit_outlined,
                      color: _cyan,
                      onTap: widget.onEdit,
                    ),
                    const SizedBox(width: 8),
                    _ActionChip(
                      label: 'Delete',
                      icon: Icons.delete_outline_rounded,
                      color: _magenta,
                      onTap: widget.onDelete,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip(
      {required this.label, required this.icon,
        required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

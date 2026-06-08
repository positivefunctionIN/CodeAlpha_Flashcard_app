import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/flashcard_provider.dart';
import '../../../screens/manage_screen.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showingFront = true;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _handleFlip(FlashcardProvider provider) {
    if (_flipController.isAnimating) return;
    if (_showingFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() => _showingFront = !_showingFront);
    provider.toggleAnswer();
  }

  void _handleNext(FlashcardProvider provider) {
    _flipController.reset();
    setState(() => _showingFront = true);
    provider.nextCard();
  }

  void _handlePrev(FlashcardProvider provider) {
    _flipController.reset();
    setState(() => _showingFront = true);
    provider.previousCard();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FlashcardProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F0E17),
          appBar: _buildAppBar(context, provider),
          body: provider.cards.isEmpty
              ? _buildEmptyState(context, provider)
              : _buildQuizView(context, provider),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, FlashcardProvider provider) {
    return AppBar(
      backgroundColor: const Color(0xFF0F0E17),
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.style, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text(
            'FlashLearn',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1D2E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${provider.totalCards} cards',
            style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 13),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.tune_rounded, color: Colors.white70),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManageScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, FlashcardProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1D2E),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt, size: 64, color: Color(0xFF6C63FF)),
          ),
          const SizedBox(height: 24),
          const Text(
            'No cards yet',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add some flashcards to get started',
            style: TextStyle(color: Colors.white38, fontSize: 15),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Cards'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizView(BuildContext context, FlashcardProvider provider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Card ${provider.currentIndex + 1}',
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  Text(
                    'of ${provider.totalCards}',
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(provider.totalCards, (i) {
                  final isActive = i == provider.currentIndex;
                  final isPast = i < provider.currentIndex;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 4,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF6C63FF)
                            : isPast
                                ? const Color(0xFF6C63FF).withValues(alpha: 0.4)
                                : const Color(0xFF1E1D2E),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => _handleFlip(provider),
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final angle = _flipAnimation.value * math.pi;
                  final isShowingFront = angle < math.pi / 2;
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    alignment: Alignment.center,
                    child: isShowingFront
                        ? _buildCardFace(
                            label: 'QUESTION',
                            text: provider.currentCard!.question,
                            isFront: true,
                          )
                        : Transform(
                            transform: Matrix4.identity()..rotateY(math.pi),
                            alignment: Alignment.center,
                            child: _buildCardFace(
                              label: 'ANSWER',
                              text: provider.currentCard!.answer,
                              isFront: false,
                            ),
                          ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Row(
            children: [
              _NavButton(
                icon: Icons.arrow_back_ios_rounded,
                onTap: () => _handlePrev(provider),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleFlip(provider),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _showingFront
                            ? [const Color(0xFF6C63FF), const Color(0xFF9C8FFF)]
                            : [const Color(0xFFFF6B6B), const Color(0xFFFF9F43)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (_showingFront
                                  ? const Color(0xFF6C63FF)
                                  : const Color(0xFFFF6B6B))
                              .withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _showingFront ? '✦  Show Answer' : '↩  Back to Question',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _NavButton(
                icon: Icons.arrow_forward_ios_rounded,
                onTap: () => _handleNext(provider),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardFace({
    required String label,
    required String text,
    required bool isFront,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isFront ? const Color(0xFF1E1D2E) : const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isFront
              ? const Color(0xFF6C63FF).withValues(alpha: 0.3)
              : const Color(0xFFFF6B6B).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isFront ? const Color(0xFF6C63FF) : const Color(0xFFFF6B6B))
                .withValues(alpha: 0.08),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: (isFront ? const Color(0xFF6C63FF) : const Color(0xFFFF6B6B))
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (isFront
                        ? const Color(0xFF6C63FF)
                        : const Color(0xFFFF6B6B))
                    .withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isFront ? const Color(0xFF6C63FF) : const Color(0xFFFF6B6B),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Tap card to flip',
            style: TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1D2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: Colors.white60, size: 18),
      ),
    );
  }
}

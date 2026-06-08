import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../provider/flashcard_provider.dart';
import '../../../screens/manage_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {

  // ── Flip animation ──────────────────────────────────────
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;
  bool _showingFront = true;

  // ── Card entrance (slide in on next/prev) ───────────────
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  // ── Pulse glow on the card ──────────────────────────────
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // ── Burst effect when answer is revealed ────────────────
  late AnimationController _burstCtrl;
  late Animation<double> _burstAnim;

  @override
  void initState() {
    super.initState();

    _flipCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 520));
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOutBack));

    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _slideAnim = Tween<Offset>(
        begin: const Offset(1.4, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _slideCtrl.value = 1.0; // start visible

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _burstCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _burstAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _burstCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    _slideCtrl.dispose();
    _pulseCtrl.dispose();
    _burstCtrl.dispose();
    super.dispose();
  }

  // ── Actions ─────────────────────────────────────────────

  void _flip(FlashcardProvider p) {
    if (_flipCtrl.isAnimating) return;
    HapticFeedback.lightImpact();
    if (_showingFront) {
      _flipCtrl.forward();
      _burstCtrl.forward(from: 0);
    } else {
      _flipCtrl.reverse();
    }
    setState(() => _showingFront = !_showingFront);
    p.toggleAnswer();
  }

  void _navigate(FlashcardProvider p, bool forward) {
    if (_flipCtrl.isAnimating || _slideCtrl.isAnimating) return;
    HapticFeedback.selectionClick();
    _flipCtrl.reset();
    setState(() {
      _showingFront = true;
    });
    _slideAnim = Tween<Offset>(
        begin: Offset(forward ? 1.4 : -1.4, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _slideCtrl.forward(from: 0);
    
    if (forward) {
      p.nextCard();
    } else {
      p.previousCard();
    }
  }

  // ── Theme colors ─────────────────────────────────────────
  static const _bg       = Color(0xFF0F0E17);
  static const _surface  = Color(0xFF10101F);
  static const _cyan     = Color(0xFF00F5FF);
  static const _magenta  = Color(0xFFFF2D78);
  static const _yellow   = Color(0xFFFFE033);
  static const _cardFront = Color(0xFF12122A);
  static const _cardBack  = Color(0xFF1A0A1A);

  @override
  Widget build(BuildContext context) {
    return Consumer<FlashcardProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: _bg,
          body: Stack(
            children: [
              // ── Ambient background grid ──────────────────
              const _AmbientGrid(),

              // ── Main content ─────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, provider),
                    if (provider.cards.isNotEmpty) _buildProgressRail(provider),
                    const SizedBox(height: 12),
                    Expanded(
                      child: provider.cards.isEmpty
                          ? _buildEmpty(context, provider)
                          : _buildCardArea(context, provider),
                    ),
                    if (provider.cards.isNotEmpty)
                      _buildControls(context, provider),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Header ───────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, FlashcardProvider p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
      child: Row(
        children: [
          // Logo mark
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(colors: [_cyan, _magenta, _yellow, _cyan]),
              boxShadow: [BoxShadow(color: _cyan.withValues(alpha: 0.5), blurRadius: 12)],
            ),
            child: const Center(
              child: Text('F', style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('FlashLearn',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
              Text('${p.totalCards} cards loaded',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 11)),
            ],
          ),
          const Spacer(),
          // Manage button
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ManageScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: _cyan.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(20),
                color: _cyan.withValues(alpha: 0.06),
              ),
              child: Row(children: [
                const Icon(Icons.tune_rounded, color: _cyan, size: 14),
                const SizedBox(width: 6),
                const Text('Manage',
                    style: TextStyle(color: _cyan, fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress rail — segmented neon bars ──────────────────
  Widget _buildProgressRail(FlashcardProvider p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: List.generate(p.totalCards, (i) {
          final active = i == p.currentIndex;
          final done   = i < p.currentIndex;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: active ? 6 : 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: active
                    ? _cyan
                    : done
                    ? _cyan.withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.08),
                boxShadow: active
                    ? [BoxShadow(color: _cyan.withValues(alpha: 0.8), blurRadius: 8)]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Card area with flip ──────────────────────────────────
  Widget _buildCardArea(BuildContext context, FlashcardProvider p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SlideTransition(
        position: _slideAnim,
        child: GestureDetector(
          onTap: () => _flip(p),
          onHorizontalDragEnd: (d) {
            if (d.primaryVelocity == null) return;
            if (d.primaryVelocity! < -300) _navigate(p, true);
            if (d.primaryVelocity! > 300) _navigate(p, false);
          },
          child: AnimatedBuilder(
            animation: Listenable.merge([_flipAnim, _pulseAnim, _burstAnim]),
            builder: (context, _) {
              final angle = _flipAnim.value * math.pi;
              final isFront = angle < math.pi / 2;

              return Stack(
                children: [
                  // ── Burst ring on reveal ─────────────────
                  if (_burstAnim.value > 0 && _burstAnim.value < 1)
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          width: 300 + _burstAnim.value * 120,
                          height: 300 + _burstAnim.value * 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _magenta.withValues(alpha: 
                                  (1 - _burstAnim.value) * 0.6),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // ── Glow behind card ─────────────────────
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: (isFront ? _cyan : _magenta)
                                  .withValues(alpha: _pulseAnim.value * 0.25),
                              blurRadius: 60,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── The card itself ──────────────────────
                  Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0012)
                      ..rotateY(angle),
                    alignment: Alignment.center,
                    child: isFront
                        ? _CardFace(
                      label: 'QUESTION',
                      text: p.currentCard!.question,
                      index: p.currentIndex,
                      total: p.totalCards,
                      isFront: true,
                      accentColor: _cyan,
                      bgColor: _cardFront,
                    )
                        : Transform(
                      transform: Matrix4.identity()..rotateY(math.pi),
                      alignment: Alignment.center,
                      child: _CardFace(
                        label: 'ANSWER',
                        text: p.currentCard!.answer,
                        index: p.currentIndex,
                        total: p.totalCards,
                        isFront: false,
                        accentColor: _magenta,
                        bgColor: _cardBack,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Bottom controls ──────────────────────────────────────
  Widget _buildControls(BuildContext context, FlashcardProvider p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _GlassButton(
            icon: Icons.arrow_back_ios_rounded,
            onTap: () => _navigate(p, false),
            color: Colors.white38,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _flip(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: _showingFront
                        ? [_cyan.withValues(alpha: 0.15), _cyan.withValues(alpha: 0.05)]
                        : [_magenta.withValues(alpha: 0.15), _magenta.withValues(alpha: 0.05)],
                  ),
                  border: Border.all(
                    color: _showingFront ? _cyan.withValues(alpha: 0.5) : _magenta.withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_showingFront ? _cyan : _magenta).withValues(alpha: 0.2),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _showingFront ? '⚡  Reveal Answer' : '↩  Flip Back',
                    style: TextStyle(
                      color: _showingFront ? _cyan : _magenta,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _GlassButton(
            icon: Icons.arrow_forward_ios_rounded,
            onTap: () => _navigate(p, true),
            color: Colors.white38,
          ),
        ],
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────
  Widget _buildEmpty(BuildContext context, FlashcardProvider p) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, _) => Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _surface,
                border: Border.all(color: _cyan.withValues(alpha: _pulseAnim.value * 0.6), width: 2),
                boxShadow: [BoxShadow(
                    color: _cyan.withValues(alpha: _pulseAnim.value * 0.3),
                    blurRadius: 30)],
              ),
              child: const Center(
                child: Text('✦', style: TextStyle(color: Colors.white, fontSize: 40)),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text('Deck is empty',
              style: TextStyle(color: Colors.white, fontSize: 22,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Create your first card to start studying',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14)),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ManageScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(colors: [_cyan, Color(0xFF0080FF)]),
                boxShadow: [BoxShadow(
                    color: _cyan.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 6))],
              ),
              child: const Text('+ Add Cards',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card Face widget ─────────────────────────────────────────────────────────
class _CardFace extends StatelessWidget {
  final String label, text;
  final int index, total;
  final bool isFront;
  final Color accentColor, bgColor;

  const _CardFace({
    required this.label, required this.text,
    required this.index, required this.total,
    required this.isFront, required this.accentColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 360),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accentColor.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Stack(
        children: [
          // Corner decorations — circuit-board aesthetic
          Positioned(top: 16, left: 16,
              child: _CornerDot(color: accentColor)),
          Positioned(top: 16, right: 16,
              child: _CornerDot(color: accentColor)),
          Positioned(bottom: 16, left: 16,
              child: _CornerDot(color: accentColor)),
          Positioned(bottom: 16, right: 16,
              child: _CornerDot(color: accentColor)),

          // Diagonal accent line (top right)
          Positioned(
            top: 0, right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topRight: Radius.circular(28)),
              child: CustomPaint(
                size: const Size(80, 80),
                painter: _CornerLinePainter(color: accentColor),
              ),
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Label chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: accentColor.withValues(alpha: 0.1),
                    border: Border.all(color: accentColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(label,
                      style: TextStyle(
                        color: accentColor, fontSize: 10,
                        fontWeight: FontWeight.w800, letterSpacing: 3,
                      )),
                ),
                const SizedBox(height: 36),
                // The text
                Text(text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 21,
                        fontWeight: FontWeight.w600, height: 1.55,
                        letterSpacing: 0.2)),
                const SizedBox(height: 36),
                // Hint
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(isFront ? Icons.touch_app_rounded : Icons.replay_rounded,
                      color: Colors.white24, size: 13),
                  const SizedBox(width: 5),
                  Text(isFront ? 'Tap to flip · swipe to navigate'
                      : 'Tap to flip back',
                      style: const TextStyle(color: Colors.white24, fontSize: 12)),
                ]),
              ],
            ),
          ),

          // Card number badge
          Positioned(
            bottom: 20, right: 20,
            child: Text('${index + 1}/$total',
                style: TextStyle(
                    color: accentColor.withValues(alpha: 0.4),
                    fontSize: 11, fontWeight: FontWeight.w700,
                    letterSpacing: 1)),
          ),
        ],
      ),
    );
  }
}

// ── Glass nav button ─────────────────────────────────────────────────────────
class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _GlassButton({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50, height: 54,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

// ── Corner dot decoration ────────────────────────────────────────────────────
class _CornerDot extends StatelessWidget {
  final Color color;
  const _CornerDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5, height: 5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.5),
      ),
    );
  }
}

// ── Corner line painter ──────────────────────────────────────────────────────
class _CornerLinePainter extends CustomPainter {
  final Color color;
  _CornerLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Ambient background grid ──────────────────────────────────────────────────
class _AmbientGrid extends StatelessWidget {
  const _AmbientGrid();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: const _GridPainter()),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00F5FF).withValues(alpha: 0.03)
      ..strokeWidth = 0.5;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Radial glow at bottom center
    final gradient = RadialGradient(
      center: const Alignment(0, 1.2),
      radius: 0.8,
      colors: [
        const Color(0xFF6C00FF).withValues(alpha: 0.15),
        Colors.transparent,
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = gradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

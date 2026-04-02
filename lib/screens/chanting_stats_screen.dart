import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';

// Data for each slide
const _stats = [
  _Stat(
    emoji: '🙏',
    stat: '',
    headline: 'Practice Your Way',
    body: 'Tap-count your mala beads or set your own timer. Even 5 minutes of sincere chanting creates a powerful habit.',
    source: '',
  ),
  _Stat(
    emoji: '📿',
    stat: '',
    headline: 'Count Mode',
    body: 'Tap along with your mala — 11, 21, 54, or 108 repetitions. Complete at your own pace.',
    source: '',
  ),
  _Stat(
    emoji: '⏱',
    stat: '',
    headline: 'Timer Mode',
    body: 'Set 5, 10, 20 or 30 minutes. Perfect for longer prayers like the Hanuman Chalisa.',
    source: '',
  ),
  _Stat(
    emoji: '🔥',
    stat: '',
    headline: 'Build the Habit',
    body: 'Consistency matters more than duration. Even one round counts toward your streak.',
    source: '',
  ),
];

class ChantingStatsScreen extends StatefulWidget {
  final int statIndex; // 0–3
  final VoidCallback onContinue;

  const ChantingStatsScreen({
    super.key,
    required this.statIndex,
    required this.onContinue,
  });

  @override
  State<ChantingStatsScreen> createState() => _ChantingStatsScreenState();
}

class _ChantingStatsScreenState extends State<ChantingStatsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _Stat get _stat => _stats[widget.statIndex];
  bool get _isLast => widget.statIndex == 3;
  // Progress 0.30 → 0.55 across the 4 stat screens
  double get _progress => 0.30 + widget.statIndex * 0.08;

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Container(
            color: AppColors.white,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: FadeTransition(
                    opacity: fade,
                    child: SlideTransition(
                      position: slide,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    gradient: AppGradients.primaryButton,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: const Text(
                                    'YOUR PACE · YOUR PRACTICE',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                // Step dots
                                Row(
                                  children: List.generate(4, (i) => Container(
                                    width: i == widget.statIndex ? 20 : 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(left: 4),
                                    decoration: BoxDecoration(
                                      color: i == widget.statIndex
                                          ? AppColors.primary
                                          : AppColors.border,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  )),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'A few minutes or\n108 repetitions —\nyour practice, your pace',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Choose how you chant. The habit is what matters.',
                              style: AppTextStyles.bodyLarge
                                  .copyWith(color: AppColors.textMedium),
                            ),
                            const Spacer(),
                            // Big stat card
                            _buildBigStatCard(),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Statistics are drawn from peer-reviewed research. Individual results may vary.',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textPale,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: GradientButton(
                    label: _isLast ? "I'm ready — let's begin" : 'Next',
                    onPressed: widget.onContinue,
                    showArrow: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(100),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: _progress,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.textDark,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBigStatCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          // Emoji badge
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primaryBorder, width: 1.5),
            ),
            child: Center(
              child: Text(_stat.emoji,
                  style: const TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 20),
          // Stat number (only shown when non-empty)
          if (_stat.stat.isNotEmpty) ...[
            Text(
              _stat.stat,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 6),
          ],
          // Headline
          Text(
            _stat.headline,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: _stat.stat.isEmpty ? 26 : 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          // Body
          Text(
            _stat.body,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textMedium,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (_stat.source.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _stat.source,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textPale,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat {
  final String emoji;
  final String stat;
  final String headline;
  final String body;
  final String source;

  const _Stat({
    required this.emoji,
    required this.stat,
    required this.headline,
    required this.body,
    required this.source,
  });
}

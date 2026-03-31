import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';

class ChantingStatsScreen extends StatefulWidget {
  final VoidCallback onContinue;

  const ChantingStatsScreen({super.key, required this.onContinue});

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
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _stats = [
    _Stat(
      emoji: '🧠',
      stat: '31%',
      headline: 'less anxiety',
      body: 'Reduces amygdala activity — your brain\'s stress centre.',
      source: 'Int\'l Journal of Yoga, 2016',
    ),
    _Stat(
      emoji: '📉',
      stat: '23%',
      headline: 'lower cortisol',
      body: 'Measurably cuts the stress hormone with daily practice.',
      source: 'Harvard Mind-Body Medical Institute',
    ),
    _Stat(
      emoji: '⚡',
      stat: '40%',
      headline: 'more alpha waves',
      body: 'Boosts the calm-focus brain frequency in minutes.',
      source: 'Neurological research on meditative states',
    ),
    _Stat(
      emoji: '❤️',
      stat: '↑ HRV',
      headline: 'healthier heart',
      body: 'Improves heart rate variability — a key longevity marker.',
      source: 'J. of Alt. and Complementary Medicine',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Container(
            color: AppColors.white,
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Hero headline ──────────────────────────────
                          FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _controller,
                              curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    gradient: AppGradients.primaryButton,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: const Text(
                                    '10 MIN · DAILY',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Science says\n10 minutes\nchanges everything',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Research-backed benefits of daily mantra chanting',
                                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMedium),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // ── Stat cards ────────────────────────────────
                          ..._stats.asMap().entries.map((entry) {
                            final delay = 0.2 + entry.key * 0.15;
                            return _AnimatedStatCard(
                              stat: entry.value,
                              controller: _controller,
                              delayStart: delay.clamp(0.0, 0.85),
                              delayEnd: (delay + 0.3).clamp(0.0, 1.0),
                            );
                          }),
                          const SizedBox(height: 16),
                          // ── Disclaimer ─────────────────────────────────
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: GradientButton(
                      label: 'I\'m ready — let\'s begin',
                      onPressed: widget.onContinue,
                      showArrow: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: _buildProgressBar(2 / 5),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(100),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.textDark,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}

// ── Stat data model ──────────────────────────────────────────────────────────

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

// ── Animated card wrapper ────────────────────────────────────────────────────

class _AnimatedStatCard extends StatelessWidget {
  final _Stat stat;
  final AnimationController controller;
  final double delayStart;
  final double delayEnd;

  const _AnimatedStatCard({
    required this.stat,
    required this.controller,
    required this.delayStart,
    required this.delayEnd,
  });

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(
      parent: controller,
      curve: Interval(delayStart, delayEnd, curve: Curves.easeIn),
    );
    final slide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(delayStart, delayEnd, curve: Curves.easeOut),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: _StatCard(stat: stat),
        ),
      ),
    );
  }
}

// ── Individual stat card ─────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final _Stat stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          // Emoji badge — uniform style, accent only on the emoji itself
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryBorder, width: 1),
            ),
            child: Center(
              child: Text(stat.emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Big stat number + label on same line
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${stat.stat} ',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      TextSpan(
                        text: stat.headline,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat.body,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMedium,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  stat.source,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppColors.textPale,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

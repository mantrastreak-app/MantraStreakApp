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
      headline: 'Calms your neurons',
      body: 'Daily chanting reduces activity in the amygdala — the brain\'s stress centre — '
          'with studies showing up to a\u00a031%\u00a0reduction in anxiety scores.',
      source: 'International Journal of Yoga, 2016',
      color: Color(0xFFEDE9FE),
      borderColor: Color(0xFFC4B5FD),
      emojiColor: Color(0xFF7C3AED),
    ),
    _Stat(
      emoji: '📉',
      headline: 'Lowers stress hormones',
      body: 'Regular mantra practice measurably reduces cortisol — the primary stress hormone — '
          'by up to\u00a023%\u00a0with consistent daily practice.',
      source: 'Harvard Mind-Body Medical Institute',
      color: Color(0xFFFFF7ED),
      borderColor: Color(0xFFFED7AA),
      emojiColor: Color(0xFFEA580C),
    ),
    _Stat(
      emoji: '⚡',
      headline: 'Sharpens your focus',
      body: 'Just 10\u00a0minutes of mantra meditation increases alpha brain waves by up to\u00a040% '
          '— the same waves linked to calm alertness and sharper thinking.',
      source: 'Neurological research on meditative states',
      color: Color(0xFFFEFCE8),
      borderColor: Color(0xFFFDE68A),
      emojiColor: Color(0xFFD97706),
    ),
    _Stat(
      emoji: '❤️',
      headline: 'Supports your heart',
      body: 'Chanting synchronises breath and heartbeat, improving heart rate variability — '
          'one of the strongest measurable markers of long-term cardiovascular health.',
      source: 'Journal of Alternative and Complementary Medicine',
      color: Color(0xFFFFF1F2),
      borderColor: Color(0xFFFECACA),
      emojiColor: Color(0xFFDC2626),
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
  final String headline;
  final String body;
  final String source;
  final Color color;
  final Color borderColor;
  final Color emojiColor;

  const _Stat({
    required this.emoji,
    required this.headline,
    required this.body,
    required this.source,
    required this.color,
    required this.borderColor,
    required this.emojiColor,
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: stat.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: stat.borderColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: stat.borderColor, width: 1),
            ),
            child: Center(
              child: Text(stat.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.headline,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: stat.emojiColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  stat.body,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    height: 1.55,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 11, color: AppColors.textPale),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        stat.source,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.textPale,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

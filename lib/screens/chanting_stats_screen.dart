import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/gradient_button.dart';

// One idea per slide. Short headline. One line of body. That's it.
const _slides = [
  _Slide(
    emoji: '🙏',
    headline: 'Your pace.\nYour practice.',
    body: 'Chant by count or by time — whatever works for you.',
  ),
  _Slide(
    emoji: '📿',
    headline: 'Count your\nmala beads.',
    body: 'Tap 11, 21, 54 or 108 times. Complete at your own pace.',
  ),
  _Slide(
    emoji: '⏱',
    headline: 'Or set a\ntimer.',
    body: 'Perfect for longer prayers like the Hanuman Chalisa.',
  ),
  _Slide(
    emoji: '🔥',
    headline: 'One round\nbuilds a habit.',
    body: 'Consistency matters more than duration. Every chant counts.',
  ),
];

class ChantingStatsScreen extends StatefulWidget {
  final int statIndex;
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
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _Slide get _slide => _slides[widget.statIndex];
  bool get _isLast => widget.statIndex == _slides.length - 1;

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(
        parent: _controller, curve: Curves.easeIn);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _controller, curve: Curves.easeOut));

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: AppColors.white,
          child: Column(
            children: [
              Expanded(
                child: FadeTransition(
                  opacity: fade,
                  child: SlideTransition(
                    position: slide,
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Spacer(flex: 2),

                          // Big emoji — replaces logo on these screens
                          // to differentiate from screen 1 & 2 while
                          // keeping the same centered visual rhythm
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.primaryBorder,
                                  width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                _slide.emoji,
                                style: const TextStyle(fontSize: 44),
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Step dots — small, centered, subtle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _slides.length,
                              (i) => AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 300),
                                width: i == widget.statIndex ? 24 : 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 3),
                                decoration: BoxDecoration(
                                  color: i == widget.statIndex
                                      ? AppColors.primary
                                      : AppColors.border,
                                  borderRadius:
                                      BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Headline — same style as education_screen
                          Text(
                            _slide.headline,
                            style: AppTextStyles.displayMedium.copyWith(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          // One line of body — same style as
                          // education_screen subtext
                          Text(
                            _slide.body,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textMedium,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const Spacer(flex: 3),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // CTA button — same as education_screen
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
    );
  }
}

class _Slide {
  final String emoji;
  final String headline;
  final String body;

  const _Slide({
    required this.emoji,
    required this.headline,
    required this.body,
  });
}

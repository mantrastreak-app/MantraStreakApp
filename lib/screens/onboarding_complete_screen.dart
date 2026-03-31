import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class OnboardingCompleteScreen extends StatefulWidget {
  final VoidCallback onContinue;

  const OnboardingCompleteScreen({super.key, required this.onContinue});

  @override
  State<OnboardingCompleteScreen> createState() => _OnboardingCompleteScreenState();
}

class _OnboardingCompleteScreenState extends State<OnboardingCompleteScreen>
    with TickerProviderStateMixin {
  // ── Primary controller for the sequence ───────────────────────────────────
  late final AnimationController _controller;

  // Logo pulse loop (runs independently after the intro)
  late final AnimationController _pulseController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _glowRadius;
  late final Animation<double> _ring1Scale;
  late final Animation<double> _ring2Scale;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _taglineFade;
  late final Animation<double> _buttonFade;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // ── Logo enters with a bounce ──────────────────────────────────────────
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.38, curve: Curves.elasticOut)),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.25, curve: Curves.easeIn)),
    );

    // ── Ripple rings expand outward ────────────────────────────────────────
    _ring1Scale = Tween<double>(begin: 0.6, end: 1.6).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.25, 0.55, curve: Curves.easeOut)),
    );
    _ring2Scale = Tween<double>(begin: 0.6, end: 2.1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.30, 0.65, curve: Curves.easeOut)),
    );

    // Glow behind logo brightens
    _glowRadius = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.25, 0.6, curve: Curves.easeInOut)),
    );

    // ── Text fades in staggered ────────────────────────────────────────────
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.48, 0.66, curve: Curves.easeIn)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.48, 0.68, curve: Curves.easeOut)),
    );
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.62, 0.78, curve: Curves.easeIn)),
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.72, 0.86, curve: Curves.easeIn)),
    );
    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.84, 1.0, curve: Curves.easeIn)),
    );

    // ── Continuous gentle logo pulse ───────────────────────────────────────
    _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _controller.forward().whenComplete(() {
      _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 3),
              _buildLogoArea(),
              const SizedBox(height: 36),
              _buildTexts(),
              const Spacer(flex: 3),
              _buildButton(),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoArea() {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ripple ring
          AnimatedBuilder(
            animation: _ring2Scale,
            builder: (_, __) {
              final progress = _ring2Scale.value;
              final opacity = ((1.0 - (progress - 0.6) / 1.5) * 0.18).clamp(0.0, 0.18);
              return Transform.scale(
                scale: progress,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: opacity),
                      width: 1.5,
                    ),
                  ),
                ),
              );
            },
          ),
          // Inner ripple ring
          AnimatedBuilder(
            animation: _ring1Scale,
            builder: (_, __) {
              final progress = _ring1Scale.value;
              final opacity = ((1.0 - (progress - 0.6) / 1.0) * 0.28).clamp(0.0, 0.28);
              return Transform.scale(
                scale: progress,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: opacity),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
          // Glow halo
          AnimatedBuilder(
            animation: _glowRadius,
            builder: (_, __) => Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28 * _glowRadius.value),
                    blurRadius: 40 * _glowRadius.value,
                    spreadRadius: 8 * _glowRadius.value,
                  ),
                ],
              ),
            ),
          ),
          // Logo with bounce + ongoing pulse
          FadeTransition(
            opacity: _logoFade,
            child: ScaleTransition(
              scale: _logoScale,
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (_, child) => Transform.scale(scale: _pulse.value, child: child),
                child: Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    gradient: AppGradients.appIcon,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 52,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTexts() {
    return Column(
      children: [
        // "Onboarding complete" badge
        FadeTransition(
          opacity: _subtitleFade,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.primaryBorder),
            ),
            child: const Text(
              'Onboarding complete ✓',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        // Main headline
        SlideTransition(
          position: _titleSlide,
          child: FadeTransition(
            opacity: _titleFade,
            child: const Text(
              'Your journey to\npeace begins here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                height: 1.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Sub-tagline
        FadeTransition(
          opacity: _taglineFade,
          child: Text(
            'Every mantra is a step closer to your inner self.\nWe are honoured to walk this path with you.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(height: 1.6, color: AppColors.textMedium),
          ),
        ),
      ],
    );
  }

  Widget _buildButton() {
    return FadeTransition(
      opacity: _buttonFade,
      child: GradientButton(
        label: 'Begin My Journey',
        onPressed: widget.onContinue,
        showArrow: true,
      ),
    );
  }
}

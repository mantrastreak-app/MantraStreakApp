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
  late final AnimationController _controller;

  // Staggered animations
  late final Animation<double> _circleScale;
  late final Animation<double> _checkScale;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _particleFade;
  late final Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    _circleScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.elasticOut),
    );
    _checkScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.5, curve: Curves.elasticOut),
    );
    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.65, curve: Curves.easeIn),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.65, curve: Curves.easeOut),
    ));
    _subtitleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 0.78, curve: Curves.easeIn),
    );
    _particleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 0.75, curve: Curves.easeIn),
    );
    _buttonFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.78, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              _buildAnimatedIcon(),
              const SizedBox(height: 16),
              _buildParticles(),
              const SizedBox(height: 28),
              _buildTitle(),
              const SizedBox(height: 12),
              _buildSubtitle(),
              const Spacer(flex: 2),
              _buildButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return ScaleTransition(
      scale: _circleScale,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: AppGradients.primaryButton,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: Color(0x40FF6900), blurRadius: 30, offset: Offset(0, 12)),
          ],
        ),
        child: ScaleTransition(
          scale: _checkScale,
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 64),
        ),
      ),
    );
  }

  Widget _buildParticles() {
    return FadeTransition(
      opacity: _particleFade,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Particle(emoji: '✨', size: 22),
          SizedBox(width: 10),
          _Particle(emoji: '🙏', size: 28),
          SizedBox(width: 10),
          _Particle(emoji: '✨', size: 22),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return SlideTransition(
      position: _titleSlide,
      child: FadeTransition(
        opacity: _titleFade,
        child: const Text(
          'You\'re all set!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            height: 1.15,
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return FadeTransition(
      opacity: _subtitleFade,
      child: Column(
        children: [
          const Text(
            'Onboarding complete',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your spiritual journey begins now.\nMay every mantra bring you peace.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(height: 1.55),
          ),
        ],
      ),
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

class _Particle extends StatelessWidget {
  final String emoji;
  final double size;

  const _Particle({required this.emoji, required this.size});

  @override
  Widget build(BuildContext context) {
    return Text(emoji, style: TextStyle(fontSize: size));
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/app_logo.dart';
import '../widgets/gradient_button.dart';

class EducationScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const EducationScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // App logo — same as splash screen
                const AppLogo(size: 96),
                const SizedBox(height: 40),
                // Quote text
                Text(
                  'When you chant, you train your mind to choose peace over chaos.',
                  style: AppTextStyles.displayMedium.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                // Subtitle
                Text(
                  'Your daily mantra practice is more than repetition —\nit\'s a path to inner stillness.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textMedium,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 3),
                GradientButton(
                  label: 'I\'m Ready',
                  onPressed: onContinue,
                  showArrow: true,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/app_logo.dart';
import '../widgets/gradient_button.dart';

class SplashScreen extends StatelessWidget {
  final VoidCallback onGetStarted;

  const SplashScreen({super.key, required this.onGetStarted});

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
                // App logo
                const AppLogo(size: 96),
                const SizedBox(height: 24),
                // Title
                Text(
                  'Mantra Streak',
                  style: AppTextStyles.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Star rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => const Icon(
                      Icons.star,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Headline
                Text(
                  'Begin Your Spiritual\nJourney',
                  style: AppTextStyles.displayMedium.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Subtext
                Text(
                  'Daily prayers and mantras for peace\nand devotion',
                  style: AppTextStyles.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Testimonial card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.bgStart,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryBorder,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '"These daily prayers bring peace and clarity to my mind"',
                    style: AppTextStyles.quoteText,
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(flex: 3),
                // Get Started button
                GradientButton(
                  label: 'Get Started',
                  onPressed: onGetStarted,
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

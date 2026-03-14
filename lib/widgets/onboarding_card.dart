import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'gradient_button.dart';

class OnboardingCard extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String title;
  final String subtitle;
  final Widget content;
  final VoidCallback onContinue;
  final VoidCallback? onSkip;
  final bool isContinueEnabled;
  final String continueLabel;

  const OnboardingCard({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.onContinue,
    this.onSkip,
    this.isContinueEnabled = true,
    this.continueLabel = 'Continue',
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: null,
      toolbarHeight: 0,
    );
  }

  Widget buildContent(BuildContext context) {
    final progress = currentStep / totalSteps;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 50,
            offset: Offset(0, 25),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Status bar area
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress bar
                  Container(
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
                  ),
                  const SizedBox(height: 12),
                  // Skip button
                  if (onSkip != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: onSkip,
                        child: Text(
                          'Skip',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.displayMedium),
                    const SizedBox(height: 8),
                    Text(subtitle, style: AppTextStyles.bodyLarge),
                    const SizedBox(height: 24),
                    content,
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Continue button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: GradientButton(
                label: continueLabel,
                onPressed: onContinue,
                showArrow: true,
                isEnabled: isContinueEnabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

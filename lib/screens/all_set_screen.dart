import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';

class AllSetScreen extends StatelessWidget {
  final VoidCallback onContinue;
  final int daysPerWeek;
  final int deitiesSelected;

  const AllSetScreen({
    super.key,
    required this.onContinue,
    this.daysPerWeek = 1,
    this.deitiesSelected = 1,
  });

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
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSuccessIcon(),
                            const SizedBox(height: 32),
                            const Text(
                              "You're all set!",
                              style: AppTextStyles.displayMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your practice is ready. Chant at your pace, build your streak, transform your day.',
                              style: AppTextStyles.bodyLarge.copyWith(fontSize: 16, height: 1.5),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            _buildSummaryCard(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: GradientButton(
                      label: 'Start My Journey',
                      onPressed: onContinue,
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

  Widget _buildSuccessIcon() {
    return Container(
      width: 96,
      height: 96,
      decoration: const BoxDecoration(
        gradient: AppGradients.allSetIcon,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Color(0x1A000000), blurRadius: 15, offset: Offset(0, 10)),
          BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: const Icon(Icons.check, color: AppColors.white, size: 48),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgStart,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Text('Daily Reminder Set', style: AppTextStyles.labelMedium.copyWith(
                fontSize: 16,
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Text('Days: $daysPerWeek days/week', style: AppTextStyles.bodyLarge),
          const SizedBox(height: 8),
          Text('Deities: $deitiesSelected selected', style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }
}

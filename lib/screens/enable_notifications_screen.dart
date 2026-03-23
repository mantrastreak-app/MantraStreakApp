import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';

class EnableNotificationsScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const EnableNotificationsScreen({super.key, required this.onContinue});

  Future<void> _openNotificationSettings(BuildContext context) async {
    if (!kIsWeb) {
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Open your device Settings > Notifications to enable alerts.'),
          ),
        );
      }
    }
    // Navigate forward regardless — user can always enable later
    onContinue();
  }

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
                  _buildProgressBar(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Notification bell icon with gradient
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: AppGradients.primaryButton,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.notifications_active_outlined,
                              color: AppColors.white,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 36),
                          Text(
                            'I work better\nwith Reminders',
                            style: AppTextStyles.displayMedium.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Get gentle daily reminders to keep your prayer streak alive. Never miss a moment of peace.',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textMedium,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          // Benefits list
                          _buildBenefit(Icons.alarm_outlined, 'Timely prayer reminders'),
                          const SizedBox(height: 14),
                          _buildBenefit(Icons.local_fire_department_outlined, 'Streak motivation nudges'),
                          const SizedBox(height: 14),
                          _buildBenefit(Icons.spa_outlined, 'Daily mantra inspiration'),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: GradientButton(
                      label: 'Enable Notifications',
                      onPressed: () => _openNotificationSettings(context),
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

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(100),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: 0.5,
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

  Widget _buildBenefit(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';

class ReminderTimeScreen extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const ReminderTimeScreen({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  State<ReminderTimeScreen> createState() => _ReminderTimeScreenState();
}

class _ReminderTimeScreenState extends State<ReminderTimeScreen> {
  TimeOfDay _time = const TimeOfDay(hour: 6, minute: 0);

  @override
  void initState() {
    super.initState();
    // Open the picker automatically once the screen is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) => _pickTime());
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            primaryContainer: AppColors.primary,
            onPrimaryContainer: Colors.white,
            secondary: AppColors.primary,
            secondaryContainer: AppColors.primarySurface,
            onSecondaryContainer: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  String get _timeLabel {
    final h = _time.hourOfPeriod == 0 ? 12 : _time.hourOfPeriod;
    final m = _time.minute.toString().padLeft(2, '0');
    final period = _time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Container(
            color: AppColors.white,
            child: Column(
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Set your prayer time',
                          style: AppTextStyles.displayMedium),
                      const SizedBox(height: 6),
                      Text(
                        'When would you like to be reminded?',
                        style: AppTextStyles.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Tappable time display
                GestureDetector(
                  onTap: _pickTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _timeLabel,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time_rounded,
                            color: AppColors.primary, size: 28),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap to change time',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textSubtle),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: GradientButton(
                    label: 'Continue',
                    onPressed: widget.onContinue,
                    showArrow: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressBar(0.5),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: widget.onSkip,
              child: Text('Skip',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.textLight)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(100)),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
              color: AppColors.textDark,
              borderRadius: BorderRadius.circular(100)),
        ),
      ),
    );
  }
}

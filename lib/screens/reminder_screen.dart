import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';

class ReminderScreen extends StatefulWidget {
  final VoidCallback onContinue;

  const ReminderScreen({super.key, required this.onContinue});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  TimeOfDay _time = const TimeOfDay(hour: 6, minute: 0);

  static const _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  String get _timeString =>
      '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

  String get _timeLabel {
    final h = _time.hourOfPeriod == 0 ? 12 : _time.hourOfPeriod;
    final m = _time.minute.toString().padLeft(2, '0');
    final period = _time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:$m $period';
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
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Time section ---
                          const Text('Set your prayer schedule', style: AppTextStyles.displayMedium),
                          const SizedBox(height: 8),
                          const Text(
                            'Choose when and which days you want to be reminded',
                            style: AppTextStyles.bodyLarge,
                          ),
                          const SizedBox(height: 28),
                          Text('Prayer Time', style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.textMedium,
                            fontWeight: FontWeight.w600,
                          )),
                          const SizedBox(height: 16),
                          Center(child: _buildTimePicker()),
                          const SizedBox(height: 28),
                          // Divider
                          const Divider(color: AppColors.border, height: 1),
                          const SizedBox(height: 24),
                          // --- Days section ---
                          Text('Prayer Days', style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.textMedium,
                            fontWeight: FontWeight.w600,
                          )),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => context.read<AppState>().selectAllDays(),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.primaryBorderDark, width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  'Select All Days',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: const Color(0xFFCA3500),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._days.map((day) => _DayRow(
                            day: day,
                            isSelected: context.watch<AppState>().selectedDays.contains(day),
                            onTap: () => context.read<AppState>().toggleDay(day),
                          )),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: GradientButton(
                      label: 'Continue',
                      onPressed: () {
                        context.read<AppState>().setReminderTime(_timeString, _time.period == DayPeriod.am ? 'AM' : 'PM');
                        widget.onContinue();
                      },
                      showArrow: true,
                      isEnabled: context.watch<AppState>().selectedDays.isNotEmpty,
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: _buildProgressBar(0.75),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      height: 6,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(100)),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(color: AppColors.textDark, borderRadius: BorderRadius.circular(100)),
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
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
                fontSize: 44,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.access_time_rounded,
                color: AppColors.primary, size: 26),
          ],
        ),
      ),
    );
  }
}


class _DayRow extends StatelessWidget {
  final String day;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayRow({required this.day, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySurface : AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(day, style: AppTextStyles.titleSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textDark,
              )),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderDark,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: AppColors.white, size: 14)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


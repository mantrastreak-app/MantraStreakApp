import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';

class PrayerDaysScreen extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const PrayerDaysScreen({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  State<PrayerDaysScreen> createState() => _PrayerDaysScreenState();
}

class _PrayerDaysScreenState extends State<PrayerDaysScreen> {
  final Set<String> _selectedDays = {};

  static const _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  void _selectAll() {
    setState(() => _selectedDays.addAll(_days));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Color(0x40000000), blurRadius: 50, offset: Offset(0, 25)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Choose your prayer days', style: AppTextStyles.displayMedium),
                          const SizedBox(height: 8),
                          Text(
                            'Select which days you want to receive reminders',
                            style: AppTextStyles.bodyLarge,
                          ),
                          const SizedBox(height: 20),
                          // Select All button
                          GestureDetector(
                            onTap: _selectAll,
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
                          // Day list
                          ..._days.map((day) => _DayRow(
                            day: day,
                            isSelected: _selectedDays.contains(day),
                            onTap: () {
                              setState(() {
                                if (_selectedDays.contains(day)) {
                                  _selectedDays.remove(day);
                                } else {
                                  _selectedDays.add(day);
                                }
                              });
                            },
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
                      onPressed: widget.onContinue,
                      showArrow: true,
                      isEnabled: _selectedDays.isNotEmpty,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressBar(0.75),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: widget.onSkip,
              child: Text('Skip', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textLight)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      height: 6,
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

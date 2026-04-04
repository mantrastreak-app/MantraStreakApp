import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';

class AllSetScreen extends StatefulWidget {
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
  State<AllSetScreen> createState() => _AllSetScreenState();
}

class _AllSetScreenState extends State<AllSetScreen> {
  int _selectedCountTarget = 108;
  int _selectedTimerMinutes = 10;

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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 32),
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
                          _buildPracticePreference(),
                          const SizedBox(height: 24),
                          _buildSummaryCard(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: GradientButton(
                      label: 'Start My Journey',
                      onPressed: () {
                        context.read<AppState>().setDefaultPractice(
                          _selectedCountTarget,
                          _selectedTimerMinutes,
                        );
                        widget.onContinue();
                      },
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

  Widget _buildPracticePreference() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Default chanting target',
            style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textMedium, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: [11, 21, 54, 108].map((v) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedCountTarget = v),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedCountTarget == v
                        ? AppColors.primarySurface
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedCountTarget == v
                          ? AppColors.primary
                          : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text('$v',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _selectedCountTarget == v
                                ? AppColors.primary
                                : AppColors.textDark,
                          )),
                      Text('chants',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: _selectedCountTarget == v
                                ? AppColors.primary
                                : AppColors.textSubtle,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 16),
        Text('Default timer duration',
            style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textMedium, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: [5, 10, 15, 20].map((v) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedTimerMinutes = v),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedTimerMinutes == v
                        ? AppColors.primarySurface
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedTimerMinutes == v
                          ? AppColors.primary
                          : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text('$v',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _selectedTimerMinutes == v
                                ? AppColors.primary
                                : AppColors.textDark,
                          )),
                      Text('min',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: _selectedTimerMinutes == v
                                ? AppColors.primary
                                : AppColors.textSubtle,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          )).toList(),
        ),
      ],
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
          Text('Days: ${widget.daysPerWeek} days/week', style: AppTextStyles.bodyLarge),
          const SizedBox(height: 8),
          Text('Deities: ${widget.deitiesSelected} selected', style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }
}

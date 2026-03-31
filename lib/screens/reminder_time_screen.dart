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
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  int _hour = 6; // 1–12
  int _minute = 0; // 0–59
  bool _isAM = true;

  static const double _itemExtent = 56.0;
  static const double _pickerHeight = 200.0;

  @override
  void initState() {
    super.initState();
    _hourController = FixedExtentScrollController(initialItem: _hour - 1);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
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
                const SizedBox(height: 32),
                _buildPicker(),
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

  Widget _buildPicker() {
    return SizedBox(
      height: _pickerHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHourWheel(),
          _buildSeparator(),
          _buildMinuteWheel(),
          const SizedBox(width: 16),
          _buildAmPmToggle(),
        ],
      ),
    );
  }

  Widget _buildHourWheel() {
    return SizedBox(
      width: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildSelectionRect(),
          ListWheelScrollView.useDelegate(
            controller: _hourController,
            itemExtent: _itemExtent,
            perspective: 0.003,
            diameterRatio: 1.6,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) =>
                setState(() => _hour = index + 1),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: 12,
              builder: (context, index) =>
                  _buildItem((index + 1).toString().padLeft(2, '0'),
                      index == _hour - 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinuteWheel() {
    return SizedBox(
      width: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildSelectionRect(),
          ListWheelScrollView.useDelegate(
            controller: _minuteController,
            itemExtent: _itemExtent,
            perspective: 0.003,
            diameterRatio: 1.6,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) =>
                setState(() => _minute = index),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: 60,
              builder: (context, index) =>
                  _buildItem(index.toString().padLeft(2, '0'),
                      index == _minute),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionRect() {
    return Positioned(
      top: (_pickerHeight - _itemExtent) / 2,
      left: 4,
      right: 4,
      child: Container(
        height: _itemExtent,
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildItem(String label, bool selected) {
    return Center(
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: selected ? 28 : 22,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          color: selected ? AppColors.primary : AppColors.textSubtle,
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        ':',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildAmPmToggle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _AmPmButton(
            label: 'AM',
            isSelected: _isAM,
            onTap: () => setState(() => _isAM = true)),
        const SizedBox(height: 8),
        _AmPmButton(
            label: 'PM',
            isSelected: !_isAM,
            onTap: () => setState(() => _isAM = false)),
      ],
    );
  }
}

class _AmPmButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AmPmButton(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(0xFFCA3500)
                : AppColors.textSubtle,
          ),
        ),
      ),
    );
  }
}

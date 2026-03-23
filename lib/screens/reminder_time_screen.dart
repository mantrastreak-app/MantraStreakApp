import 'package:flutter/material.dart';
import 'dart:math' as math;
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
  int _hour = 6;
  int _minute = 0;
  bool _isAM = true;

  String get _timeString {
    return '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';
  }

  double get _hourAngle => (_hour % 12 + _minute / 60) / 12 * 2 * math.pi - math.pi / 2;
  double get _minuteAngle => _minute / 60 * 2 * math.pi - math.pi / 2;

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
                          Text('Set your prayer time', style: AppTextStyles.displayMedium),
                          const SizedBox(height: 8),
                          Text(
                            'When would you like to be reminded for daily prayers?',
                            style: AppTextStyles.bodyLarge,
                          ),
                          const SizedBox(height: 32),
                          Center(child: _buildClock()),
                          const SizedBox(height: 24),
                          Center(child: _buildTimeDisplay()),
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
          _buildProgressBar(0.5),
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

  Widget _buildClock() {
    return GestureDetector(
      onPanUpdate: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final center = Offset(box.size.width / 2, 280);
        final touchPos = details.globalPosition;
        final angle = math.atan2(touchPos.dy - center.dy, touchPos.dx - center.dx);
        final normalizedAngle = (angle + math.pi / 2 + 2 * math.pi) % (2 * math.pi);
        final newHour = (normalizedAngle / (2 * math.pi) * 12).round() % 12;
        setState(() => _hour = newHour == 0 ? 12 : newHour);
      },
      child: CustomPaint(
        size: const Size(260, 260),
        painter: _ClockPainter(
          hourAngle: _hourAngle,
          minuteAngle: _minuteAngle,
        ),
      ),
    );
  }

  Widget _buildTimeDisplay() {
    return Column(
      children: [
        Text(
          _timeString,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AmPmButton(label: 'AM', isSelected: _isAM, onTap: () => setState(() => _isAM = true)),
            const SizedBox(width: 8),
            _AmPmButton(label: 'PM', isSelected: !_isAM, onTap: () => setState(() => _isAM = false)),
          ],
        ),
      ],
    );
  }
}

class _AmPmButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AmPmButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isSelected ? const Color(0xFFCA3500) : AppColors.textSubtle,
          ),
        ),
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final double hourAngle;
  final double minuteAngle;

  _ClockPainter({required this.hourAngle, required this.minuteAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Clock face
    final facePaint = Paint()
      ..color = AppColors.surfaceLight
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius - 2, facePaint);
    canvas.drawCircle(center, radius - 2, borderPaint);

    // Hour markers
    final markerPaint = Paint()
      ..color = AppColors.textPale
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle = i * 2 * math.pi / 12 - math.pi / 2;
      final isHour = i % 3 == 0;
      final innerRadius = isHour ? radius * 0.82 : radius * 0.88;
      final outerRadius = radius * 0.94;

      final p1 = Offset(
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );
      canvas.drawLine(p1, p2, markerPaint);
    }

    // Hour numbers
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    const hours = ['12', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11'];
    for (int i = 0; i < 12; i++) {
      final angle = i * 2 * math.pi / 12 - math.pi / 2;
      final textRadius = radius * 0.72;
      final pos = Offset(
        center.dx + textRadius * math.cos(angle),
        center.dy + textRadius * math.sin(angle),
      );
      textPainter.text = TextSpan(
        text: hours[i],
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: AppColors.textMedium,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        pos - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Minute hand
    final minutePaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.6 * math.cos(minuteAngle),
        center.dy + radius * 0.6 * math.sin(minuteAngle),
      ),
      minutePaint,
    );

    // Hour hand
    final hourPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.45 * math.cos(hourAngle),
        center.dy + radius * 0.45 * math.sin(hourAngle),
      ),
      hourPaint,
    );

    // Center dot
    final dotPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(center, 8, dotPaint);
  }

  @override
  bool shouldRepaint(_ClockPainter oldDelegate) =>
      oldDelegate.hourAngle != hourAngle || oldDelegate.minuteAngle != minuteAngle;
}

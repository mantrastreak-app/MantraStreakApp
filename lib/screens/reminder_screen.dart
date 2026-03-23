import 'package:flutter/material.dart';
import 'dart:math' as math;
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
  // Time state
  int _hour = 6;
  int _minute = 0;
  bool _isAM = true;

  static const _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  String get _timeString =>
      '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';

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
                          // --- Time section ---
                          Text('Set your prayer schedule', style: AppTextStyles.displayMedium),
                          const SizedBox(height: 8),
                          Text(
                            'Choose when and which days you want to be reminded',
                            style: AppTextStyles.bodyLarge,
                          ),
                          const SizedBox(height: 28),
                          Text('Prayer Time', style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.textMedium,
                            fontWeight: FontWeight.w600,
                          )),
                          const SizedBox(height: 16),
                          Center(child: _buildClock()),
                          const SizedBox(height: 20),
                          Center(child: _buildTimeDisplay()),
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
                        context.read<AppState>().setReminderTime(_timeString, _isAM ? 'AM' : 'PM');
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
        size: const Size(240, 240),
        painter: _ClockPainter(hourAngle: _hourAngle, minuteAngle: _minuteAngle),
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
            fontSize: 44,
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

class _ClockPainter extends CustomPainter {
  final double hourAngle;
  final double minuteAngle;

  _ClockPainter({required this.hourAngle, required this.minuteAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final facePaint = Paint()
      ..color = AppColors.surfaceLight
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius - 2, facePaint);
    canvas.drawCircle(center, radius - 2, borderPaint);

    final markerPaint = Paint()
      ..color = AppColors.textPale
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle = i * 2 * math.pi / 12 - math.pi / 2;
      final isHour = i % 3 == 0;
      final innerRadius = isHour ? radius * 0.82 : radius * 0.88;
      final outerRadius = radius * 0.94;
      final p1 = Offset(center.dx + innerRadius * math.cos(angle), center.dy + innerRadius * math.sin(angle));
      final p2 = Offset(center.dx + outerRadius * math.cos(angle), center.dy + outerRadius * math.sin(angle));
      canvas.drawLine(p1, p2, markerPaint);
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    const hours = ['12', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11'];
    for (int i = 0; i < 12; i++) {
      final angle = i * 2 * math.pi / 12 - math.pi / 2;
      final textRadius = radius * 0.72;
      final pos = Offset(center.dx + textRadius * math.cos(angle), center.dy + textRadius * math.sin(angle));
      textPainter.text = TextSpan(
        text: hours[i],
        style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textMedium),
      );
      textPainter.layout();
      textPainter.paint(canvas, pos - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    final minutePaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx + radius * 0.6 * math.cos(minuteAngle), center.dy + radius * 0.6 * math.sin(minuteAngle)),
      minutePaint,
    );

    final hourPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx + radius * 0.45 * math.cos(hourAngle), center.dy + radius * 0.45 * math.sin(hourAngle)),
      hourPaint,
    );

    final dotPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(center, 7, dotPaint);
  }

  @override
  bool shouldRepaint(_ClockPainter old) => old.hourAngle != hourAngle || old.minuteAngle != minuteAngle;
}

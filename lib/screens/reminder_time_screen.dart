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
  bool _selectingHour = true;

  final GlobalKey _clockKey = GlobalKey();

  double get _hourAngle =>
      (_hour % 12 + _minute / 60) / 12 * 2 * math.pi - math.pi / 2;
  double get _minuteAngle => _minute / 60 * 2 * math.pi - math.pi / 2;

  /// On pan-start, decide which hand to move based on which is closer to
  /// the touch point. This means users don't need to tap HH/MM first.
  void _handlePanStart(DragStartDetails details) {
    final clockCtx = _clockKey.currentContext;
    if (clockCtx == null) return;

    final box = clockCtx.findRenderObject() as RenderBox;
    final center = box.localToGlobal(
      Offset(box.size.width / 2, box.size.height / 2),
    );
    final touch = details.globalPosition;
    final radius = box.size.width / 2;

    // Compute where each hand tip currently is
    final hourTip = Offset(
      center.dx + radius * 0.45 * math.cos(_hourAngle),
      center.dy + radius * 0.45 * math.sin(_hourAngle),
    );
    final minuteTip = Offset(
      center.dx + radius * 0.6 * math.cos(_minuteAngle),
      center.dy + radius * 0.6 * math.sin(_minuteAngle),
    );

    final dHour = (touch - hourTip).distance;
    final dMinute = (touch - minuteTip).distance;

    setState(() => _selectingHour = dHour <= dMinute);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final clockCtx = _clockKey.currentContext;
    if (clockCtx == null) return;

    final box = clockCtx.findRenderObject() as RenderBox;
    final center = box.localToGlobal(
      Offset(box.size.width / 2, box.size.height / 2),
    );
    final touch = details.globalPosition;

    final angle = math.atan2(touch.dy - center.dy, touch.dx - center.dx);
    final normalized = (angle + math.pi / 2 + 2 * math.pi) % (2 * math.pi);

    setState(() {
      if (_selectingHour) {
        final raw = (normalized / (2 * math.pi) * 12).round() % 12;
        _hour = raw == 0 ? 12 : raw;
      } else {
        _minute = (normalized / (2 * math.pi) * 60).round() % 60;
      }
    });
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
              // ── Fixed column — clock is NOT inside a scroll view so
              // drag gestures are never consumed by a scroll parent. ────────
              child: Column(
                children: [
                  _buildHeader(),
                  // Title + subtitle
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
                  const SizedBox(height: 24),
                  // ── Clock (outside scroll, drag works correctly) ─────────
                  _buildClock(),
                  const SizedBox(height: 20),
                  _buildTimeDisplay(),
                  const SizedBox(height: 6),
                  Text(
                    _selectingHour ? 'Drag to set hour' : 'Drag to set minute',
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

  Widget _buildClock() {
    return GestureDetector(
      key: _clockKey,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      child: CustomPaint(
        size: const Size(240, 240),
        painter: _ClockPainter(
          hourAngle: _hourAngle,
          minuteAngle: _minuteAngle,
          selectingHour: _selectingHour,
        ),
      ),
    );
  }

  Widget _buildTimeDisplay() {
    const baseStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: 48,
      fontWeight: FontWeight.w700,
    );

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HH — tap to switch to hour mode
            GestureDetector(
              onTap: () => setState(() => _selectingHour = true),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _selectingHour
                      ? AppColors.primarySurface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _hour.toString().padLeft(2, '0'),
                  style: baseStyle.copyWith(
                    color: _selectingHour
                        ? AppColors.primary
                        : AppColors.textDark,
                  ),
                ),
              ),
            ),
            Text(':',
                style: baseStyle.copyWith(color: AppColors.textDark)),
            // MM — tap to switch to minute mode
            GestureDetector(
              onTap: () => setState(() => _selectingHour = false),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: !_selectingHour
                      ? AppColors.primarySurface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _minute.toString().padLeft(2, '0'),
                  style: baseStyle.copyWith(
                    color: !_selectingHour
                        ? AppColors.primary
                        : AppColors.textDark,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AmPmButton(
                label: 'AM',
                isSelected: _isAM,
                onTap: () => setState(() => _isAM = true)),
            const SizedBox(width: 8),
            _AmPmButton(
                label: 'PM',
                isSelected: !_isAM,
                onTap: () => setState(() => _isAM = false)),
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

  const _AmPmButton(
      {required this.label,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
            color: isSelected
                ? const Color(0xFFCA3500)
                : AppColors.textSubtle,
          ),
        ),
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final double hourAngle;
  final double minuteAngle;
  final bool selectingHour;

  _ClockPainter({
    required this.hourAngle,
    required this.minuteAngle,
    required this.selectingHour,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Face
    canvas.drawCircle(
        center,
        radius - 2,
        Paint()
          ..color = AppColors.surfaceLight
          ..style = PaintingStyle.fill);
    canvas.drawCircle(
        center,
        radius - 2,
        Paint()
          ..color = AppColors.border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    // Tick marks
    final markerPaint = Paint()
      ..color = AppColors.textPale
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 60; i++) {
      final angle = i * 2 * math.pi / 60 - math.pi / 2;
      final isMain = i % 5 == 0;
      final inner = isMain ? radius * 0.82 : radius * 0.9;
      canvas.drawLine(
        Offset(center.dx + inner * math.cos(angle),
            center.dy + inner * math.sin(angle)),
        Offset(center.dx + radius * 0.94 * math.cos(angle),
            center.dy + radius * 0.94 * math.sin(angle)),
        markerPaint
          ..strokeWidth = isMain ? 2.0 : 1.0
          ..color = isMain ? AppColors.textPale : AppColors.border,
      );
    }

    // Hour numbers
    final tp = TextPainter(textDirection: TextDirection.ltr);
    const hrs = [
      '12', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11'
    ];
    for (int i = 0; i < 12; i++) {
      final angle = i * 2 * math.pi / 12 - math.pi / 2;
      final textRadius = radius * 0.70;
      final pos = Offset(
        center.dx + textRadius * math.cos(angle),
        center.dy + textRadius * math.sin(angle),
      );
      tp.text = TextSpan(
        text: hrs[i],
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight:
              selectingHour ? FontWeight.w600 : FontWeight.w400,
          color: selectingHour
              ? AppColors.textMedium
              : AppColors.textPale,
        ),
      );
      tp.layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    // Minute hand
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.62 * math.cos(minuteAngle),
        center.dy + radius * 0.62 * math.sin(minuteAngle),
      ),
      Paint()
        ..color = selectingHour ? AppColors.border : AppColors.primary
        ..strokeWidth = selectingHour ? 2.5 : 3.5
        ..strokeCap = StrokeCap.round,
    );

    // Hour hand
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.44 * math.cos(hourAngle),
        center.dy + radius * 0.44 * math.sin(hourAngle),
      ),
      Paint()
        ..color = selectingHour ? AppColors.primary : AppColors.border
        ..strokeWidth = selectingHour ? 4.0 : 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Centre dot
    canvas.drawCircle(center, 7, Paint()..color = AppColors.primary);
    canvas.drawCircle(
        center,
        3,
        Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_ClockPainter old) =>
      old.hourAngle != hourAngle ||
      old.minuteAngle != minuteAngle ||
      old.selectingHour != selectingHour;
}

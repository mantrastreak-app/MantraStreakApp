import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';

class MonthlyDashboardScreen extends StatefulWidget {
  final int dayStreak;
  final int bestStreak;
  final int totalDays;
  final Set<DateTime> completedDays;
  final VoidCallback onClose;

  const MonthlyDashboardScreen({
    super.key,
    this.dayStreak = 0,
    this.bestStreak = 0,
    this.totalDays = 0,
    this.completedDays = const {},
    required this.onClose,
  });

  @override
  State<MonthlyDashboardScreen> createState() => _MonthlyDashboardScreenState();
}

class _MonthlyDashboardScreenState extends State<MonthlyDashboardScreen> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthName = _getMonthName(_currentMonth.month);
    final year = _currentMonth.year;
    final completionCount = _getCompletionCount();
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final completionPercent = daysInMonth > 0
        ? (completionCount / daysInMonth * 100).round()
        : 0;

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
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          _buildStatsRow(),
                          _buildCalendarControls(monthName, year, completionCount, completionPercent),
                          _buildCalendarGrid(),
                          _buildLegend(),
                          const SizedBox(height: 24),
                        ],
                      ),
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

  int _getCompletionCount() {
    return widget.completedDays.where((d) =>
      d.year == _currentMonth.year && d.month == _currentMonth.month
    ).length;
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Journey', style: AppTextStyles.headlineMedium),
              Text('Track your prayer streak', style: AppTextStyles.bodyMedium),
            ],
          ),
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: AppColors.textSubtle, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          Expanded(child: _StatCard(
            icon: Icons.local_fire_department,
            iconColor: AppColors.primary,
            value: '${widget.dayStreak}',
            label: 'Day\nStreak',
            gradient: AppGradients.monthCard,
            borderColor: AppColors.primaryBorder,
          )),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(
            icon: Icons.emoji_events,
            iconColor: const Color(0xFFF59E0B),
            value: '${widget.bestStreak}',
            label: 'Best\nStreak',
            gradient: AppGradients.bestStreakCard,
            borderColor: const Color(0xFFFFF085),
          )),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(
            icon: Icons.trending_up,
            iconColor: const Color(0xFF3B82F6),
            value: '${widget.totalDays}',
            label: 'Total\nDays',
            gradient: AppGradients.totalDaysCard,
            borderColor: const Color(0xFFBEDBFF),
          )),
        ],
      ),
    );
  }

  Widget _buildCalendarControls(
    String monthName,
    int year,
    int completionCount,
    int completionPercent,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _previousMonth,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                  child: const Icon(Icons.chevron_left, color: AppColors.textSubtle),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('$monthName $year', style: AppTextStyles.titleMedium),
                ],
              ),
              GestureDetector(
                onTap: _nextMonth,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                  child: const Icon(Icons.chevron_right, color: AppColors.textSubtle),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Month summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppGradients.calendarHeader,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('This Month',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white70)),
                    Text('$completionCount days',
                        style: const TextStyle(
                            fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$completionPercent%',
                        style: const TextStyle(
                            fontFamily: 'Inter', fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white)),
                    const Text('Completion',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Day headers
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((d) => Expanded(
              child: Center(
                child: Text(d, style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w600, color: AppColors.textSubtle)),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0 = Sunday
    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: startWeekday + daysInMonth,
        itemBuilder: (context, index) {
          if (index < startWeekday) return const SizedBox();
          final day = index - startWeekday + 1;
          final date = DateTime(_currentMonth.year, _currentMonth.month, day);
          final isToday = date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;
          final isCompleted = widget.completedDays.any((d) =>
              d.year == date.year && d.month == date.month && d.day == date.day);
          final isFuture = date.isAfter(today);

          return _CalendarDay(
            day: day,
            isToday: isToday,
            isCompleted: isCompleted,
            isFuture: isFuture,
          );
        },
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendItem(
            color: AppColors.primary,
            gradient: AppGradients.appIcon,
            label: 'Completed',
          ),
          const SizedBox(width: 24),
          _LegendItem(
            color: AppColors.primarySurface,
            border: AppColors.primaryLight,
            label: 'Today',
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month - 1];
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Gradient gradient;
  final Color borderColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.gradient,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.headlineLarge),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isCompleted;
  final bool isFuture;

  const _CalendarDay({
    required this.day,
    required this.isToday,
    required this.isCompleted,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    BoxDecoration? decoration;

    if (isCompleted) {
      decoration = const BoxDecoration(
        gradient: AppGradients.appIcon,
        borderRadius: BorderRadius.all(Radius.circular(14)),
      );
      textColor = Colors.white;
    } else if (isToday) {
      bg = AppColors.primarySurface;
      textColor = AppColors.primaryDark;
      decoration = BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryLight, width: 1.5),
      );
    } else if (isFuture) {
      bg = AppColors.surfaceLight;
      textColor = AppColors.textPale;
      decoration = BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14));
    } else {
      bg = AppColors.surface;
      textColor = AppColors.textSubtle;
      decoration = BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14));
    }

    return Container(
      decoration: decoration,
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final Gradient? gradient;
  final Color? border;
  final String label;

  const _LegendItem({required this.color, this.gradient, this.border, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: gradient == null ? color : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(10),
            border: border != null ? Border.all(color: border!, width: 1.5) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

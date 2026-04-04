import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onLogOut;
  final VoidCallback onViewDashboard;

  const ProfileScreen({
    super.key,
    required this.onClose,
    required this.onLogOut,
    required this.onViewDashboard,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _allDeities = [
    _Deity('Ganesha', Icons.self_improvement),
    _Deity('Shiva', Icons.water_drop),
    _Deity('Vishnu', Icons.circle),
    _Deity('Lakshmi', Icons.spa),
    _Deity('Saraswati', Icons.music_note),
    _Deity('Hanuman', Icons.fitness_center),
    _Deity('Durga', Icons.shield),
    _Deity('Krishna', Icons.music_note_outlined),
  ];

  static const _allDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  late Set<String> _selectedDeities;
  late Set<String> _selectedDays;
  late TimeOfDay _reminderTime;
  bool _isAM = true;
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final state = context.read<AppState>();
      _selectedDeities = Set.from(state.selectedDeities);
      _selectedDays = Set.from(state.selectedDays);
      final parts = state.reminderTime.split(':');
      final h = int.tryParse(parts[0]) ?? 6;
      final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      _isAM = state.reminderPeriod == 'AM';
      _reminderTime = TimeOfDay(hour: h, minute: m);
      _initialized = true;
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
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
      setState(() {
        _reminderTime = picked;
        _isAM = picked.period == DayPeriod.am;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final state = context.read<AppState>();
    state.selectedDeities = _selectedDeities.toList();
    state.selectedDays = _selectedDays.toList();
    final h = _reminderTime.hour;
    final m = _reminderTime.minute;
    state.reminderTime = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    state.reminderPeriod = _isAM ? 'AM' : 'PM';
    await state.saveProfile();
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved!'),
          backgroundColor: Color(0xFF16A34A),
          duration: Duration(seconds: 2),
        ),
      );
      widget.onClose();
    }
  }

  Future<void> _logOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to log out?', style: TextStyle(fontFamily: 'Inter')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out', style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await SupabaseService.signOut();
      context.read<AppState>().clearUserData();
      widget.onLogOut();
    }
  }

  String get _timeLabel {
    final h = _reminderTime.hourOfPeriod == 0 ? 12 : _reminderTime.hourOfPeriod;
    final m = _reminderTime.minute.toString().padLeft(2, '0');
    final period = _isAM ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final email = SupabaseService.currentUser?.email ?? 'Not signed in';

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Container(
            color: AppColors.white,
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User email card
                          _buildSection(
                            icon: Icons.person_outline,
                            title: 'Account',
                            child: _buildEmailRow(email),
                          ),
                          const SizedBox(height: 24),
                          // Change password
                          _buildSection(
                            icon: Icons.lock_outline,
                            title: 'Password',
                            child: _buildChangePasswordRow(),
                          ),
                          const SizedBox(height: 24),
                          // Reminder time
                          _buildSection(
                            icon: Icons.alarm_outlined,
                            title: 'Daily Reminder Time',
                            child: _buildTimeRow(),
                          ),
                          const SizedBox(height: 24),
                          _buildDefaultPracticeSection(),
                          // Prayer days
                          _buildSection(
                            icon: Icons.calendar_today_outlined,
                            title: 'Prayer Days',
                            child: _buildDaysList(),
                          ),
                          const SizedBox(height: 24),
                          // Deity selection
                          _buildSection(
                            icon: Icons.self_improvement,
                            title: 'Deities',
                            child: _buildDeityGrid(),
                          ),
                          const SizedBox(height: 24),
                          // Monthly stats
                          _buildSection(
                            icon: Icons.bar_chart_rounded,
                            title: 'Monthly Stats',
                            child: _buildMonthlyStatsRow(),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  // Buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      children: [
                        GradientButton(
                          label: _isSaving ? 'Saving…' : 'Save Changes',
                          onPressed: _isSaving ? null : _save,
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _logOut,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFDC2626), width: 1.5),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout, color: Color(0xFFDC2626), size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Log Out',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_rounded, color: AppColors.textSubtle, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Text('Profile', style: AppTextStyles.headlineLarge.copyWith(fontSize: 22)),
        ],
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.titleSmall.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildEmailRow(String email) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.email_outlined, color: AppColors.textDisabled, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(email, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMedium)),
          ),
          const Icon(Icons.lock_outline, color: AppColors.textDisabled, size: 16),
        ],
      ),
    );
  }

  Widget _buildChangePasswordRow() {
    return GestureDetector(
      onTap: _showChangePasswordSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_reset_outlined, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Change Password',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500,
                  )),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSubtle, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _showChangePasswordSheet() async {
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureNew = true;
    bool obscureConfirm = true;
    String? error;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Change Password',
                      style: AppTextStyles.headlineLarge.copyWith(fontSize: 20)),
                  const SizedBox(height: 20),
                  // New password
                  TextField(
                    controller: newCtrl,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                      suffixIcon: GestureDetector(
                        onTap: () => setSheetState(() => obscureNew = !obscureNew),
                        child: Icon(obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textSubtle),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Confirm password
                  TextField(
                    controller: confirmCtrl,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                      suffixIcon: GestureDetector(
                        onTap: () => setSheetState(() => obscureConfirm = !obscureConfirm),
                        child: Icon(obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textSubtle),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Text(error!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13)),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final np = newCtrl.text.trim();
                        final cp = confirmCtrl.text.trim();
                        if (np.isEmpty || cp.isEmpty) {
                          setSheetState(() => error = 'Please fill in both fields.');
                          return;
                        }
                        if (np.length < 6) {
                          setSheetState(() => error = 'Password must be at least 6 characters.');
                          return;
                        }
                        if (np != cp) {
                          setSheetState(() => error = 'Passwords do not match.');
                          return;
                        }
                        try {
                          await SupabaseService.updatePassword(np);
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password updated successfully!'),
                                backgroundColor: Color(0xFF16A34A),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          setSheetState(() => error = e.toString());
                        }
                      },
                      child: const Text('Update Password',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDefaultPracticeSection() {
    final appState = context.watch<AppState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: AppColors.border),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Default Practice',
                style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600)),
            GestureDetector(
              onTap: () => _showEditPracticeSheet(appState),
              child: Text('Edit',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _PracticeChip(
              icon: Icons.touch_app_rounded,
              label: '${appState.defaultCountTarget} chants',
            ),
            const SizedBox(width: 8),
            _PracticeChip(
              icon: Icons.timer_outlined,
              label: '${appState.defaultTimerMinutes} min',
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showEditPracticeSheet(AppState appState) {
    int selectedCount = appState.defaultCountTarget;
    int selectedMinutes = appState.defaultTimerMinutes;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Default Practice',
                  style: AppTextStyles.titleMedium),
              const SizedBox(height: 4),
              Text('These become your starting point on every mantra.',
                  style: AppTextStyles.bodyMedium),
              const SizedBox(height: 24),

              Text('Count target',
                  style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(
                children: [11, 21, 54, 108].map((v) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setSheetState(() => selectedCount = v),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedCount == v
                              ? AppColors.primarySurface
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedCount == v
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
                                  color: selectedCount == v
                                      ? AppColors.primary
                                      : AppColors.textDark,
                                )),
                            Text('chants',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  color: selectedCount == v
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
              const SizedBox(height: 20),

              Text('Timer duration',
                  style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(
                children: [5, 10, 15, 20].map((v) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setSheetState(() => selectedMinutes = v),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedMinutes == v
                              ? AppColors.primarySurface
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedMinutes == v
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
                                  color: selectedMinutes == v
                                      ? AppColors.primary
                                      : AppColors.textDark,
                                )),
                            Text('min',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  color: selectedMinutes == v
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
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    appState.setDefaultPractice(
                        selectedCount, selectedMinutes);
                    appState.saveProfile();
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRow() {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryBorderDark, width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Text(
              _timeLabel,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.edit_outlined, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyStatsRow() {
    return GestureDetector(
      onTap: widget.onViewDashboard,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryBorderDark, width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.bar_chart_rounded,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Text(
              'View Monthly Dashboard',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  static const _dayAbbr = {
    'Monday': 'Mon', 'Tuesday': 'Tue', 'Wednesday': 'Wed',
    'Thursday': 'Thu', 'Friday': 'Fri', 'Saturday': 'Sat', 'Sunday': 'Sun',
  };

  Widget _buildDaysList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _selectedDays.addAll(_allDays)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryBorderDark, width: 1.5),
            ),
            child: Text('Select All', style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 13,
              color: const Color(0xFFCA3500),
              fontWeight: FontWeight.w600,
            )),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allDays.map((day) {
            final selected = _selectedDays.contains(day);
            return GestureDetector(
              onTap: () => setState(() {
                if (selected) {
                  _selectedDays.remove(day);
                } else {
                  _selectedDays.add(day);
                }
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _dayAbbr[day]!,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: 13,
                    color: selected ? AppColors.white : AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDeityGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allDeities.map((deity) {
        final selected = _selectedDeities.contains(deity.name);
        return GestureDetector(
          onTap: () => setState(() {
            if (selected) {
              _selectedDeities.remove(deity.name);
            } else {
              _selectedDeities.add(deity.name);
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(deity.icon, size: 14,
                    color: selected ? AppColors.white : AppColors.textSubtle),
                const SizedBox(width: 6),
                Text(deity.name, style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 13,
                  color: selected ? AppColors.white : AppColors.textDark,
                  fontWeight: FontWeight.w600,
                )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Deity {
  final String name;
  final IconData icon;
  const _Deity(this.name, this.icon);
}

class _PracticeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PracticeChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.primaryBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              )),
        ],
      ),
    );
  }
}

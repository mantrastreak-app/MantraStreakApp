import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';

class AppState extends ChangeNotifier {
  // Onboarding / settings
  List<String> selectedDeities = [];
  String reminderTime = '06:00';
  String reminderPeriod = 'AM';
  List<String> selectedDays = [];

  // Streak stats
  int prayerStreak = 0;
  int totalPrayerDays = 0;
  int bestStreak = 0;
  Set<DateTime> completedDays = {};

  // Current prayer session
  String? selectedMood;
  String? selectedPrayer;
  String? selectedPrayerDeity;
  int? selectedPrayerDuration;

  // Loading state for async operations
  bool isLoading = false;
  String? errorMessage;

  // -------------------------------------------------------------------------
  // Onboarding setters
  // -------------------------------------------------------------------------

  void toggleDeity(String deity) {
    if (selectedDeities.contains(deity)) {
      selectedDeities.remove(deity);
    } else {
      selectedDeities.add(deity);
    }
    notifyListeners();
  }

  void setReminderTime(String time, String period) {
    reminderTime = time;
    reminderPeriod = period;
    notifyListeners();
  }

  void toggleDay(String day) {
    if (selectedDays.contains(day)) {
      selectedDays.remove(day);
    } else {
      selectedDays.add(day);
    }
    notifyListeners();
  }

  void selectAllDays() {
    selectedDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    notifyListeners();
  }

  void setMood(String mood) {
    selectedMood = mood;
    notifyListeners();
  }

  void setPrayer(String prayer) {
    selectedPrayer = prayer;
    notifyListeners();
  }

  // -------------------------------------------------------------------------
  // Supabase: load all user data after login
  // -------------------------------------------------------------------------

  Future<void> loadUserData() async {
    if (!SupabaseService.isAuthenticated) return;
    _setLoading(true);
    try {
      await Future.wait([_loadProfile(), _loadStreaks(), _loadCompletedDays()]);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadProfile() async {
    final profile = await SupabaseService.loadProfile();
    if (profile != null) {
      selectedDeities = List<String>.from(profile['selected_deities'] ?? []);
      reminderTime = profile['reminder_time'] ?? '06:00';
      reminderPeriod = profile['reminder_period'] ?? 'AM';
      selectedDays = List<String>.from(profile['selected_days'] ?? []);
    }
  }

  Future<void> _loadStreaks() async {
    final streaks = await SupabaseService.loadStreaks();
    if (streaks != null) {
      prayerStreak = streaks['current_streak'] ?? 0;
      bestStreak = streaks['best_streak'] ?? 0;
      totalPrayerDays = streaks['total_prayer_days'] ?? 0;
    }
  }

  Future<void> _loadCompletedDays() async {
    completedDays = await SupabaseService.loadCompletedDays();
  }

  // -------------------------------------------------------------------------
  // Supabase: persist onboarding settings
  // -------------------------------------------------------------------------

  Future<void> saveProfile() async {
    if (!SupabaseService.isAuthenticated) return;
    try {
      await SupabaseService.saveProfile(
        selectedDeities: selectedDeities,
        reminderTime: reminderTime,
        reminderPeriod: reminderPeriod,
        selectedDays: selectedDays,
      );
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  // -------------------------------------------------------------------------
  // Complete a prayer session
  // -------------------------------------------------------------------------

  Future<void> completePrayer() async {
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);

    if (!completedDays.contains(dateOnly)) {
      completedDays.add(dateOnly);
      totalPrayerDays++;
      prayerStreak++;
      if (prayerStreak > bestStreak) bestStreak = prayerStreak;
      notifyListeners();

      if (SupabaseService.isAuthenticated) {
        try {
          await Future.wait([
            SupabaseService.logPrayerSession(
              completedAt: dateOnly,
              prayerTitle: selectedPrayer ?? '',
              deity: selectedPrayerDeity ?? '',
              mood: selectedMood ?? '',
              durationMinutes: selectedPrayerDuration ?? 0,
            ),
            SupabaseService.saveStreaks(
              currentStreak: prayerStreak,
              bestStreak: bestStreak,
              totalPrayerDays: totalPrayerDays,
              lastPrayerDate: dateOnly,
            ),
          ]);
        } catch (e) {
          errorMessage = e.toString();
          notifyListeners();
        }
      }
    }
  }

  bool isDayCompleted(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return completedDays.contains(dateOnly);
  }

  // -------------------------------------------------------------------------
  // Clear state on sign out
  // -------------------------------------------------------------------------

  void clearUserData() {
    selectedDeities = [];
    reminderTime = '06:00';
    reminderPeriod = 'AM';
    selectedDays = [];
    prayerStreak = 0;
    totalPrayerDays = 0;
    bestStreak = 0;
    completedDays = {};
    selectedMood = null;
    selectedPrayer = null;
    selectedPrayerDeity = null;
    selectedPrayerDuration = null;
    errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}

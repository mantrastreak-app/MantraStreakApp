import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';

class AppState extends ChangeNotifier {
  // Onboarding / settings
  List<String> selectedDeities = [];
  String reminderTime = '06:00';
  String reminderPeriod = 'AM';
  List<String> selectedDays = [];
  int defaultCountTarget = 108;
  int defaultTimerMinutes = 10;

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
  String? selectedPrayerMantraId;
  int currentSessionCount = 0;
  int currentSessionTarget = 108;
  String currentSessionMode = 'timer';

  // Pending session data — set by prayer_page_screen before calling onComplete
  int pendingSessionCount = 0;
  int pendingSessionTarget = 108;
  String pendingSessionMode = 'timer';

  // Today's chant progress — mantraId → count chanted today
  Map<String, int> todayChantCounts = {};

  // Favourite mantras (persisted locally)
  // Each entry stores just enough data to render a compact card.
  List<Map<String, dynamic>> favouriteMantraCards = [];

  bool isFavourite(String mantraId) =>
      favouriteMantraCards.any((m) => m['id'] == mantraId);

  int todayCountFor(String mantraId) => todayChantCounts[mantraId] ?? 0;

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

  // ── Favourites ────────────────────────────────────────────────────────────

  Future<void> loadFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('fav_ids') ?? [];
    final List<Map<String, dynamic>> loaded = [];
    for (final id in ids) {
      final title = prefs.getString('fav_${id}_title') ?? '';
      final deity = prefs.getString('fav_${id}_deity') ?? '';
      final transliteration = prefs.getString('fav_${id}_transliteration') ?? '';
      loaded.add({'id': id, 'title': title, 'deity': deity, 'transliteration': transliteration});
    }
    favouriteMantraCards = loaded;
    notifyListeners();
  }

  Future<void> toggleFavourite({
    required String id,
    required String title,
    required String deity,
    required String transliteration,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (isFavourite(id)) {
      favouriteMantraCards.removeWhere((m) => m['id'] == id);
      await prefs.remove('fav_${id}_title');
      await prefs.remove('fav_${id}_deity');
      await prefs.remove('fav_${id}_transliteration');
    } else {
      favouriteMantraCards.add({'id': id, 'title': title, 'deity': deity, 'transliteration': transliteration});
      await prefs.setString('fav_${id}_title', title);
      await prefs.setString('fav_${id}_deity', deity);
      await prefs.setString('fav_${id}_transliteration', transliteration);
    }
    final ids = favouriteMantraCards.map((m) => m['id'] as String).toList();
    await prefs.setStringList('fav_ids', ids);
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

  void setDefaultPractice(int countTarget, int timerMinutes) {
    defaultCountTarget = countTarget;
    defaultTimerMinutes = timerMinutes;
    notifyListeners();
  }

  // -------------------------------------------------------------------------
  // Supabase: load all user data after login
  // -------------------------------------------------------------------------

  Future<void> loadUserData() async {
    if (!SupabaseService.isAuthenticated) return;
    _setLoading(true);
    try {
      await Future.wait([_loadProfile(), _loadStreaks(), _loadCompletedDays(), loadFavourites(), _loadTodayProgress()]);
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
      defaultCountTarget = profile['default_count_target'] as int? ?? 108;
      defaultTimerMinutes = profile['default_timer_minutes'] as int? ?? 10;
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

  Future<void> _loadTodayProgress() async {
    final sessions = await SupabaseService.loadTodaysSessions();
    final Map<String, int> counts = {};
    for (final session in sessions) {
      final id = session['mantra_id'] as String? ?? '';
      final count = session['count_achieved'] as int? ?? 0;
      if (id.isNotEmpty) {
        counts[id] = (counts[id] ?? 0) + count;
      }
    }
    todayChantCounts = counts;
    notifyListeners();
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
        defaultCountTarget: defaultCountTarget,
        defaultTimerMinutes: defaultTimerMinutes,
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

    // Update in-memory today progress immediately
    final mantraId = selectedPrayerMantraId ?? '';
    if (mantraId.isNotEmpty && pendingSessionCount > 0) {
      todayChantCounts[mantraId] =
          (todayChantCounts[mantraId] ?? 0) + pendingSessionCount;
    }

    // Only count as a completed day if target was reached
    final bool sessionCompleted = pendingSessionMode == 'count'
        ? pendingSessionCount >= pendingSessionTarget
        : pendingSessionCount >= 0 && pendingSessionTarget == 0;
    // For timer mode, completion is signalled by pendingSessionTarget == 0
    // (set by _completeSession) vs pendingSessionTarget > 0 (set by _saveAndExit)

    if (sessionCompleted && !completedDays.contains(dateOnly)) {
      completedDays.add(dateOnly);
      totalPrayerDays++;
      prayerStreak++;
      if (prayerStreak > bestStreak) bestStreak = prayerStreak;
    }
    notifyListeners();

    if (SupabaseService.isAuthenticated) {
      try {
        await Future.wait([
          SupabaseService.logPrayerSession(
            completedAt: dateOnly,
            prayerTitle: selectedPrayer ?? '',
            mantraId: mantraId,
            deity: selectedPrayerDeity ?? '',
            mood: selectedMood ?? '',
            durationMinutes: selectedPrayerDuration ?? 0,
            countAchieved: pendingSessionCount,
            targetCount: pendingSessionTarget,
            sessionMode: pendingSessionMode,
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

    // Reset pending
    pendingSessionCount = 0;
    pendingSessionTarget = 108;
    pendingSessionMode = 'timer';
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
    selectedPrayerMantraId = null;
    todayChantCounts = {};
    pendingSessionCount = 0;
    pendingSessionTarget = 108;
    pendingSessionMode = 'timer';
    defaultCountTarget = 108;
    defaultTimerMinutes = 10;
    favouriteMantraCards = [];
    errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}

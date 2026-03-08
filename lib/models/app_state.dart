import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  // Onboarding state
  List<String> selectedDeities = [];
  String reminderTime = '06:00';
  String reminderPeriod = 'AM';
  List<String> selectedDays = [];
  int prayerStreak = 0;
  int totalPrayerDays = 0;
  int bestStreak = 0;
  Set<DateTime> completedDays = {};

  // Prayer session state
  String? selectedMood;
  String? selectedPrayer;

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

  void completePrayer() {
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);
    if (!completedDays.contains(dateOnly)) {
      completedDays.add(dateOnly);
      totalPrayerDays++;
      prayerStreak++;
      if (prayerStreak > bestStreak) bestStreak = prayerStreak;
      notifyListeners();
    }
  }

  bool isDayCompleted(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return completedDays.contains(dateOnly);
  }
}

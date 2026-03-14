import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/app_state.dart';
import 'services/supabase_service.dart';
import 'screens/splash_screen.dart';
import 'screens/deity_selection_screen.dart';
import 'screens/reminder_time_screen.dart';
import 'screens/prayer_days_screen.dart';
import 'screens/all_set_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/mood_selector_screen.dart';
import 'screens/prayer_selection_screen.dart';
import 'screens/prayer_page_screen.dart';
import 'screens/monthly_dashboard_screen.dart';

enum AppRoute {
  splash,
  deitySelection,
  reminderTime,
  prayerDays,
  allSet,
  login,
  home,
  moodSelector,
  prayerSelection,
  prayerPage,
  monthlyDashboard,
}

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  AppRoute _currentRoute = AppRoute.splash;
  String? _selectedMood;
  Prayer? _selectedPrayer;

  @override
  void initState() {
    super.initState();
    // If a Supabase session already exists, load user data and skip to home.
    if (SupabaseService.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await context.read<AppState>().loadUserData();
        _navigate(AppRoute.home);
      });
    }
  }

  void _navigate(AppRoute route) {
    setState(() => _currentRoute = route);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return SlideTransition(position: slideAnimation, child: child);
      },
      child: _buildCurrentScreen(state),
    );
  }

  Widget _buildCurrentScreen(AppState state) {
    switch (_currentRoute) {
      case AppRoute.splash:
        return SplashScreen(
          key: const ValueKey(AppRoute.splash),
          onGetStarted: () => _navigate(AppRoute.deitySelection),
        );

      case AppRoute.deitySelection:
        return DeitySelectionScreen(
          key: const ValueKey(AppRoute.deitySelection),
          onContinue: () => _navigate(AppRoute.reminderTime),
          onSkip: () => _navigate(AppRoute.reminderTime),
        );

      case AppRoute.reminderTime:
        return ReminderTimeScreen(
          key: const ValueKey(AppRoute.reminderTime),
          onContinue: () => _navigate(AppRoute.prayerDays),
          onSkip: () => _navigate(AppRoute.prayerDays),
        );

      case AppRoute.prayerDays:
        return PrayerDaysScreen(
          key: const ValueKey(AppRoute.prayerDays),
          onContinue: () => _navigate(AppRoute.allSet),
          onSkip: () => _navigate(AppRoute.allSet),
        );

      case AppRoute.allSet:
        return AllSetScreen(
          key: const ValueKey(AppRoute.allSet),
          onContinue: () => _navigate(AppRoute.login),
        );

      case AppRoute.login:
        return LoginScreen(
          key: const ValueKey(AppRoute.login),
          onSignIn: () => _navigate(AppRoute.home),
          onSkip: () => _navigate(AppRoute.home),
        );

      case AppRoute.home:
        return HomeScreen(
          key: const ValueKey(AppRoute.home),
          streak: state.prayerStreak,
          totalDays: state.totalPrayerDays,
          onLetsPray: () => _navigate(AppRoute.moodSelector),
          onViewDashboard: () => _navigate(AppRoute.monthlyDashboard),
        );

      case AppRoute.moodSelector:
        return MoodSelectorScreen(
          key: const ValueKey(AppRoute.moodSelector),
          onContinue: (mood) {
            setState(() => _selectedMood = mood);
            _navigate(AppRoute.prayerSelection);
          },
        );

      case AppRoute.prayerSelection:
        return PrayerSelectionScreen(
          key: const ValueKey(AppRoute.prayerSelection),
          mood: _selectedMood ?? 'Good',
          onStart: (prayer) {
            setState(() => _selectedPrayer = prayer);
            // Store prayer details in AppState for Supabase logging
            state.selectedPrayerDeity = prayer.deity;
            state.selectedPrayerDuration = prayer.durationMinutes;
            _navigate(AppRoute.prayerPage);
          },
          onBack: () => _navigate(AppRoute.moodSelector),
        );

      case AppRoute.prayerPage:
        return PrayerPageScreen(
          key: const ValueKey(AppRoute.prayerPage),
          prayer: _selectedPrayer!,
          onClose: () => _navigate(AppRoute.home),
          onComplete: () {
            state.completePrayer();
            _navigate(AppRoute.home);
          },
        );

      case AppRoute.monthlyDashboard:
        return MonthlyDashboardScreen(
          key: const ValueKey(AppRoute.monthlyDashboard),
          dayStreak: state.prayerStreak,
          bestStreak: state.bestStreak,
          totalDays: state.totalPrayerDays,
          completedDays: state.completedDays,
          onClose: () => _navigate(AppRoute.home),
        );
    }
  }
}

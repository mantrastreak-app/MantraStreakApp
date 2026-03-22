import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/app_state.dart';
import 'services/supabase_service.dart';
import 'screens/splash_screen.dart';
import 'screens/education_screen.dart';
import 'screens/login_screen.dart';
import 'screens/deity_selection_screen.dart';
import 'screens/enable_notifications_screen.dart';
import 'screens/reminder_screen.dart';
import 'screens/all_set_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/mood_selector_screen.dart';
import 'screens/prayer_selection_screen.dart';
import 'screens/prayer_page_screen.dart';
import 'screens/monthly_dashboard_screen.dart';
import 'screens/otp_verification_screen.dart';

// Onboarding: splash → education → login → otpVerification → deitySelection → enableNotifications → reminder → allSet → home
// Main app:   home ↔ profile, moodSelector → prayerSelection → prayerPage, home ↔ monthlyDashboard
enum AppRoute {
  splash,
  education,
  login,
  otpVerification,
  deitySelection,
  enableNotifications,
  reminder,
  allSet,
  home,
  profile,
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
  bool _signInMode = false; // true after logout → show sign-in, not sign-up
  String? _pendingOtpEmail;

  @override
  void initState() {
    super.initState();
    if (SupabaseService.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await context.read<AppState>().loadUserData();
        _navigate(AppRoute.home);
      });
    }
  }

  void _navigate(AppRoute route) => setState(() => _currentRoute = route);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return SlideTransition(position: slide, child: child);
      },
      child: _buildCurrentScreen(state),
    );
  }

  Widget _buildCurrentScreen(AppState state) {
    switch (_currentRoute) {
      case AppRoute.splash:
        return SplashScreen(
          key: const ValueKey(AppRoute.splash),
          onGetStarted: () => _navigate(AppRoute.education),
        );

      case AppRoute.education:
        return EducationScreen(
          key: const ValueKey(AppRoute.education),
          onContinue: () => _navigate(AppRoute.login),
        );

      case AppRoute.login:
        return LoginScreen(
          key: const ValueKey(AppRoute.login),
          startInSignUpMode: !_signInMode,
          onSignIn: () {
            _signInMode = false;
            _navigate(AppRoute.home);
          },
          onPendingOtp: (email) {
            setState(() => _pendingOtpEmail = email);
            _navigate(AppRoute.otpVerification);
          },
        );

      case AppRoute.otpVerification:
        return OtpVerificationScreen(
          key: const ValueKey(AppRoute.otpVerification),
          email: _pendingOtpEmail!,
          onVerified: () async {
            await context.read<AppState>().loadUserData();
            if (mounted) _navigate(AppRoute.deitySelection);
          },
          onBack: () => _navigate(AppRoute.login),
        );

      case AppRoute.deitySelection:
        return DeitySelectionScreen(
          key: const ValueKey(AppRoute.deitySelection),
          onContinue: () => _navigate(AppRoute.enableNotifications),
        );

      case AppRoute.enableNotifications:
        return EnableNotificationsScreen(
          key: const ValueKey(AppRoute.enableNotifications),
          onContinue: () => _navigate(AppRoute.reminder),
        );

      case AppRoute.reminder:
        return ReminderScreen(
          key: const ValueKey(AppRoute.reminder),
          onContinue: () => _navigate(AppRoute.allSet),
        );

      case AppRoute.allSet:
        return AllSetScreen(
          key: const ValueKey(AppRoute.allSet),
          onContinue: () {
            state.saveProfile();
            _navigate(AppRoute.home);
          },
          daysPerWeek: state.selectedDays.length,
          deitiesSelected: state.selectedDeities.length,
        );

      case AppRoute.home:
        return HomeScreen(
          key: const ValueKey(AppRoute.home),
          streak: state.prayerStreak,
          totalDays: state.totalPrayerDays,
          onLetsPray: () => _navigate(AppRoute.moodSelector),
          onViewDashboard: () => _navigate(AppRoute.monthlyDashboard),
          onProfile: () => _navigate(AppRoute.profile),
        );

      case AppRoute.profile:
        return ProfileScreen(
          key: const ValueKey(AppRoute.profile),
          onClose: () => _navigate(AppRoute.home),
          onLogOut: () => setState(() {
            _signInMode = true;
            _currentRoute = AppRoute.login;
          }),
        );

      case AppRoute.moodSelector:
        return MoodSelectorScreen(
          key: const ValueKey(AppRoute.moodSelector),
          onBack: () => _navigate(AppRoute.home),
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
            state.selectedPrayer = prayer.title;
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

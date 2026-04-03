import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/app_state.dart';
import 'services/supabase_service.dart';
import 'screens/splash_screen.dart';
import 'screens/education_screen.dart';
import 'screens/chanting_stats_screen.dart';
import 'screens/login_screen.dart';
import 'screens/deity_selection_screen.dart';
import 'screens/enable_notifications_screen.dart';
import 'screens/reminder_screen.dart';
import 'screens/all_set_screen.dart';
import 'screens/onboarding_complete_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/mood_selector_screen.dart';
import 'screens/prayer_selection_screen.dart';
import 'screens/prayer_page_screen.dart';
import 'screens/monthly_dashboard_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/reset_password_screen.dart';

// Onboarding: splash → education → chantingStats → login → otpVerification → deitySelection → enableNotifications → reminder → allSet → onboardingComplete → home
// Main app:   home ↔ profile, moodSelector → prayerSelection → prayerPage, home ↔ monthlyDashboard
enum AppRoute {
  splash,
  education,
  chantingStats,
  login,
  otpVerification,
  deitySelection,
  enableNotifications,
  reminder,
  allSet,
  onboardingComplete,
  home,
  profile,
  moodSelector,
  prayerSelection,
  prayerPage,
  monthlyDashboard,
  resetPassword,
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
  int _statIndex = 0; // which of the 4 chanting-stat screens to show

  // Deep link / auth state subscriptions
  StreamSubscription<Uri>? _linkSub;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();

    if (SupabaseService.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final state = context.read<AppState>();
        await Future.wait([state.loadUserData(), state.loadFavourites()]);
        if (mounted) _navigate(AppRoute.home);
      });
    }

    _initDeepLinks();
    _initAuthStateListener();
  }

  // ── Deep link handling (for Supabase password reset emails) ───────────────
  void _initDeepLinks() {
    final appLinks = AppLinks();

    // Handle link that launched the app from a cold start
    appLinks.getInitialAppLink().then((uri) {
      if (uri != null) _handleIncomingLink(uri);
    });

    // Handle links while the app is running
    _linkSub = appLinks.uriLinkStream.listen(
      _handleIncomingLink,
      onError: (_) {},
    );
  }

  Future<void> _handleIncomingLink(Uri uri) async {
    if (uri.scheme != 'com.mantrastreak.app') return;
    try {
      // supabase_flutter parses the fragment and sets the session
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
      // The auth state listener will fire with passwordRecovery
    } catch (_) {}
  }

  // ── Auth state change listener ────────────────────────────────────────────
  void _initAuthStateListener() {
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        if (mounted) _navigate(AppRoute.resetPassword);
      }
    });
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  void _navigate(AppRoute route) => setState(() => _currentRoute = route);

  Future<void> _openFavouritePrayer(String id) async {
    final row = await SupabaseService.fetchMantraById(id);
    if (row != null && mounted) {
      final prayer = Prayer.fromSupabase(row);
      final state = context.read<AppState>();
      setState(() => _selectedPrayer = prayer);
      state.selectedPrayer = prayer.title;
      state.selectedPrayerDeity = prayer.deity;
      state.selectedPrayerDuration = prayer.durationMinutes;
      _navigate(AppRoute.prayerPage);
    }
  }

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
          onContinue: () => _navigate(AppRoute.chantingStats),
        );

      case AppRoute.chantingStats:
        return ChantingStatsScreen(
          key: ValueKey('stat_$_statIndex'),
          statIndex: _statIndex,
          onContinue: () {
            if (_statIndex < 3) {
              setState(() => _statIndex++);
            } else {
              setState(() => _statIndex = 0);
              _navigate(AppRoute.login);
            }
          },
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
            _navigate(AppRoute.onboardingComplete);
          },
          daysPerWeek: state.selectedDays.length,
          deitiesSelected: state.selectedDeities.length,
        );

      case AppRoute.onboardingComplete:
        return OnboardingCompleteScreen(
          key: const ValueKey(AppRoute.onboardingComplete),
          onContinue: () => _navigate(AppRoute.home),
        );

      case AppRoute.home:
        return HomeScreen(
          key: const ValueKey(AppRoute.home),
          streak: state.prayerStreak,
          totalDays: state.totalPrayerDays,
          onViewDashboard: () {},
          onProfile: () => _navigate(AppRoute.profile),
          onFavouriteTap: (id) => _openFavouritePrayer(id),
        );

      case AppRoute.profile:
        return ProfileScreen(
          key: const ValueKey(AppRoute.profile),
          onClose: () => _navigate(AppRoute.home),
          onViewDashboard: () => _navigate(AppRoute.monthlyDashboard),
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
            state.selectedPrayerMantraId = prayer.id;
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

      case AppRoute.resetPassword:
        return ResetPasswordScreen(
          key: const ValueKey(AppRoute.resetPassword),
          onPasswordReset: () => _navigate(AppRoute.home),
        );
    }
  }
}

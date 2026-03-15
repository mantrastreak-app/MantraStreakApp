import 'package:supabase_flutter/supabase_flutter.dart';

/// Central service for all Supabase operations.
/// Handles authentication, user profiles, streaks, and prayer sessions.
class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  static User? get currentUser => _client.auth.currentUser;
  static Session? get currentSession => _client.auth.currentSession;
  static bool get isAuthenticated => currentUser != null;

  /// Stream of auth state changes.
  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  /// Sign in with email and password.
  static Future<AuthResponse> signInWithEmail(
    String email,
    String password,
  ) async {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email and password.
  static Future<AuthResponse> signUpWithEmail(
    String email,
    String password,
  ) async {
    return _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign out the current user.
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Sign in / sign up with Google OAuth (opens browser).
  static Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.mantrastreak.app://auth-callback',
    );
  }

  /// Sign in / sign up with Facebook OAuth (opens browser).
  static Future<void> signInWithFacebook() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.facebook,
      redirectTo: 'com.mantrastreak.app://auth-callback',
    );
  }

  /// Send a password reset email.
  static Future<void> sendPasswordResetEmail(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'com.mantrastreak.app://reset-password',
    );
  }

  // ---------------------------------------------------------------------------
  // Profiles (user settings)
  // ---------------------------------------------------------------------------

  /// Save or update user settings in the profiles table.
  static Future<void> saveProfile({
    required List<String> selectedDeities,
    required String reminderTime,
    required String reminderPeriod,
    required List<String> selectedDays,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) return;

    await _client.from('profiles').upsert({
      'id': userId,
      'selected_deities': selectedDeities,
      'reminder_time': reminderTime,
      'reminder_period': reminderPeriod,
      'selected_days': selectedDays,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Load user settings from the profiles table.
  /// Returns null if no profile exists yet.
  static Future<Map<String, dynamic>?> loadProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  // ---------------------------------------------------------------------------
  // Streaks
  // ---------------------------------------------------------------------------

  /// Save or update streak data for the current user.
  static Future<void> saveStreaks({
    required int currentStreak,
    required int bestStreak,
    required int totalPrayerDays,
    required DateTime? lastPrayerDate,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) return;

    await _client.from('streaks').upsert({
      'user_id': userId,
      'current_streak': currentStreak,
      'best_streak': bestStreak,
      'total_prayer_days': totalPrayerDays,
      'last_prayer_date': lastPrayerDate?.toIso8601String().substring(0, 10),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Load streak data for the current user.
  /// Returns null if no streak record exists yet.
  static Future<Map<String, dynamic>?> loadStreaks() async {
    final userId = currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('streaks')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return response;
  }

  // ---------------------------------------------------------------------------
  // Prayer Sessions
  // ---------------------------------------------------------------------------

  /// Log a completed prayer session.
  static Future<void> logPrayerSession({
    required DateTime completedAt,
    required String prayerTitle,
    required String deity,
    required String mood,
    required int durationMinutes,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) return;

    await _client.from('prayer_sessions').insert({
      'user_id': userId,
      'completed_at': completedAt.toIso8601String().substring(0, 10),
      'prayer_title': prayerTitle,
      'deity': deity,
      'mood': mood,
      'duration_minutes': durationMinutes,
    });
  }

  /// Fetch all distinct dates when the user completed a prayer.
  static Future<Set<DateTime>> loadCompletedDays() async {
    final userId = currentUser?.id;
    if (userId == null) return {};

    final response = await _client
        .from('prayer_sessions')
        .select('completed_at')
        .eq('user_id', userId);

    final Set<DateTime> days = {};
    for (final row in response as List<dynamic>) {
      final dateStr = row['completed_at'] as String?;
      if (dateStr != null) {
        final date = DateTime.tryParse(dateStr);
        if (date != null) {
          days.add(DateTime(date.year, date.month, date.day));
        }
      }
    }
    return days;
  }
}

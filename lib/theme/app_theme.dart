import 'package:flutter/material.dart';

class AppColors {
  // Primary orange brand colors
  static const Color primary = Color(0xFFFF6900);
  static const Color primaryDark = Color(0xFFF54900);
  static const Color primaryLight = Color(0xFFFF8904);
  static const Color primarySurface = Color(0xFFFFEDD4);
  static const Color primaryBorder = Color(0xFFFFD6A8);
  static const Color primaryBorderDark = Color(0xFFFFB86A);

  // Background gradients
  static const Color bgStart = Color(0xFFFFF7ED);
  static const Color bgEnd = Color(0xFFEFF6FF);

  // Text colors
  static const Color textDark = Color(0xFF1D293D);
  static const Color textMedium = Color(0xFF314158);
  static const Color textSubtle = Color(0xFF45556C);
  static const Color textLight = Color(0xFF62748E);
  static const Color textDisabled = Color(0xFF90A1B9);
  static const Color textPale = Color(0xFFCAD5E2);

  // Neutral surfaces
  static const Color white = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF1F5F9);
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFFCAD5E2);

  // Card gradient colors
  static const Color cardGradientStart = Color(0xFFFFF7ED);
  static const Color cardGradientEnd = Color(0xFFFDF2F8);

  // Deity icon backgrounds
  static const Color ganeshaIconBg = Color(0x21FFD700);
  static const Color shivaIconBg = Color(0x21E8E8E8);
  static const Color vishnuIconBg = Color(0x214169E1);
  static const Color lakshmiIconBg = Color(0x21FF69B4);
  static const Color saraswatiIconBg = Color(0x21F0E68C);
  static const Color hanumanIconBg = Color(0x21FF6347);
  static const Color durgaIconBg = Color(0x21DC143C);
  static const Color krishnaIconBg = Color(0x21466AB4);
}

class AppGradients {
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.bgStart, AppColors.white, AppColors.bgEnd],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient appIcon = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8904), Color(0xFFF54900)],
  );

  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primary, AppColors.primaryDark],
  );

  static const LinearGradient allSetIcon = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8904), Color(0xFFF6339A)],
  );

  static const LinearGradient streakCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
  );

  static const LinearGradient monthCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD4)],
  );

  static const LinearGradient bestStreakCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFEFCE8), Color(0xFFFEF9C2)],
  );

  static const LinearGradient totalDaysCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
  );

  static const LinearGradient calendarHeader = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primary, AppColors.primaryDark],
  );
}

class AppTextStyles {
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.9,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSubtle,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSubtle,
    height: 1.43,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textMedium,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSubtle,
  );

  static const TextStyle streakNumber = TextStyle(
    fontFamily: 'Inter',
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDark,
  );

  static const TextStyle quoteText = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: AppColors.textMedium,
    height: 1.5,
  );

  static const TextStyle sanskritText = TextStyle(
    fontFamily: 'Noto Sans Devanagari',
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
    height: 1.625,
  );

  static const TextStyle pronunciationText = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Color(0xFFCA3500),
    height: 1.625,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.bgStart,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTextStyles.labelLarge,
          elevation: 4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          color: AppColors.textDisabled,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

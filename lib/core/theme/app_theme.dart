import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modern Material 3 theme configuration for QuitForBit
/// Designed to look like a well-funded VC-backed startup
class AppTheme {
  // Core brand colors
  static const Color primaryBrand = Color(0xFF6366F1); // Indigo
  static const Color secondaryBrand = Color(0xFF8B5CF6); // Purple
  static const Color accentBrand = Color(0xFFF7931A); // Bitcoin Orange

  // Success/Progress colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFBE0B);
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color infoColor = Color(0xFF4ECDC4);

  // Dark theme surface colors
  static const Color darkBackground = Color(0xFF0A0B0D);
  static const Color darkSurface = Color(0xFF1A1B1E);
  static const Color darkSurfaceVariant = Color(0xFF2D2E32);
  static const Color darkOutline = Color(0xFF3F4045);

  // Light theme surface colors (for future implementation)
  static const Color lightBackground = Color(0xFFFAFBFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF5F6F7);
  static const Color lightOutline = Color(0xFFE5E7EB);

  /// Modern dark theme optimized for engagement and premium feel
  static ThemeData get darkTheme {
    const ColorScheme darkColorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: primaryBrand,
      onPrimary: Colors.white,
      secondary: secondaryBrand,
      onSecondary: Colors.white,
      tertiary: accentBrand,
      onTertiary: Colors.white,
      surface: darkSurface,
      onSurface: Colors.white,
      background: darkBackground,
      onBackground: Colors.white,
      error: errorColor,
      onError: Colors.white,
      outline: darkOutline,
      surfaceVariant: darkSurfaceVariant,
      onSurfaceVariant: Color(0xFFE0E1E6),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      fontFamily: 'SF Pro Display', // iOS-like font for premium feel

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
      ),

      // Scaffold Theme
      scaffoldBackgroundColor: darkBackground,

      // Card Theme
      cardTheme: CardTheme(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBrand,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBrand,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBrand,
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: primaryBrand,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: errorColor,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryBrand,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarTheme(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: primaryBrand.withOpacity(0.2),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.1,
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return Colors.white.withOpacity(0.8);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryBrand;
          }
          return Colors.white.withOpacity(0.2);
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryBrand;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: BorderSide(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryBrand,
        linearTrackColor: darkSurfaceVariant,
        circularTrackColor: darkSurfaceVariant,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.1),
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: Colors.white.withOpacity(0.8),
        size: 24,
      ),

      // Typography Theme
      textTheme: _buildTextTheme(),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurface,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        contentTextStyle: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        elevation: 0,
      ),
    );
  }

  /// Build premium typography system with proper Material 3 scales
  static TextTheme _buildTextTheme() {
    return const TextTheme(
      // Display styles - for hero sections
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: Colors.white,
        height: 1.12,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: Colors.white,
        height: 1.16,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: Colors.white,
        height: 1.22,
      ),

      // Headline styles - for section headers
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: Colors.white,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: Colors.white,
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: Colors.white,
        height: 1.33,
      ),

      // Title styles - for card titles and labels
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: Colors.white,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: Colors.white,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: Colors.white,
        height: 1.43,
      ),

      // Body styles - for content text
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: Colors.white,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: Colors.white,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: Colors.white,
        height: 1.33,
      ),

      // Label styles - for buttons and small text
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: Colors.white,
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: Colors.white,
        height: 1.33,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: Colors.white,
        height: 1.45,
      ),
    );
  }

  /// Habit-specific color schemes for theming
  static Map<String, ColorScheme> get habitColorSchemes {
    return {
      'smoking': const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: Color(0xFF2E7D32),
        onPrimary: Colors.white,
        secondary: Color(0xFF66BB6A),
        onSecondary: Colors.white,
        tertiary: accentBrand,
        onTertiary: Colors.white,
        surface: darkSurface,
        onSurface: Colors.white,
        background: darkBackground,
        onBackground: Colors.white,
        error: errorColor,
        onError: Colors.white,
      ),
      'alcohol': const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: Color(0xFF1565C0),
        onPrimary: Colors.white,
        secondary: Color(0xFF42A5F5),
        onSecondary: Colors.white,
        tertiary: accentBrand,
        onTertiary: Colors.white,
        surface: darkSurface,
        onSurface: Colors.white,
        background: darkBackground,
        onBackground: Colors.white,
        error: errorColor,
        onError: Colors.white,
      ),
      'drugs': const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: Color(0xFF7B1FA2),
        onPrimary: Colors.white,
        secondary: Color(0xFFBA68C8),
        onSecondary: Colors.white,
        tertiary: accentBrand,
        onTertiary: Colors.white,
        surface: darkSurface,
        onSurface: Colors.white,
        background: darkBackground,
        onBackground: Colors.white,
        error: errorColor,
        onError: Colors.white,
      ),
      // Add more habit-specific themes as needed
    };
  }

  /// Get dynamic theme based on user's habit type
  static ThemeData getHabitTheme(String? habitType) {
    final baseTheme = darkTheme;
    final habitScheme = habitColorSchemes[habitType];

    if (habitScheme != null) {
      return baseTheme.copyWith(colorScheme: habitScheme);
    }

    return baseTheme;
  }

  /// Glass morphism decoration for premium cards
  static BoxDecoration get glassMorphicDecoration {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Premium gradient decorations
  static BoxDecoration primaryGradientDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [primaryBrand, secondaryBrand],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: primaryBrand.withOpacity(0.3),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration successGradientDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [successColor, Color(0xFF66BB6A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: successColor.withOpacity(0.3),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration bitcoinGradientDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [accentBrand, Color(0xFFFFD700)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: accentBrand.withOpacity(0.3),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

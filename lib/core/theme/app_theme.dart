import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF4B63F0),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFDCE2FF),
      onPrimaryContainer: Color(0xFF1D2C84),
      secondary: Color(0xFFFFB655),
      onSecondary: Color(0xFF3D2400),
      secondaryContainer: Color(0xFFFFE2BC),
      onSecondaryContainer: Color(0xFF5B3A00),
      tertiary: Color(0xFF4CA8FF),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFD1EAFF),
      onTertiaryContainer: Color(0xFF003355),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: Color(0xFFF3F5FB),
      onSurface: Color(0xFF1A2138),
      onSurfaceVariant: Color(0xFF5A6175),
      outline: Color(0xFFBCC2D5),
      outlineVariant: Color(0xFFDCE1F0),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFF2B3147),
      onInverseSurface: Color(0xFFEFF1F8),
      inversePrimary: Color(0xFFBBC3FF),
      surfaceTint: Color(0xFF4B63F0),
    );

    return _themeFromScheme(scheme);
  }

  static ThemeData darkTheme() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFBBC3FF),
      onPrimary: Color(0xFF1D2C84),
      primaryContainer: Color(0xFF344AB7),
      onPrimaryContainer: Color(0xFFDCE2FF),
      secondary: Color(0xFFFFC779),
      onSecondary: Color(0xFF442C00),
      secondaryContainer: Color(0xFF5F4100),
      onSecondaryContainer: Color(0xFFFFE2BC),
      tertiary: Color(0xFF9DD0FF),
      onTertiary: Color(0xFF003355),
      tertiaryContainer: Color(0xFF004B7C),
      onTertiaryContainer: Color(0xFFD1EAFF),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFF11131A),
      onSurface: Color(0xFFE6E8F0),
      onSurfaceVariant: Color(0xFFC3C7D6),
      outline: Color(0xFF8D93A7),
      outlineVariant: Color(0xFF43485B),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFFE6E8F0),
      onInverseSurface: Color(0xFF2B3147),
      inversePrimary: Color(0xFF4B63F0),
      surfaceTint: Color(0xFFBBC3FF),
    );

    return _themeFromScheme(scheme);
  }

  static ThemeData _themeFromScheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.brightness == Brightness.dark
            ? colorScheme.surfaceContainerLow
            : Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: .7),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.brightness == Brightness.dark
            ? colorScheme.surfaceContainerLow
            : Colors.white,
        elevation: 0,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: colorScheme.outlineVariant),
        selectedColor: colorScheme.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: .45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}

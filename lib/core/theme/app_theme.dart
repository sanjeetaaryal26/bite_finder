import 'package:flutter/material.dart';

class AppTheme {
  static const Color defaultSeedColor = Color(0xFF9E1116);

  static ThemeData lightTheme({Color seedColor = defaultSeedColor}) {
    const bg = Color(0xFFF7ECEE);
    const text = Color(0xFF2A1618);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );

    final textTheme = Typography.material2021(platform: TargetPlatform.android).black.copyWith(
          headlineMedium: const TextStyle(fontWeight: FontWeight.w800, fontSize: 28, color: text),
          titleLarge: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: text),
          titleMedium: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: text),
          bodyLarge: const TextStyle(fontSize: 16, height: 1.35, color: text),
          bodyMedium: const TextStyle(fontSize: 15, height: 1.35, color: text),
          bodySmall: const TextStyle(fontSize: 13, height: 1.3, color: text),
          labelLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: text,
        elevation: 0.2,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: text,
          fontWeight: FontWeight.w800,
        ),
      ),
      textTheme: textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0.3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.primary,
        contentTextStyle: TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            size: selected ? 25 : 22,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          minimumSize: const Size(0, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  static ThemeData darkTheme({Color seedColor = defaultSeedColor}) {
    final colorScheme = ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: Typography.material2021(platform: TargetPlatform.android).white.copyWith(
            bodyLarge: const TextStyle(fontSize: 16),
            bodyMedium: const TextStyle(fontSize: 15),
            bodySmall: const TextStyle(fontSize: 13),
          ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        indicatorColor: colorScheme.primaryContainer,
      ),
    );
  }
}

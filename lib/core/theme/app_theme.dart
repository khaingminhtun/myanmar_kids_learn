import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color cream = Color(0xFFFFF8EE);
  static const Color card = Color(0xFFFFFDF8);
  static const Color ink = Color(0xFF3E2C23);
  static const Color inkSoft = Color(0xFF7A6255);
  static const Color orange = Color(0xFFF4A261);
  static const Color orangeDeep = Color(0xFFE76F51);
  static const Color sun = Color(0xFFF9C74F);
  static const Color teal = Color(0xFF2A9D8F);
  static const Color green = Color(0xFF7CB342);
  static const Color sky = Color(0xFF8FD3F4);
  static const Color pink = Color(0xFFF7B7C8);
  static const Color purple = Color(0xFF9B7EDE);
  static const Color error = Color(0xFFD9534F);
  static const Color success = Color(0xFF2E7D32);
}

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.orangeDeep,
      onPrimary: Colors.white,
      secondary: AppColors.teal,
      onSecondary: Colors.white,
      surface: AppColors.card,
      onSurface: AppColors.ink,
      error: AppColors.error,
      tertiary: AppColors.sun,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      fontFamily: 'NotoSansMyanmar',
      visualDensity: VisualDensity.comfortable,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );

    final textTheme = base.textTheme
        .apply(
          fontFamily: 'NotoSansMyanmar',
          bodyColor: AppColors.ink,
          displayColor: AppColors.ink,
        )
        .copyWith(
          displaySmall: const TextStyle(
            fontFamily: 'NotoSansMyanmar',
            fontSize: 34,
            height: 1.35,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          headlineMedium: const TextStyle(
            fontFamily: 'NotoSansMyanmar',
            fontSize: 28,
            height: 1.4,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          headlineSmall: const TextStyle(
            fontFamily: 'NotoSansMyanmar',
            fontSize: 23,
            height: 1.45,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          titleLarge: const TextStyle(
            fontFamily: 'NotoSansMyanmar',
            fontSize: 21,
            height: 1.4,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          titleMedium: const TextStyle(
            fontFamily: 'NotoSansMyanmar',
            fontSize: 18,
            height: 1.4,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
          bodyLarge: const TextStyle(
            fontFamily: 'NotoSansMyanmar',
            fontSize: 20,
            height: 1.65,
            color: AppColors.ink,
          ),
          bodyMedium: const TextStyle(
            fontFamily: 'NotoSansMyanmar',
            fontSize: 17,
            height: 1.55,
            color: AppColors.ink,
          ),
          bodySmall: const TextStyle(
            fontFamily: 'NotoSansMyanmar',
            fontSize: 15,
            height: 1.45,
            color: AppColors.inkSoft,
          ),
          labelLarge: const TextStyle(
            fontFamily: 'NotoSansMyanmar',
            fontSize: 18,
            height: 1.3,
            fontWeight: FontWeight.w700,
          ),
        );

    final buttonStyle = ButtonStyle(
      minimumSize: WidgetStateProperty.all(const Size(64, 56)),
      textStyle: WidgetStateProperty.all(
        const TextStyle(
          fontFamily: 'NotoSansMyanmar',
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'NotoSansMyanmar',
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(style: buttonStyle),
      elevatedButtonTheme: ElevatedButtonThemeData(style: buttonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: buttonStyle.copyWith(
          side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.orange, width: 2),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: buttonStyle),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE8D9C8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE8D9C8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.orange, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(
          fontFamily: 'NotoSansMyanmar',
          fontSize: 16,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'NotoSansMyanmar',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'NotoSansMyanmar',
          fontSize: 17,
          height: 1.5,
          color: AppColors.ink,
        ),
      ),
      dividerColor: const Color(0xFFEADBCB),
      iconTheme: const IconThemeData(color: AppColors.ink, size: 26),
    );
  }
}

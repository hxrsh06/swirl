import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color palette
  static const Color primaryColor = Color(0xFF4A6CF7); // Modern blue
  static const Color primaryColorLight = Color(0xFF6D88FF);
  static const Color primaryColorDark = Color(0xFF2A4BCE);
  
  static const Color secondaryColor = Color(0xFF6C5CE7); // Purple accent
  static const Color secondaryColorLight = Color(0xFF8D7CF7);
  static const Color secondaryColorDark = Color(0xFF4B3DD1);
  
  static const Color successColor = Color(0xFF00B894); // Green
  static const Color warningColor = Color(0xFFE17055); // Orange-red
 static const Color errorColor = Color(0xFFE84393); // Pink
  
  static const Color backgroundColor = Color(0xFFF8F9FA); // Light gray
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;
  
  static const Color textColorPrimary = Color(0xFF2D3436); // Dark gray
  static const Color textColorSecondary = Color(0xFF636E72); // Medium gray
  static const Color textColorHint = Color(0xFFB2BEC3); // Light gray
  
  // Typography
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48.0,
    fontWeight: FontWeight.w700,
    color: textColorPrimary,
    height: 1.2,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 36.0,
    fontWeight: FontWeight.w700,
    color: textColorPrimary,
    height: 1.2,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    color: textColorPrimary,
    height: 1.2,
  );
  
 static const TextStyle headlineLarge = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    color: textColorPrimary,
    height: 1.3,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    color: textColorPrimary,
    height: 1.3,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w700,
    color: textColorPrimary,
    height: 1.3,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: textColorPrimary,
    height: 1.4,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: textColorPrimary,
    height: 1.4,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: textColorSecondary,
    height: 1.4,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: textColorPrimary,
    height: 1.2,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    color: textColorPrimary,
    height: 1.2,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.w600,
    color: textColorPrimary,
    height: 1.2,
  );
  
  // Theme
 static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textColorPrimary,
      onBackground: textColorPrimary,
      onError: Colors.white,
      onSurfaceVariant: textColorSecondary,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 0,
      titleTextStyle: headlineMedium.copyWith(color: textColorPrimary),
      iconTheme: const IconThemeData(color: textColorPrimary),
      centerTitle: true,
      scrolledUnderElevation: 4,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textColorHint,
      selectedLabelStyle: labelMedium,
      unselectedLabelStyle: labelSmall,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 0.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: labelLarge.copyWith(fontWeight: FontWeight.w600),
        elevation: 0,
        shadowColor: primaryColor.withOpacity(0.2),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: labelLarge.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: labelLarge.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: bodyMedium.copyWith(color: textColorHint),
      floatingLabelStyle: bodyMedium.copyWith(color: primaryColor),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(const TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    )),
    iconTheme: const IconThemeData(
      color: textColorPrimary,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 0.5,
      space: 0,
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: const Color(0xFF1E1E1E),
      background: const Color(0xFF121212),
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white,
      onSurfaceVariant: textColorHint,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      titleTextStyle: headlineMedium.copyWith(color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: true,
      scrolledUnderElevation: 4,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: primaryColor,
      unselectedItemColor: textColorHint,
      selectedLabelStyle: labelMedium,
      unselectedLabelStyle: labelSmall,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade700, width: 0.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: labelLarge.copyWith(fontWeight: FontWeight.w600),
        elevation: 0,
        shadowColor: primaryColor.withOpacity(0.2),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: labelLarge.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: labelLarge.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2D2D2D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: bodyMedium.copyWith(color: textColorHint),
      floatingLabelStyle: bodyMedium.copyWith(color: primaryColor),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(const TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    )),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade700,
      thickness: 0.5,
      space: 0,
    ),
  );
}
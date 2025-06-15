// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class AppTheme {
//   // Brand Colors
//   static const Color primaryColor = Color(0xFF4E48E0);
//   static const Color secondaryColor = Color(0xFF6A64F0);
//   static const Color accentColor = Color(0xFF00D9D5);
//   static const Color errorColor = Color(0xFFFF5252);
//   static const Color warningColor = Color(0xFFFFB74D);
//   static const Color successColor = Color(0xFF66BB6A);
  
//   // Light Theme Colors
//   static const Color lightBackground = Color(0xFFF8F8FE);
//   static const Color lightCardColor = Colors.white;
//   static const Color lightTextPrimary = Color(0xFF212121);
//   static const Color lightTextSecondary = Color(0xFF757575);
  
//   // Dark Theme Colors
//   static const Color darkBackground = Color(0xFF121212);
//   static const Color darkCardColor = Color(0xFF1E1E3A);
//   static const Color darkTextPrimary = Color(0xFFFAFAFA);
//   static const Color darkTextSecondary = Color(0xFFBDBDBD);
  
//   // Common Border Radius
//   static final BorderRadius borderRadius = BorderRadius.circular(12.0);
//   static final BorderRadius buttonRadius = BorderRadius.circular(8.0);
//   static final BorderRadius cardRadius = BorderRadius.circular(16.0);
  
//   // Light Theme
//   static ThemeData get lightTheme {
//     return ThemeData(
//       brightness: Brightness.light,
//       primaryColor: primaryColor,
//       scaffoldBackgroundColor: lightBackground,
//       cardColor: lightCardColor,
//       colorScheme: const ColorScheme.light(
//         primary: primaryColor,
//         secondary: secondaryColor,
//         error: errorColor,
//       ),
//       appBarTheme: AppBarTheme(
//         backgroundColor: lightBackground,
//         foregroundColor: primaryColor,
//         elevation: 0,
//         centerTitle: true,
//         titleTextStyle: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//           color: primaryColor,
//         ),
//         iconTheme: const IconThemeData(color: primaryColor),
//       ),
//       textTheme: GoogleFonts.poppinsTextTheme(
//         const TextTheme(
//           displayLarge: TextStyle(color: lightTextPrimary),
//           displayMedium: TextStyle(color: lightTextPrimary),
//           displaySmall: TextStyle(color: lightTextPrimary),
//           headlineMedium: TextStyle(color: lightTextPrimary),
//           headlineSmall: TextStyle(color: lightTextPrimary),
//           titleLarge: TextStyle(color: lightTextPrimary),
//           titleMedium: TextStyle(color: lightTextPrimary),
//           titleSmall: TextStyle(color: lightTextPrimary),
//           bodyLarge: TextStyle(color: lightTextPrimary),
//           bodyMedium: TextStyle(color: lightTextSecondary),
//           bodySmall: TextStyle(color: lightTextSecondary),
//           labelLarge: TextStyle(color: lightTextPrimary),
//         ),
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: primaryColor,
//           foregroundColor: Colors.white,
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           shape: RoundedRectangleBorder(borderRadius: buttonRadius),
//         ),
//       ),
//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           foregroundColor: primaryColor,
//           side: const BorderSide(color: primaryColor),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           shape: RoundedRectangleBorder(borderRadius: buttonRadius),
//         ),
//       ),
//       textButtonTheme: TextButtonThemeData(
//         style: TextButton.styleFrom(
//           foregroundColor: primaryColor,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         ),
//       ),
//       cardTheme: CardTheme(
//         color: lightCardColor,
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: cardRadius),
//       ),
//       iconTheme: const IconThemeData(
//         color: lightTextSecondary,
//         size: 24,
//       ),
//       bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//         backgroundColor: lightCardColor,
//         selectedItemColor: primaryColor,
//         unselectedItemColor: lightTextSecondary,
//         type: BottomNavigationBarType.fixed,
//         elevation: 8,
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: borderRadius,
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: borderRadius,
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: borderRadius,
//           borderSide: const BorderSide(color: primaryColor, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: borderRadius,
//           borderSide: const BorderSide(color: errorColor, width: 1),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: borderRadius,
//           borderSide: const BorderSide(color: errorColor, width: 2),
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       ),
//     );
//   }
  
//   // Dark Theme
//   static ThemeData get darkTheme {
//     return ThemeData(
//       brightness: Brightness.dark,
//       primaryColor: primaryColor,
//       scaffoldBackgroundColor: darkBackground,
//       cardColor: darkCardColor,
//       colorScheme: const ColorScheme.dark(
//         primary: primaryColor,
//         secondary: accentColor,
//         error: errorColor,
//       ),
//       appBarTheme: AppBarTheme(
//         backgroundColor: darkBackground,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         titleTextStyle: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//           color: Colors.white,
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       textTheme: GoogleFonts.poppinsTextTheme(
//         const TextTheme(
//           displayLarge: TextStyle(color: darkTextPrimary),
//           displayMedium: TextStyle(color: darkTextPrimary),
//           displaySmall: TextStyle(color: darkTextPrimary),
//           headlineMedium: TextStyle(color: darkTextPrimary),
//           headlineSmall: TextStyle(color: darkTextPrimary),
//           titleLarge: TextStyle(color: darkTextPrimary),
//           titleMedium: TextStyle(color: darkTextPrimary),
//           titleSmall: TextStyle(color: darkTextPrimary),
//           bodyLarge: TextStyle(color: darkTextPrimary),
//           bodyMedium: TextStyle(color: darkTextSecondary),
//           bodySmall: TextStyle(color: darkTextSecondary),
//           labelLarge: TextStyle(color: darkTextPrimary),
//         ),
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: accentColor,
//           foregroundColor: Colors.black,
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           shape: RoundedRectangleBorder(borderRadius: buttonRadius),
//         ),
//       ),
//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           foregroundColor: accentColor,
//           side: const BorderSide(color: accentColor),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           shape: RoundedRectangleBorder(borderRadius: buttonRadius),
//         ),
//       ),
//       textButtonTheme: TextButtonThemeData(
//         style: TextButton.styleFrom(
//           foregroundColor: accentColor,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         ),
//       ),
//       cardTheme: CardTheme(
//         color: darkCardColor,
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: cardRadius),
//       ),
//       iconTheme: const IconThemeData(
//         color: darkTextSecondary,
//         size: 24,
//       ),
//       bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//         backgroundColor: darkCardColor,
//         selectedItemColor: accentColor,
//         unselectedItemColor: darkTextSecondary,
//         type: BottomNavigationBarType.fixed,
//         elevation: 8,
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: darkCardColor,
//         border: OutlineInputBorder(
//           borderRadius: borderRadius,
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: borderRadius,
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: borderRadius,
//           borderSide: const BorderSide(color: accentColor, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: borderRadius,
//           borderSide: const BorderSide(color: errorColor, width: 1),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: borderRadius,
//           borderSide: const BorderSide(color: errorColor, width: 2),
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       ),
//     );
//   }
  
//   // Common shadows
//   static List<BoxShadow> get lightShadow => [
//     BoxShadow(
//       color: Colors.black.withOpacity(0.05),
//       blurRadius: 10,
//       spreadRadius: 0,
//       offset: const Offset(0, 5),
//     ),
//   ];
  
//   static List<BoxShadow> get mediumShadow => [
//     BoxShadow(
//       color: Colors.black.withOpacity(0.1),
//       blurRadius: 20,
//       spreadRadius: 0,
//       offset: const Offset(0, 10),
//     ),
//   ];
// }




import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme extends ChangeNotifier {
  // Internal state for theme
  bool _isDarkMode = false;
  
  // Getter for current mode
  bool get isDarkMode => _isDarkMode;
  
  // Setter for dark mode with notification
  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      notifyListeners();
    }
  }
  
  // Get current theme based on mode
  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;
  
  // Brand Colors
  static const Color primaryColor = Color(0xFF4E48E0);
  static const Color secondaryColor = Color(0xFF6A64F0);
  static const Color accentColor = Color(0xFF00D9D5);
  static const Color errorColor = Color(0xFFFF5252);
  static const Color warningColor = Color(0xFFFFB74D);
  static const Color successColor = Color(0xFF66BB6A);
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8F8FE);
  static const Color lightCardColor = Colors.white;
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E3A);
  static const Color darkTextPrimary = Color(0xFFFAFAFA);
  static const Color darkTextSecondary = Color(0xFFBDBDBD);
  
  // Common Border Radius
  static final BorderRadius borderRadius = BorderRadius.circular(12.0);
  static final BorderRadius buttonRadius = BorderRadius.circular(8.0);
  static final BorderRadius cardRadius = BorderRadius.circular(16.0);
  
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true, // Add Material 3 support for better design consistency
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBackground,
      cardColor: lightCardColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        tertiary: accentColor,
        surface: lightCardColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: lightTextPrimary),
          displayMedium: TextStyle(color: lightTextPrimary),
          displaySmall: TextStyle(color: lightTextPrimary),
          headlineMedium: TextStyle(color: lightTextPrimary),
          headlineSmall: TextStyle(color: lightTextPrimary),
          titleLarge: TextStyle(color: lightTextPrimary),
          titleMedium: TextStyle(color: lightTextPrimary),
          titleSmall: TextStyle(color: lightTextPrimary),
          bodyLarge: TextStyle(color: lightTextPrimary),
          bodyMedium: TextStyle(color: lightTextSecondary),
          bodySmall: TextStyle(color: lightTextSecondary),
          labelLarge: TextStyle(color: lightTextPrimary),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: buttonRadius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: buttonRadius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      cardTheme: CardTheme(
        color: lightCardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: cardRadius),
      ),
      iconTheme: const IconThemeData(
        color: lightTextSecondary,
        size: 24,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightCardColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      // Add support for floating action buttons
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      // Add support for segmented buttons
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
        space: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey.shade400;
            }
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }
            return Colors.grey.shade50;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey.shade200;
            }
            if (states.contains(WidgetState.selected)) {
              return primaryColor.withOpacity(0.3);
            }
            return Colors.grey.shade300;
          },
        ),
      ),
    );
  }
  
  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true, // Add Material 3 support
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkCardColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        error: errorColor,
        tertiary: secondaryColor,
        surface: darkCardColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: darkTextPrimary),
          displayMedium: TextStyle(color: darkTextPrimary),
          displaySmall: TextStyle(color: darkTextPrimary),
          headlineMedium: TextStyle(color: darkTextPrimary),
          headlineSmall: TextStyle(color: darkTextPrimary),
          titleLarge: TextStyle(color: darkTextPrimary),
          titleMedium: TextStyle(color: darkTextPrimary),
          titleSmall: TextStyle(color: darkTextPrimary),
          bodyLarge: TextStyle(color: darkTextPrimary),
          bodyMedium: TextStyle(color: darkTextSecondary),
          bodySmall: TextStyle(color: darkTextSecondary),
          labelLarge: TextStyle(color: darkTextPrimary),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: buttonRadius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          side: const BorderSide(color: accentColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: buttonRadius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      cardTheme: CardTheme(
        color: darkCardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: cardRadius),
      ),
      iconTheme: const IconThemeData(
        color: darkTextSecondary,
        size: 24,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkCardColor,
        selectedItemColor: accentColor,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardColor,
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      // Add support for floating action buttons
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.black,
        elevation: 4,
      ),
      // Add support for dividers
      dividerTheme: const DividerThemeData(
        color: Color(0xFF323232),
        thickness: 1,
        space: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey.shade700;
            }
            if (states.contains(WidgetState.selected)) {
              return accentColor;
            }
            return Colors.grey.shade400;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey.shade800;
            }
            if (states.contains(WidgetState.selected)) {
              return accentColor.withOpacity(0.3);
            }
            return Colors.grey.shade700;
          },
        ),
      ),
    );
  }
  
  // Common shadows
  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      spreadRadius: 0,
      offset: const Offset(0, 5),
    ),
  ];
  
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 10),
    ),
  ];
  
  // Dark shadows
  static List<BoxShadow> get darkShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 30,
      spreadRadius: 0,
      offset: const Offset(0, 15),
    ),
  ];
  
  // Card styles
  static BoxDecoration lightCardDecoration = BoxDecoration(
    color: lightCardColor,
    borderRadius: cardRadius,
    boxShadow: lightShadow,
  );
  
  static BoxDecoration darkCardDecoration = BoxDecoration(
    color: darkCardColor,
    borderRadius: cardRadius,
    border: Border.all(
      color: Colors.white.withOpacity(0.1),
      width: 1,
    ),
  );
  
  // Get appropriate card decoration based on theme
  BoxDecoration getCardDecoration() => _isDarkMode ? darkCardDecoration : lightCardDecoration;
}
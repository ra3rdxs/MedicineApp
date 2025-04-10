import 'package:flutter/material.dart';

// AppTheme class - Centralizes all styling and theming for the application
// This class provides consistent colors, text styles, and UI element styling
// throughout the app, making it easier to maintain a cohesive design
class AppTheme {
  // Primary color palette - Main colors used throughout the app
  static const Color primaryColor = Color(0xFF757575); // Medium Grey
  static const Color primaryLightColor = Color(0xFFA4A4A4); // Lighter variant of primary color
  static const Color primaryDarkColor = Color(0xFF494949); // Darker variant of primary color
  
  // Secondary color palette - Used for accents and highlights
  static const Color secondaryColor = Color(0xFFFF9800); // Orange
  static const Color secondaryLightColor = Color(0xFFFFB74D); // Lighter variant of secondary color
  static const Color secondaryDarkColor = Color(0xFFF57C00); // Darker variant of secondary color
  
  // Accent colors - Used for specific UI states and actions
  static const Color accentColor = Color(0xFFFF5722); // Deep Orange for important actions
  static const Color successColor = Color(0xFF4CAF50); // Green for success states
  static const Color warningColor = Color(0xFFFFCA28); // Amber for warnings
  
  // Background colors - Used for different surface types
  static const Color backgroundColor = Color(0xFFF8F9FE); // Light background for screens
  static const Color cardColor = Colors.white; // White background for cards
  static const Color dividerColor = Color(0xFFEEEEEE); // Light grey for dividers
  
  // Text colors - Different shades for text hierarchy
  static const Color textPrimaryColor = Color(0xFF2D3142); // Dark blue-gray for primary text
  static const Color textSecondaryColor = Color(0xFF6E7191); // Medium gray for secondary text
  static const Color textLightColor = Color(0xFFA0A3BD); // Light gray for tertiary text
  
  // Gradient for cards and backgrounds - Adds visual interest
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLightColor, primaryColor], // Gradient from light to normal primary color
    begin: Alignment.topLeft, // Starting point of gradient
    end: Alignment.bottomRight, // Ending point of gradient
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryLightColor, secondaryColor], // Gradient from light to normal secondary color
    begin: Alignment.topLeft, // Starting point of gradient
    end: Alignment.bottomRight, // Ending point of gradient
  );
  
  // Text styles - Consistent typography throughout the app
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24, // Large size for main headings
    fontWeight: FontWeight.bold, // Bold weight for emphasis
    color: textPrimaryColor, // Dark color for contrast
    letterSpacing: 0.15, // Slight letter spacing for readability
  );
  
  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 20, // Medium-large size for subheadings
    fontWeight: FontWeight.w600, // Semi-bold weight
    color: textPrimaryColor, // Dark color for contrast
    letterSpacing: 0.15, // Slight letter spacing for readability
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16, // Standard size for body text
    color: textPrimaryColor, // Dark color for contrast
    letterSpacing: 0.5, // Moderate letter spacing for readability
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontSize: 14, // Smaller size for captions and hints
    color: textSecondaryColor, // Medium gray for less emphasis
    letterSpacing: 0.4, // Moderate letter spacing for readability
  );
  
  // Card decoration - Consistent styling for card elements
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor, // White background
    borderRadius: BorderRadius.circular(16), // Rounded corners
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05), // Subtle shadow
        blurRadius: 10, // Soft blur
        offset: const Offset(0, 4), // Shadow offset downward
      ),
    ],
  );
  
  // Button styles - Consistent styling for buttons
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor, // Primary color background
    foregroundColor: Colors.white, // White text for contrast
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Comfortable padding
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
    elevation: 2, // Subtle elevation
  );
  
  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white, // White background
    foregroundColor: primaryColor, // Primary color text
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Comfortable padding
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Rounded corners
      side: const BorderSide(color: primaryColor), // Border with primary color
    ),
    elevation: 0, // No elevation for flat appearance
  );
  
  // Input decoration - Consistent styling for text fields
  static InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label, // Label text
      prefixIcon: Icon(icon), // Icon at the start of the input
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: dividerColor), // Light border when not focused
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2), // Primary color border when focused
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 1), // Red border for errors
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 2), // Thicker red border for focused errors
      ),
      filled: true, // Fill the input background
      fillColor: Colors.white, // White background
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16), // Comfortable padding
    );
  }
  
  // Get the complete theme data for the app
  static ThemeData getTheme() {
    return ThemeData(
      // Base colors
      primaryColor: primaryColor,
      primaryColorLight: primaryLightColor,
      primaryColorDark: primaryDarkColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        surface: cardColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textPrimaryColor,
        onSurface: textPrimaryColor,
      ),
      
      // Background colors
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      dividerColor: dividerColor,
      
      // Text themes
      textTheme: TextTheme(
        displayLarge: headingStyle,
        displayMedium: subheadingStyle,
        bodyLarge: bodyStyle,
        bodyMedium: captionStyle,
      ),
      
      // Component themes
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: subheadingStyle,
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButtonStyle,
      ),
      
      // Input themes
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
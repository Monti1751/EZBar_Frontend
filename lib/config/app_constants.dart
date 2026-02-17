import 'package:flutter/material.dart';

/// Centralized application constants to avoid "magic numbers"
class AppConstants {
  // ==================== HTTP STATUS CODES ====================
  static const int httpOk = 200;
  static const int httpCreated = 201;
  static const int httpNoContent = 204;
  static const int httpBadRequest = 400;
  static const int httpUnauthorized = 401;
  static const int httpForbidden = 403;
  static const int httpNotFound = 404;
  static const int httpInternalServerError = 500;

  // ==================== DESIGN SYSTEM: COLORS ====================
  // Core branding colors
  static const Color primaryGreen = Color(0xFF7BA238);
  static const Color backgroundCream = Color(0xFFECF0D5);
  static const Color darkBrown = Color(0xFF4A4025);
  static const Color lightGreen = Color(0xFF8EB156);

  // Feedback colors
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;

  // ==================== UI DIMENSIONS ====================
  // Spacing & Padding
  static const double paddingXXSmall = 4.0;
  static const double paddingXSmall = 6.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 10.0;
  static const double paddingLarge = 12.0;
  static const double paddingXLarge = 16.0;
  static const double paddingXXLarge = 20.0;
  static const double paddingExtraLarge = 32.0;

  // Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusSmallMedium = 10.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 20.0;

  // Elements
  static const double appBarHeight = 55.0;
  static const double logoSizeLarge = 130.0;
  static const double defaultIconSize = 28.0;
  static const double buttonPaddingVertical = 14.0;
  static const double buttonPaddingVerticalLarge = 18.0;

  // Borders
  static const double borderWidthThin = 1.5;
  static const double borderWidthThick = 2.2;
  static const double logoBorderWidth = 6.0;

  // ==================== DURATIONS ====================
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration snackBarShort = Duration(seconds: 1);
  static const Duration snackBarMedium = Duration(seconds: 3);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 500);
}

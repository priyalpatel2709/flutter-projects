import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryShade50 = Color(0xFFEFF6FF);
  static const Color primaryShade100 = Color(0xFFDBEAFE);
  static const Color primaryShade200 = Color(0xFFBFDBFE);
  static const Color primaryShade300 = Color(0xFF93C5FD);
  static const Color primaryShade400 = Color(0xFF60A5FA);
  static const Color primaryShade500 = Color(0xFF3B82F6);
  static const Color primaryShade600 = Color(0xFF2563EB);
  static const Color primaryShade700 = Color(0xFF1D4ED8);
  static const Color primaryShade800 = Color(0xFF1E40AF);
  static const Color primaryShade900 = Color(0xFF1E3A8A);

  // Secondary Colors
  static const Color secondary = Color(0xFFF59E0B);
  static const Color secondaryLight = Color(0xFFFBBF24);
  static const Color secondaryDark = Color(0xFFD97706);

  // Success Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);

  // Error Colors
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  // Warning Colors
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Background Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Border Colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderDark = Color(0xFFD1D5DB);

  // Shadow Colors
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  // Premium Colors
  static const Color premium = Color(0xFFF59E0B);
  static const Color premiumLight = Color(0xFFFEF3C7);
  static const Color premiumDark = Color(0xFFD97706);

  // Referral Colors
  static const Color referral = Color(0xFF8B5CF6);
  static const Color referralLight = Color(0xFFDDD6FE);
  static const Color referralDark = Color(0xFF7C3AED);

  // File Type Colors
  static const Color filePdf = Color(0xFFEF4444);
  static const Color fileSpreadsheet = Color(0xFF10B981);
  static const Color filePresentation = Color(0xFFF59E0B);
  static const Color fileImage = Color(0xFF8B5CF6);
  static const Color fileDocument = Color(0xFF3B82F6);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [white, grey50],
  );

  static const LinearGradient referralGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [referral, referralLight],
  );
} 
import 'package:flutter/material.dart';

/// Industrial Light Gray & Pitch Black Monochrome Palette
/// Strict: All white surfaces replaced with Light Gray. Max font-weight 600.
class AppColors {
  // Deep Pitch Blacks & Darks
  static const Color pitchBlack = Color(0xFF000000);
  static const Color black = Color(0xFF111111);
  static const Color cardDark = Color(0xFF1E1E1E);

  // Primary Action Accent (Monochrome Pitch Black)
  static const Color primary = Color(0xFF000000);
  static const Color primaryDark = Color(0xFF000000);
  static const Color primaryLight = Color(0xFF374151);
  static const Color primaryTint = Color(0xFFE5E7EB);
  static const Color primaryBorder = Color(0xFFD1D5DB);

  // Deep Slate Darks
  static const Color slate950 = Color(0xFF000000);
  static const Color slate900 = Color(0xFF111111);
  static const Color slate800 = Color(0xFF1F2937);
  static const Color slate700 = Color(0xFF374151);

  // Surfaces: Pure White eliminated -> Replaced with Light Gray
  static const Color canvas = Color(0xFFE5E7EB); // Base canvas (Cool Light Gray)
  static const Color lightGray = Color(0xFFF3F4F6); // Surface panels & cards
  static const Color cardLight = Color(0xFFF3F4F6);
  static const Color surfaceElevated = Color(0xFFE5E7EB);
  static const Color surfaceInput = Color(0xFFE5E7EB);

  // Text on Dark Backgrounds
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Borders & Dividers (Tuned for light gray backgrounds)
  static const Color border = Color(0xFFD1D5DB); // Gray 300
  static const Color borderDark = Color(0xFF9CA3AF); // Gray 400
  static const Color borderHover = Color(0xFF000000);

  // Typography & Semantics
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF374151);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color zinc400 = Color(0xFF6B7280);
  static const Color zinc500 = Color(0xFF4B5563);
  static const Color zinc600 = Color(0xFF374151);
  static const Color zinc700 = Color(0xFF1F2937);
  static const Color zinc100 = Color(0xFFE5E7EB);
  static const Color zinc50 = Color(0xFFF3F4F6);

  // Status & Tags
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEF2F2);
}

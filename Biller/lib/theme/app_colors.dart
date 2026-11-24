import 'package:flutter/material.dart';

/// Royal Indigo & Deep Slate Enterprise Theme
/// Inspired by Ant Design & Modern SaaS Enterprise UI
class AppColors {
  // Brand Royal Indigo
  static const Color primary = Color(0xFF4F46E5);       // Royal Indigo (Indigo 600)
  static const Color primaryDark = Color(0xFF3730A3);   // Deep Indigo (Indigo 800)
  static const Color primaryLight = Color(0xFF6366F1);  // Vivid Indigo (Indigo 500)
  static const Color primaryTint = Color(0xFFEEF2FF);   // Soft Indigo Tint (Indigo 50)
  static const Color primaryBorder = Color(0xFFC7D2FE); // Soft Indigo Border (Indigo 200)

  // Deep Slate Darks (Headings, High Contrast)
  static const Color slate950 = Color(0xFF020617);
  static const Color slate900 = Color(0xFF0F172A);      // Deep Slate (Rich Navy Black)
  static const Color slate800 = Color(0xFF1E293B);      // Slate 800
  static const Color slate700 = Color(0xFF334155);      // Slate 700

  // Enterprise Dark Aliases (backward-compatible)
  static const Color pitchBlack = Color(0xFF0F172A);    // Deep Slate 900
  static const Color black = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF0F172A);

  // Surfaces: Modern Slate Enterprise
  static const Color canvas = Color(0xFFF1F5F9);        // Slate 100 - Clean, airy, modern canvas
  static const Color lightGray = Color(0xFFFFFFFF);     // Pure White panels & cards (signature crisp AntD look)
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceInput = Color(0xFFF8FAFC);   // Slate 50

  // Text on Dark Backgrounds
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);        // Slate 200 - Ultra clean, subtle borders
  static const Color borderDark = Color(0xFFCBD5E1);    // Slate 300
  static const Color borderHover = Color(0xFF6366F1);

  // Typography & Semantics
  static const Color textPrimary = Color(0xFF0F172A);   // Slate 900
  static const Color textSecondary = Color(0xFF334155); // Slate 700
  static const Color textMuted = Color(0xFF64748B);     // Slate 500
  static const Color zinc400 = Color(0xFF94A3B8);       // Slate 400
  static const Color zinc500 = Color(0xFF64748B);       // Slate 500
  static const Color zinc600 = Color(0xFF475569);       // Slate 600
  static const Color zinc700 = Color(0xFF334155);       // Slate 700
  static const Color zinc100 = Color(0xFFF1F5F9);       // Slate 100
  static const Color zinc50 = Color(0xFFF8FAFC);        // Slate 50

  // Status & Tags
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEF2F2);
}

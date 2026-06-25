import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const primary = Color(0xFF1A56DB);
  static const primaryLight = Color(0xFF3B82F6);
  static const primaryDark = Color(0xFF1E3A8A);

  // Surface
  static const background = Color(0xFFEEF2F7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF8FAFC);
  static const sidebarBg = Color(0xFF1E293B);
  static const sidebarActive = Color(0xFF2D3E50);

  // Status
  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFFD1FAE5);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEE2E2);
  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFFDBEAFE);

  // Text
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);
  static const textOnDark = Color(0xFFFFFFFF);
  static const textOnDarkMuted = Color(0xFF94A3B8);

  // Border
  static const border = Color(0xFFE2E8F0);
  static const borderLight = Color(0xFFF1F5F9);

  // Accent chips
  static const chipBlue = Color(0xFFDBEAFE);
  static const chipGreen = Color(0xFFD1FAE5);
  static const chipAmber = Color(0xFFFEF3C7);
  static const chipRed = Color(0xFFFEE2E2);
  static const chipPurple = Color(0xFFEDE9FE);

  // Dashboard stat cards
  static const statCard1 = Color(0xFFEBF5FF);
  static const statCard2 = Color(0xFFF0FDF4);
  static const statCard3 = Color(0xFFFFF7ED);
  static const statCard4 = Color(0xFFFDF4FF);

  /// Shared elevated card style for chit detail sections.
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      );
}

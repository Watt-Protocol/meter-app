import 'package:flutter/material.dart';

/// WATT Smart Meter brand color palette — Black & Gold
class AppColors {
  AppColors._();

  // ── Primary Gold ────────────────────────────────────────────
  static const Color gold = Color(0xFFFFD700);
  static const Color darkGold = Color(0xFFDAA520);
  static const Color lightGold = Color(0xFFFFE44D);
  static const Color mutedGold = Color(0xFFB8960C);
  static const Color goldWithOpacity = Color(0x33FFD700); // 20%

  // ── Backgrounds ─────────────────────────────────────────────
  static const Color scaffoldBg = Color(0xFF0A0A0A);
  static const Color cardBg = Color(0xFF141414);
  static const Color cardBgElevated = Color(0xFF1A1A1A);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color bottomNavBg = Color(0xFF0F0F0F);

  // ── Text ────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF6B6B6B);
  static const Color textGold = Color(0xFFFFD700);

  // ── Status ──────────────────────────────────────────────────
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFA726);

  // ── Input / Border ──────────────────────────────────────────
  static const Color inputBorder = Color(0xFF2A2A2A);
  static const Color inputFocusBorder = Color(0xFFFFD700);
  static const Color divider = Color(0xFF222222);

  // ── Light theme surfaces ────────────────────────────────────
  static const Color scaffoldBgLight = Color(0xFFF5F5F5);
  static const Color cardBgLight = Color(0xFFFFFFFF);
  static const Color cardBgElevatedLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFEEEEEE);
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF555555);
  static const Color textMutedLight = Color(0xFF888888);
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color inputBorderLight = Color(0xFFCCCCCC);

  // ── Gradients ───────────────────────────────────────────────
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradientVertical = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF141414)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleGoldGlow = LinearGradient(
    colors: [Color(0x1AFFD700), Color(0x00FFD700)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

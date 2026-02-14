import 'package:flutter/material.dart';

/// All app colors defined centrally.
class AppColors {
  AppColors._();

  // ─── PRIMARY PALETTE ──────────────────────────────────────
  static const Color primary = Color(0xFFD32F2F); // deep red — SOS theme
  static const Color primaryDark = Color(0xFF9A0007); // darker red
  static const Color primaryLight = Color(0xFFFF6659); // lighter red

  // ─── BACKGROUND ───────────────────────────────────────────
  static const Color background = Color(0xFF0D0D0D); // near black
  static const Color surface = Color(0xFF1A1A1A); // dark surface
  static const Color surfaceVariant = Color(0xFF2A2A2A); // slightly lighter

  // ─── TEXT ─────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textHint = Color(0xFF666666);

  // ─── STATUS ───────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF2196F3);

  // ─── SOS SPECIFIC ─────────────────────────────────────────
  static const Color sosButton = Color(0xFFD32F2F);
  static const Color sosPulse = Color(0x44D32F2F); // semi-transparent red
  static const Color cancelButton = Color(0xFF4CAF50);

  // ─── MISC ─────────────────────────────────────────────────
  static const Color divider = Color(0xFF2A2A2A);
  static const Color cardBorder = Color(0xFF333333);
  static const Color inputFill = Color(0xFF1E1E1E);
}

import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF080808);
  static const Color surface = Color(0xFF111111);
  static const Color card = Color(0xFF161616);
  static const Color border = Color(0xFF1E1E1E);
  static const Color accent = Color(0xFF22C55E);
  static const Color accentDim = Color(0x1F22C55E);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF888888);
  static const Color textMuted = Color(0xFF444444);

  // Genre colors
  static const Color pop = Color(0xFFF472B6);
  static const Color rap = Color(0xFFA78BFA);
  static const Color rnb = Color(0xFF34D399);
  static const Color rock = Color(0xFFFB923C);
  static const Color electro = Color(0xFF38BDF8);
  static const Color nasheed = Color(0xFF22C55E);
}

class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
  );

  static const TextStyle trackTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle trackSub = TextStyle(
    color: AppColors.textMuted,
    fontSize: 12,
  );

  static const TextStyle label = TextStyle(
    color: AppColors.textMuted,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'button_enums.dart';

class ButtonStyleConfig {
  // HEIGHT
  static double height(EButtonSize size) {
    switch (size) {
      case EButtonSize.small:
        return 40;
      case EButtonSize.medium:
        return 48;
      case EButtonSize.large:
        return 56;
    }
  }

  // FONT SIZE
  static double fontSize(EButtonSize size) {
    switch (size) {
      case EButtonSize.small:
        return 14;
      case EButtonSize.medium:
        return 16;
      case EButtonSize.large:
        return 18;
    }
  }

  // PADDING
  static EdgeInsets padding(EButtonSize size) {
    switch (size) {
      case EButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12);
      case EButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16);
      case EButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20);
    }
  }

  // BACKGROUND
  static Color background(EButtonType type, bool isDisabled) {
    if (isDisabled) return AppColors.disabled;

    switch (type) {
      case EButtonType.primary:
        return AppColors.primary;
      case EButtonType.secondary:
        return AppColors.secondary;
      case EButtonType.outlined:
      case EButtonType.outlinedSecondary:
        return Colors.transparent;
    }
  }

  // TEXT COLOR
  static Color textColor(EButtonType type) {
    switch (type) {
      case EButtonType.primary:
      case EButtonType.secondary:
        return Colors.white;
      case EButtonType.outlined:
        return AppColors.primary;
      case EButtonType.outlinedSecondary:
        return AppColors.secondary;
    }
  }

  // BORDER
  static Color border(EButtonType type) {
    switch (type) {
      case EButtonType.outlined:
        return AppColors.primary;
      case EButtonType.outlinedSecondary:
        return AppColors.secondary;
      default:
        return Colors.transparent;
    }
  }
}

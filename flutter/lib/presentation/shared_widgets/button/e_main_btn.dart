import 'package:flutter/material.dart';

import 'btn_style_config.dart';
import 'button_enums.dart';

class EMainButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final EButtonSize size;
  final EButtonType type;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? width;

  const EMainButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.size = EButtonSize.medium,
    this.type = EButtonType.primary,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: width ?? double.infinity,
      height: ButtonStyleConfig.height(size),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ButtonStyleConfig.background(type, isDisabled),
          elevation: 0,
          padding: ButtonStyleConfig.padding(size),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: ButtonStyleConfig.border(type)),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: ButtonStyleConfig.fontSize(size),
                      fontWeight: FontWeight.w600,
                      color: ButtonStyleConfig.textColor(type),
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 8),
                    suffixIcon!,
                  ],
                ],
              ),
      ),
    );
  }
}

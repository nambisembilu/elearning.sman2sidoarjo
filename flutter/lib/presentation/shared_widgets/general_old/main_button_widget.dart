import 'package:flutter/material.dart';

class MainButtonWidget extends StatelessWidget {
  final VoidCallback? btnAction;
  final String btnTitle;
  final bool disabled;

  const MainButtonWidget({
    super.key,
    required this.btnAction,
    required this.btnTitle,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: disabled ? null : btnAction, // 👈 disable button
      style: ElevatedButton.styleFrom(
        backgroundColor: disabled
            ? Colors
                  .grey
                  .shade400 // 👈 warna saat disabled
            : const Color(0xff016EB3),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // 👈 bikin kotak
        ),
      ),
      child: Text(btnTitle, style: TextStyle(color: Colors.white)),
    );
  }
}

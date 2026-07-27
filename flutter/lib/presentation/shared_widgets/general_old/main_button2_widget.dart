import 'package:flutter/material.dart';

class MainButton2Widget extends StatelessWidget {
  final VoidCallback? btnAction;
  final String btnTitle;

  // ⬇ parameter baru
  final Color? btnColor; // warna tombol
  final bool isDisabled; // disable button

  const MainButton2Widget({
    super.key,
    required this.btnAction,
    required this.btnTitle,
    this.btnColor,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isDisabled ? null : btnAction, // ⬅ disable logic
      style: ElevatedButton.styleFrom(
        backgroundColor: btnColor,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      child: Text(btnTitle, style: const TextStyle(color: Colors.white)),
    );
  }
}

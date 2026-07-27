import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ButtonAddWidget extends StatelessWidget {
  final VoidCallback? addAction;

  const ButtonAddWidget({super.key, required this.addAction});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: addAction,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff016EB3),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        minimumSize: const Size(120, 50),
      ),
      icon: const Icon(Symbols.add_circle),
      label: Text('Tambah'),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class DialogErrorWidget extends StatelessWidget {
  final String errorText;

  const DialogErrorWidget({super.key, required this.errorText});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.warning, size: 100, color: Colors.red[700]),
            SizedBox(height: 10),
            Text(
              errorText,
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff016EB3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('OK'),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class DialogKonfirmasiWidget extends StatelessWidget {
  final String confirmText;
  final VoidCallback? confirmAction;

  const DialogKonfirmasiWidget({
    super.key,
    required this.confirmText,
    required this.confirmAction,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Center(
        child: const Text(
          'Konfirmasi',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.info, size: 100, color: Colors.grey[400]),
            SizedBox(height: 10),
            Text(
              confirmText,
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff016EB3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: confirmAction,
                child: const Text('Lanjutkan'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class DialogTimerHabisWidget extends StatefulWidget {
  const DialogTimerHabisWidget({super.key});

  @override
  State<DialogTimerHabisWidget> createState() => _DialogTimerHabisWidgetState();
}

class _DialogTimerHabisWidgetState extends State<DialogTimerHabisWidget> {
  @override
  void initState() {
    super.initState();
    // Auto close setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

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
            Icon(Symbols.history_toggle_off, size: 80, color: Colors.red),
            SizedBox(height: 10),
            Text(
              "Waktu telah habis ! Jawaban akan disubmit...",
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
    );
  }
}

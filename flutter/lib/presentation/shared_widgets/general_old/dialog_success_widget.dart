import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class DialogSuccessWidget extends StatefulWidget {
  final String succesText;

  const DialogSuccessWidget({super.key, required this.succesText});

  @override
  State<DialogSuccessWidget> createState() => _DialogSuccessWidgetState();
}

class _DialogSuccessWidgetState extends State<DialogSuccessWidget> {
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
            Icon(Symbols.task_alt, size: 80, color: Colors.green[900]),
            SizedBox(height: 10),
            Text(
              widget.succesText,
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

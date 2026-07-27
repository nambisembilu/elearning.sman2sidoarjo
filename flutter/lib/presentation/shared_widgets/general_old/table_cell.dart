import 'package:flutter/material.dart';

class TableCellWidget extends StatelessWidget {
  final String text;
  const TableCellWidget(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(text, style: TextStyle(color: Colors.black87, fontSize: 12)),
    );
  }
}

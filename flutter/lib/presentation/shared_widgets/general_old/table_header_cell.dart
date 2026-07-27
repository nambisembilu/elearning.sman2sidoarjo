import 'package:flutter/material.dart';

class TableHeaderCell extends StatelessWidget {
  final String text;
  const TableHeaderCell(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }
}

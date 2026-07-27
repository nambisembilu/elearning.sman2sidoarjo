import 'package:flutter/material.dart';

class Header2Widget extends StatelessWidget {
  final String header2Title;
  final String subtitle;

  const Header2Widget({
    super.key,
    required this.header2Title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header2Title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}

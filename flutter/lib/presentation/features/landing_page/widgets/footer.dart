import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      color: const Color(0xFF0062b3),
      child: const Column(
        children: [
          Text(
            '© 2024 E-Learning SMAN 2 Sidoarjo',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            'Sistem Pembelajaran Digital Terpadu',
            style: TextStyle(
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

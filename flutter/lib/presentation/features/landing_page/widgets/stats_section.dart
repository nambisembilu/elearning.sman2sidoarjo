import 'package:flutter/material.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  final List<Map<String, dynamic>> stats = const [
    {'value': '1500+', 'label': 'Siswa Aktif'},
    {'value': '100+', 'label': 'Guru Pengguna'},
    {'value': '5000+', 'label': 'Tugas Terkirim'},
    {'value': '24/7', 'label': 'Akses Platform'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      color: const Color(0xFF0062b3),
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Wrap(
              spacing: 30,
              runSpacing: 30,
              alignment: WrapAlignment.spaceEvenly,
              children: stats.map((stat) {
                return Container(
                  width: 200,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        stat['value'],
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        stat['label'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

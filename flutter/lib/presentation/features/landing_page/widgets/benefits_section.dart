import 'package:flutter/material.dart';

class BenefitsSection extends StatelessWidget {
  const BenefitsSection({super.key});

  final List<Map<String, dynamic>> benefits = const [
    {
      'title': 'Pembelajaran Fleksibel',
      'description': 'Akses materi kapan saja dan di mana saja',
    },
    {
      'title': 'Efisiensi Waktu',
      'description':
          'Hemat waktu dalam pengumpulan tugas dan distribusi materi',
    },
    {
      'title': 'Monitoring Real-time',
      'description': 'Pantau perkembangan belajar siswa secara langsung',
    },
    {
      'title': 'Komunikasi Efektif',
      'description':
          'Interaksi yang lebih baik antara guru, siswa, dan orang tua',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                const Text(
                  'Manfaat Menggunakan E-Learning',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0062b3),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 100,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0062b3), Color(0xFFFF9800)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Wrap(
              spacing: 24,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: benefits.map((benefit) {
                return Container(
                  width: 280,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFf8fbff),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFF0062b3).withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 50,
                        color: Color(0xFFFF9800),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        benefit['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0062b3),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        benefit['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
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

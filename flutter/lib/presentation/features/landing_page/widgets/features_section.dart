import 'package:flutter/material.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  final List<Map<String, dynamic>> eLearningFeatures = const [
    {
      'icon': Icons.assignment,
      'title': 'Tugas Online',
      'description':
          'Kirim dan kumpulkan tugas secara digital dengan deadline yang jelas',
      'color': Color(0xFF0062b3),
    },
    {
      'icon': Icons.library_books,
      'title': 'Materi Pembelajaran',
      'description': 'Akses materi pembelajaran lengkap dalam format digital',
      'color': Colors.green,
    },
    {
      'icon': Icons.forum,
      'title': 'Forum Diskusi',
      'description':
          'Diskusikan materi dengan guru dan teman sekelas secara online',
      'color': Colors.orange,
    },
    {
      'icon': Icons.quiz,
      'title': 'Ujian Online',
      'description': 'Ikuti ujian dan tes dengan sistem penilaian otomatis',
      'color': Colors.purple,
    },
    {
      'icon': Icons.notifications,
      'title': 'Notifikasi',
      'description':
          'Dapatkan pemberitahuan tugas, ujian, dan pengumuman penting',
      'color': Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: const Color(0xFFf8fbff),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                const Text(
                  'Fitur Utama E-Learning',
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
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Wrap(
              spacing: 24,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: eLearningFeatures.map((feature) {
                return Container(
                  width: 280,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: (feature['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          feature['icon'],
                          size: 40,
                          color: feature['color'],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        feature['title'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0062b3),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        feature['description'],
                        style: TextStyle(
                          fontSize: 15,
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

import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

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
                  'Apa itu E-Learning SMANDA?',
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
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  margin: const EdgeInsets.only(bottom: 30),
                  decoration: BoxDecoration(
                    color: const Color(0xFFf0f7ff),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF0062b3).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.school,
                        size: 60,
                        color: Color(0xFF0062b3),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'E-Learning SMANDA adalah platform pembelajaran digital resmi SMAN 2 Sidoarjo yang dirancang untuk memfasilitasi proses belajar mengajar secara online dengan fitur-fitur lengkap dan mudah digunakan.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tujuan Pengembangan:',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0062b3),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildPurposeItem(
                      'Menyediakan sistem pembelajaran digital yang terintegrasi',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildPurposeItem(
                      'Mempermudah distribusi materi dan pengumpulan tugas',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildPurposeItem(
                      'Meningkatkan interaksi antara guru dan siswa',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildPurposeItem(
                      'Memantau perkembangan belajar siswa secara real-time',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurposeItem(String text, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

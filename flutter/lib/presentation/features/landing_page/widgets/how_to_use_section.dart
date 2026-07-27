import 'package:flutter/material.dart';

import 'dialogs/login_dialog.dart';

class HowToUseSection extends StatelessWidget {
  const HowToUseSection({super.key});

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
                  'Cara Menggunakan E-Learning',
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
                _buildStepCard(
                  1,
                  'Login',
                  'Gunakan akun yang diberikan sekolah untuk masuk ke sistem',
                ),
                _buildStepCard(
                  2,
                  'Akses Kelas',
                  'Pilih kelas yang diikuti untuk melihat materi dan tugas',
                ),
                _buildStepCard(
                  3,
                  'Pelajari Materi',
                  'Baca dan pelajari materi yang disediakan guru',
                ),
                _buildStepCard(
                  4,
                  'Kerjakan Tugas/Ujian',
                  'Kerjakan tugas dan ujian sesuai deadline',
                ),
                _buildStepCard(
                  5,
                  'Diskusi',
                  'Gunakan forum untuk bertanya dan berdiskusi',
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => LoginDialog(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0062b3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 8,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.login),
                    SizedBox(width: 10),
                    Text(
                      'Masuk Sekarang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(int number, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF0062b3),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0062b3),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/enums/role_user_enum.dart';
import '../../../core/routes/routes_name.dart';

class RoleSelectionScreen extends StatelessWidget {
  RoleSelectionScreen({super.key});

  final List<Map<String, dynamic>> roles = [
    {
      'role': UserRole.siswa,
      'name': 'Siswa',
      'icon': Icons.school,
      'color': Color(0xFF2196F3),
      'description': 'Akses materi, tugas, dan ujian',
    },
    {
      'role': UserRole.guru,
      'name': 'Guru',
      'icon': Icons.person,
      'color': Color(0xFF4CAF50),
      'description': 'Kelola kelas, tugas, dan nilai',
    },
    {
      'role': UserRole.staff,
      'name': 'Staff Kurikulum',
      'icon': Icons.folder_special,
      'color': Color(0xFFFF9800),
      'description': 'Kelola kurikulum dan jadwal',
    },
    {
      'role': UserRole.admin,
      'name': 'Admin',
      'icon': Icons.admin_panel_settings,
      'color': Color(0xFF9C27B0),
      'description': 'Kelola sistem dan pengguna',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF0062b3), const Color(0xFF2196F3)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.school,
                      size: 40,
                      color: Color(0xFF0062b3),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pilih Role Anda',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Silakan pilih peran Anda untuk melanjutkan',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Role Cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                itemCount: roles.length,
                itemBuilder: (context, index) {
                  final role = roles[index];
                  return _buildRoleCard(
                    context,
                    role['name'],
                    role['role'],
                    role['icon'],
                    role['color'],
                    role['description'],
                  );
                },
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'SMAN 2 Sidoarjo © 2024',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    String roleName,
    UserRole role,
    IconData icon,
    Color color,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: () {
            context.push(
              RoutesNames.login,
              extra: role, // ✅ kirim enum
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, size: 40, color: color),
                ),
                const SizedBox(width: 20),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roleName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

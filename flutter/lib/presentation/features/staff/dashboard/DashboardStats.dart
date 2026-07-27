import 'package:flutter/material.dart';

class DashboardStats extends StatelessWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 800
                    ? 4
                    : constraints.maxWidth > 600
                        ? 3
                        : 2;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                  children: [
                    _buildStatCard(
                      context,
                      title: 'Total Siswa',
                      value: '1,245',
                      subtitle: '+15 dari bulan lalu',
                      icon: Icons.people_alt_outlined,
                      color: Colors.blue,
                    ),
                    _buildStatCard(
                      context,
                      title: 'Total Guru',
                      value: '68',
                      subtitle: '+2 dari bulan lalu',
                      icon: Icons.school_outlined,
                      color: Colors.green,
                    ),
                    _buildStatCard(
                      context,
                      title: 'Mata Pelajaran',
                      value: '24',
                      subtitle: 'Semester Ganjil 2023/2024',
                      icon: Icons.menu_book_outlined,
                      color: Colors.orange,
                    ),
                    _buildStatCard(
                      context,
                      title: 'Total Kelas',
                      value: '36',
                      subtitle: 'Tahun Ajaran 2023/2024',
                      icon: Icons.class_outlined,
                      color: Colors.purple,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const Spacer(),
            LinearProgressIndicator(
              value: 0.7,
              backgroundColor: color.withOpacity(0.1),
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}

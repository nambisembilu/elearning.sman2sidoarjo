// ignore_for_file: use_build_context_synchronously
import 'package:elearning_sman2sidoarjo/core/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../models/guru/daftar_pengumpulan_tugas.dart';

class ListCardPengumpulanTugasWidget extends ConsumerWidget {
  final List<DaftarPengumpulanTugas> daftarPengumpulanTugas;
  const ListCardPengumpulanTugasWidget({
    super.key,
    required this.daftarPengumpulanTugas,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: daftarPengumpulanTugas.length,
      itemBuilder: (context, index) {
        final pengumpulanTugas = daftarPengumpulanTugas[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bagian kiri: Foto profil dan info siswa
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          pengumpulanTugas.namaSiswa.isNotEmpty
                              ? pengumpulanTugas.namaSiswa[0].toUpperCase()
                              : 'S',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pengumpulanTugas.namaSiswa,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'NIS: ${pengumpulanTugas.nis}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (pengumpulanTugas.statusPengumpulan ==
                                'Belum Mengumpulkan')
                              Text(
                                'Belum Mengumpulkan',
                                style: TextStyle(color: Colors.orange),
                              ),
                            if (pengumpulanTugas.statusPengumpulan ==
                                'Tepat Waktu')
                              Text(
                                'Dikumpulkan Tepat Waktu',
                                style: TextStyle(color: Colors.green),
                              ),
                            if (pengumpulanTugas.statusPengumpulan ==
                                'Terlambat')
                              Text(
                                'Dikumpulkan Terlambat',
                                style: TextStyle(color: Colors.red),
                              ),
                            if (pengumpulanTugas.nilai != null &&
                                pengumpulanTugas.nilai! > 0)
                              const SizedBox(height: 4),
                            if (pengumpulanTugas.nilai != null &&
                                pengumpulanTugas.nilai! > 0)
                              Text(
                                'Nilai: ${pengumpulanTugas.nilai}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (pengumpulanTugas.statusPengumpulan != 'Belum Mengumpulkan')
                  IconButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt(
                        'pengumpulanTugasId',
                        pengumpulanTugas.pengumpulanTugasId!,
                      );
                      await prefs.setString(
                        'namaSiswa',
                        pengumpulanTugas.namaSiswa,
                      );
                      await prefs.setString(
                        'nilaiSiswa',
                        pengumpulanTugas.nilai.toString(),
                      );
                      await prefs.setString(
                        'feedback',
                        pengumpulanTugas.feedback ?? '',
                      );
                      final kelasMapelId = prefs.getInt(
                        'kelasMapelId',
                      ); // hasilnya bisa null

                      context.go(RoutesNames.penilaianTugas);
                    },
                    icon: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

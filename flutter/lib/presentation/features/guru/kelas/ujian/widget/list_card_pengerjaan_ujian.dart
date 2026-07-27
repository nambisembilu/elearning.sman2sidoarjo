// ignore_for_file: use_build_context_synchronously

import 'package:elearning_sman2sidoarjo/core/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../models/guru/daftar_pengerjaan_ujian.dart';

class ListCardPengerjaanUjianWidget extends ConsumerWidget {
  final List<DaftarPengerjaanUjian> daftarPengumpulanUjian;
  const ListCardPengerjaanUjianWidget({
    super.key,
    required this.daftarPengumpulanUjian,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: daftarPengumpulanUjian.length,
      itemBuilder: (context, index) {
        final pengerjaanUjian = daftarPengumpulanUjian[index];

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
                          pengerjaanUjian.namaSiswa.isNotEmpty
                              ? pengerjaanUjian.namaSiswa[0].toUpperCase()
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
                              pengerjaanUjian.namaSiswa,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'NIS: ${pengerjaanUjian.nis}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (pengerjaanUjian.nilai != null &&
                                pengerjaanUjian.nilai! > 0)
                              const SizedBox(height: 4),
                            if (pengerjaanUjian.nilai != null &&
                                pengerjaanUjian.nilai! > 0)
                              Text(
                                'Nilai: ${pengerjaanUjian.nilai}',
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
                if (pengerjaanUjian.sudahMengerjakan)
                  IconButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      // await prefs.setInt('ujianId', ujian.ujianId);
                      await prefs.setInt(
                        'userIdSiswa',
                        pengerjaanUjian.userIdSiswa,
                      );
                      final kelasMapelId = prefs.getInt('kelasMapelId');

                      context.go(RoutesNames.detailPengerjaanUjian);
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

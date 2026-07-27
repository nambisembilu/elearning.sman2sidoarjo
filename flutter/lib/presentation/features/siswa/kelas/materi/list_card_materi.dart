import 'package:elearning_sman2sidoarjo/core/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../models/siswa/materi_kelas_model.dart';

class ListCardMateri extends StatelessWidget {
  final List<MateriKelas> daftarMateri;
  const ListCardMateri({super.key, required this.daftarMateri});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: daftarMateri.length,
      itemBuilder: (context, index) {
        final materi = daftarMateri[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bagian kiri: Foto profil dan info ujian
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('materiId', materi.materiId);
                      final kelasMapelId = prefs.getInt(
                        'kelasMapelId',
                      ); // hasilnya bisa null

                      // context.go(
                      //   '/dashboard/siswa/kelas/$kelasMapelId/detail-materi',
                      //   // extra: true, // Mark as coming from detail screen
                      // );
                      context.go(RoutesNames.detailMateriSiswa);
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(
                            Symbols.file_copy,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                materi.judulMateri,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Tanggal ${materi.tanggalDibuat}",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

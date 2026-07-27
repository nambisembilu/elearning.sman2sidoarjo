import 'package:elearning_sman2sidoarjo/core/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../models/siswa/ujian_model.dart';

class ListCardUjian extends StatelessWidget {
  final List<UjianKelas> daftarUjian;
  const ListCardUjian({super.key, required this.daftarUjian});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: daftarUjian.length,
      itemBuilder: (context, index) {
        final ujian = daftarUjian[index];
        return InkWell(
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('ujianId', ujian.ujianId);

            final kelasMapelId = prefs.getInt(
              'kelasMapelId',
            ); // hasilnya bisa null

            context.go(RoutesNames.detailUjianSiswa);
          },
          child: Padding(
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
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(
                            Symbols.quiz,
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
                                ujian.judulDefault,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Tanggal ${ujian.tanggalujian}",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Pukul (${ujian.jamMulai} - ${ujian.jamSelesai})",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tombol message
                  // IconButton(
                  //   onPressed: () {
                  //     // Aksi untuk mengirim pesan
                  //   },
                  //   icon: Icon(Symbols.menu, color: Colors.blue),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

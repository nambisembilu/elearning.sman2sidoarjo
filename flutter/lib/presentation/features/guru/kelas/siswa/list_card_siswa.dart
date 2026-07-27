import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../models/guru/siswa_kelas_mapel_model.dart';

class ListCardSiswaWidget extends StatelessWidget {
  final List<SiswaKelas> daftarSiswa;
  const ListCardSiswaWidget({super.key, required this.daftarSiswa});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: daftarSiswa.length,
      itemBuilder: (context, index) {
        final siswa = daftarSiswa[index];
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
                // Bagian kiri: Foto profil dan info siswa
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(
                          Symbols.person,
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
                              siswa.namaSiswa,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "NIS/NISN: ${siswa.nis.toString()}/${siswa.nisn.toString()}",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              siswa.emailSiswa,
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
                //   icon: Icon(Symbols.message, color: Colors.blue),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}

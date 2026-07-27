import 'package:flutter/material.dart';

import '../../../../../models/guru/siswa_kelas_mapel_model.dart';

class ListSiswaNonKelompokWidget extends StatelessWidget {
  final List<dynamic>
  listData; // Ubah menjadi dynamic untuk menerima kedua tipe
  final Function(int, String) btnAction;
  final bool isKelompok;

  const ListSiswaNonKelompokWidget({
    super.key,
    required this.listData,
    required this.btnAction,
    required this.isKelompok,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: listData.length,
      itemBuilder: (context, index) {
        // Handle kedua tipe data
        String nama;
        int id;

        if (listData[index] is SiswaKelas) {
          nama = (listData[index] as SiswaKelas).namaSiswa;
          id = (listData[index] as SiswaKelas).siswaId;
        } else if (listData[index] is Map<String, dynamic>) {
          nama = listData[index]['nama'];
          id = listData[index]['siswa_id'];
        } else {
          return SizedBox(); // Fallback
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(nama),
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: FloatingActionButton(
                      backgroundColor: isKelompok
                          ? Colors.red
                          : const Color(0xff016EB3),
                      onPressed: () {
                        btnAction(id, nama);
                      },
                      child: isKelompok
                          ? Icon(Icons.remove, color: Colors.white, size: 15)
                          : Icon(Icons.add, color: Colors.white, size: 15),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
          ],
        );
      },
    );
  }
}

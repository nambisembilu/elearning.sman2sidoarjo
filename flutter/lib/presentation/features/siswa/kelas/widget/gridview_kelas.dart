import 'package:elearning_sman2sidoarjo/core/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../models/siswa/kelas_siswa_model.dart';
import '../../../../controllers/siswa/kelas/kelas_siswa_riverpod.dart';

class GridviewKelasWidget extends ConsumerWidget {
  final List<KelasSiswa> daftarKelasSiswa;

  const GridviewKelasWidget({super.key, required this.daftarKelasSiswa});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true, // biar bisa dalam SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 500, // lebar maksimum satu item
        crossAxisSpacing: 20,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6, // proporsi tinggi-lebar item
      ),
      itemCount: daftarKelasSiswa.length,
      itemBuilder: (context, index) {
        final kelas = daftarKelasSiswa[index];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kelas.judulMapel,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 12, 129, 225),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      "Pengampu : ${kelas.guruPengampu}",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Symbols.import_contacts, size: 16),
                          SizedBox(width: 10),
                          Text('${kelas.jumlahMateri.toString()} Materi'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Symbols.assignment, size: 16),
                          SizedBox(width: 10),
                          Text('${kelas.jumlahTugas.toString()} Tugas'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Symbols.quiz, size: 16),
                          SizedBox(width: 10),
                          Text('${kelas.jumlahUjian.toString()} Ujian'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              // SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey, // warna abu-abu
                      thickness: 1, // ketebalan garis
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () async {
                      // Simpan kelasMapelId ke SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('kelasMapelId', kelas.kelasMapelId);
                      ref
                          .read(kelasSiswaNotifierProvider.notifier)
                          .setSelectedKmp();
                      // Pastikan widget masih mounted sebelum pakai context
                      if (!context.mounted) return;

                      // context.go(
                      //   '/dashboard/siswa/kelas/${kelas.kelasMapelId}',
                      //   // extra: selectedKelas,
                      // );
                      context.go(RoutesNames.detailKelasSiswa);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(
                        255,
                        12,
                        129,
                        225,
                      ), // warna teks
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    child: Text("Lihat Detail"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

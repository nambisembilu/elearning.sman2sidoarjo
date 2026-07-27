// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/helper/shared_pref_helper.dart';
import '../../../../../core/routes/routes_name.dart';
import '../../../../../models/guru/kelas_guru_model.dart';
import '../../../../controllers/guru/kelas_guru_riverpod.dart';

class GridviewKelasWidget extends ConsumerWidget {
  final List<KelasGuru> daftarKelasGuru;

  const GridviewKelasWidget({super.key, required this.daftarKelasGuru});

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
      itemCount: daftarKelasGuru.length,
      itemBuilder: (context, index) {
        final kelas = daftarKelasGuru[index];

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 12, 129, 225),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      kelas.judulMapel,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        Icon(Symbols.group, size: 16),
                        SizedBox(width: 5),
                        Text(
                          kelas.jumlahSiswa.toString(),
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kelas.namaKelas,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      await SharedPrefHelper.saveKelasMapelId(
                        kelas.kelasMapelId,
                      );

                      // final prefs = await SharedPreferences.getInstance();
                      // await prefs.setInt('kelasMapelId', kelas.kelasMapelId);

                      ref
                          .read(kelasGuruNotifierProvider.notifier)
                          .setSelectedKmp();
                      // Pastikan widget masih mounted sebelum pakai context
                      if (!context.mounted) return;

                      // context.go(
                      //   '/dashboard/guru/kelas/${kelas.kelasMapelId}',
                      //   // extra: selectedKelas,
                      // );

                      context.go(RoutesNames.detailKelas);
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

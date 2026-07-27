// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../models/guru/kelompok_belajar_model.dart';
import '../../../../controllers/guru/konten_kelas/kelompok_belajar_riverpod.dart';
import '../../../../shared_widgets/general_old/dialog_konfirmasi_widget.dart';
import '../../../../shared_widgets/general_old/dialog_success_widget.dart';
import 'dialog_tambah_or_edit_kelompok.dart';

class ListCardKelompokWidget extends ConsumerWidget {
  final List<KelompokBelajar> daftarKelompok;

  const ListCardKelompokWidget({super.key, required this.daftarKelompok});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: daftarKelompok.length,
      itemBuilder: (context, index) {
        final kelompok = daftarKelompok[index];
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
                          Symbols.groups,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kelompok.namaKelompok,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Jumlah anggota : ${kelompok.jumlahAnggota.toString()}",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => DialogKonfirmasiWidget(
                            confirmText:
                                "Apakah anda yakin ingin menghapus ${kelompok.namaKelompok}? Urutan kelompok akan diatur ulang.",
                            confirmAction: () async {
                              try {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                final success = await ref
                                    .read(
                                      kelompokBelajarRiverpodProvider.notifier,
                                    )
                                    .deleteKelompok(
                                      kelompokId: int.parse(
                                        kelompok.kelompokBelajarId.toString(),
                                      ),
                                    );

                                // Remove loading indicator
                                Navigator.pop(context);

                                if (success) {
                                  // Close dialog
                                  Navigator.pop(context);

                                  showDialog(
                                    context: context,
                                    builder: (context) => DialogSuccessWidget(
                                      succesText: 'Kelompok berhasil dihapus',
                                    ),
                                  );
                                }
                              } catch (e) {
                                // Remove loading indicator
                                Navigator.pop(context);
                              }
                            },
                          ),
                        );
                      },
                      icon: Icon(Symbols.delete),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => DialogTambahOrEditKelompok(
                            dataKelompok: kelompok,
                          ),
                        );
                      },
                      icon: Icon(Symbols.edit),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

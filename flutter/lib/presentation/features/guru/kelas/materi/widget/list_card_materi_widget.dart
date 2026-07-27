// ignore_for_file: use_build_context_synchronously, avoid_print
import 'package:elearning_sman2sidoarjo/core/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../models/guru/materi_kelas_model.dart';
import '../../../../../controllers/guru/materi/materi_kelas_riverpod.dart';
import '../../../../../shared_widgets/general_old/dialog_konfirmasi_widget.dart';
import '../../../../../shared_widgets/general_old/dialog_success_widget.dart';

class ListCardMateri extends ConsumerWidget {
  final List<MateriKelas> daftarMateri;

  const ListCardMateri({super.key, required this.daftarMateri});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                // Bagian kiri: Foto profil dan info materi
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('materiId', materi.materiId);
                      final kelasMapelId = prefs.getInt(
                        'kelasMapelId',
                      ); // hasilnya bisa null

                      context.go(RoutesNames.pratinjauMateri);
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

                // Tombol menu dengan popup
                PopupMenuButton<String>(
                  icon: Icon(Symbols.menu, color: Colors.blue),
                  onSelected: (value) async {
                    if (value == 'hapus') {
                      // onHapus(materi);
                      showDialog(
                        context: context,
                        builder: (context) => DialogKonfirmasiWidget(
                          confirmText:
                              "Apakah anda yakin ingin menghapus  ${materi.judulMateri}?",
                          confirmAction: () async {
                            try {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              // Ambil semua URL dari fileMateri
                              List<String> filesToDelete = materi.fileMateri
                                  .map((file) => file['link_file_materi'] ?? '')
                                  .where((url) => url.isNotEmpty)
                                  .toList();

                              final success = await ref
                                  .read(materiKelasRiverpodProvider.notifier)
                                  .deleteMateri(
                                    materiId: materi.materiId,
                                    filesToDelete: filesToDelete,
                                  );

                              // Remove loading indicator
                              Navigator.pop(context);

                              if (success) {
                                // Close dialog
                                Navigator.pop(context);

                                showDialog(
                                  context: context,
                                  builder: (context) => DialogSuccessWidget(
                                    succesText: 'Materi berhasil dihapus',
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
                    } else if (value == 'edit') {
                      // Aksi edit
                      print("Edit data");
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('materiId', materi.materiId);
                      final kelasMapelId = prefs.getInt('kelasMapelId');

                      context.go(RoutesNames.editMateri
                      );
                    } else if (value == 'sembunyikan') {
                      // Aksi hide
                      showDialog(
                        context: context,
                        builder: (context) => DialogKonfirmasiWidget(
                          confirmText:
                              "Apakah anda yakin ingin menyembunyikan materi '${materi.judulMateri}' ?",
                          confirmAction: () async {
                            // Tampilkan dialog loading
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );

                            try {
                              final success = await ref
                                  .read(materiKelasRiverpodProvider.notifier)
                                  .updateStatusMateri(
                                    materiId: materi.materiId,
                                    statusMateri: "Hide",
                                  );
                              Navigator.pop(context);

                              if (success) {
                                // Close dialog
                                Navigator.pop(context);

                                // Show success message
                                showDialog(
                                  context: context,
                                  builder: (context) => DialogSuccessWidget(
                                    succesText:
                                        "Status materi berhasil diperbarui",
                                  ),
                                );
                              }
                            } catch (e) {
                              // Remove loading indicator
                              Navigator.pop(context);

                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gagal memperbarui sttaus materi: ${e.toString()}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      );
                    } else if (value == 'tampilkan') {
                      // Aksi hide
                      showDialog(
                        context: context,
                        builder: (context) => DialogKonfirmasiWidget(
                          confirmText:
                              "Apakah anda yakin ingin menampilkan materi '${materi.judulMateri}' ?",
                          confirmAction: () async {
                            // Tampilkan dialog loading
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );

                            try {
                              final success = await ref
                                  .read(materiKelasRiverpodProvider.notifier)
                                  .updateStatusMateri(
                                    materiId: materi.materiId,
                                    statusMateri: "Visible",
                                  );
                              Navigator.pop(context);

                              if (success) {
                                // Close dialog
                                Navigator.pop(context);

                                // Show success message
                                showDialog(
                                  context: context,
                                  builder: (context) => DialogSuccessWidget(
                                    succesText:
                                        "Status materi berhasil diperbarui",
                                  ),
                                );
                              }
                            } catch (e) {
                              // Remove loading indicator
                              Navigator.pop(context);

                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gagal memperbarui sttaus materi: ${e.toString()}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Symbols.edit, size: 20, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: materi.statusMateri == "Visible"
                          ? 'sembunyikan'
                          : 'tampilkan',
                      child: SizedBox(
                        height: 15,
                        child: Row(
                          children: [
                            // Icon berubah sesuai status
                            Icon(
                              materi.statusMateri == "Visible"
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.red,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              materi.statusMateri == "Visible"
                                  ? 'Sembunyikan'
                                  : 'Tampilkan',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'hapus',
                      child: Row(
                        children: [
                          Icon(Symbols.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
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

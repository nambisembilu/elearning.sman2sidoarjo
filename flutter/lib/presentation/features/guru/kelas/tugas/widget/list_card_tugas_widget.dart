// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:elearning_sman2sidoarjo/core/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../models/guru/tugas_kelas_model.dart';
import '../../../../../controllers/guru/tugas/tugas_kelas_riverpod.dart';
import '../../../../../shared_widgets/general_old/dialog_konfirmasi_widget.dart';
import '../../../../../shared_widgets/general_old/dialog_success_widget.dart';

class ListCardTugas extends ConsumerWidget {
  final List<TugasKelas> daftarTugas;
  const ListCardTugas({super.key, required this.daftarTugas});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: daftarTugas.length,
      itemBuilder: (context, index) {
        final tugas = daftarTugas[index];
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
                      await prefs.setInt('tugasId', tugas.tugasId);
                      final kelasMapelId = prefs.getInt(
                        'kelasMapelId',
                      ); // hasilnya bisa null

                      context.go(RoutesNames.detailTugas);
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(
                            Symbols.assignment,
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
                                tugas.judulTugas,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Tanggal ${tugas.tanggalDibuat}",
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
                      // onHapus(ujian);
                      showDialog(
                        context: context,
                        builder: (context) => DialogKonfirmasiWidget(
                          confirmText:
                              "Apakah anda yakin ingin menghapus  '${tugas.judulTugas}'?",
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
                              List<String> filesToDelete = tugas.fileTugas
                                  .map((file) => file['link_file_tugas'] ?? '')
                                  .where((url) => url.isNotEmpty)
                                  .toList();

                              final success = await ref
                                  .read(tugasKelasRiverpodProvider.notifier)
                                  .deleteTugas(
                                    tugasId: tugas.tugasId,
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
                                    succesText: 'Tugas berhasil dihapus',
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
                      await prefs.setInt('tugasId', tugas.tugasId);
                      final kelasMapelId = prefs.getInt('kelasMapelId');

                      context.go(RoutesNames.editTugas
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

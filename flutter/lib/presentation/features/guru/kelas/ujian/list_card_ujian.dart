// ignore_for_file: use_build_context_synchronously

import 'package:elearning_sman2sidoarjo/core/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../models/guru/ujian_model.dart';
import '../../../../controllers/guru/ujian/ujian_kelas_riverpod.dart';
import '../../../../shared_widgets/general_old/dialog_konfirmasi_widget.dart';
import '../../../../shared_widgets/general_old/dialog_success_widget.dart';

class ListCardUjian extends ConsumerStatefulWidget {
  final List<UjianKelas> daftarUjian;

  const ListCardUjian({super.key, required this.daftarUjian});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ListCardUjianState();
}

class _ListCardUjianState extends ConsumerState<ListCardUjian> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.daftarUjian.length,
      itemBuilder: (context, index) {
        final ujian = widget.daftarUjian[index];
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
                              "Apakah anda yakin ingin menghapus ujian?",
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
                                  .read(ujianKelasRiverpodProvider.notifier)
                                  .deleteUjian(ujianId: ujian.ujianId);

                              // Remove loading indicator
                              Navigator.pop(context);

                              if (success) {
                                // Close dialog
                                Navigator.pop(context);

                                showDialog(
                                  context: context,
                                  builder: (context) => DialogSuccessWidget(
                                    succesText: 'Ujian berhasil dihapus',
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
                    } else if (value == 'lihat_pengerjaan') {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('ujianId', ujian.ujianId);
                      final kelasMapelId = prefs.getInt('kelasMapelId');

                      // context.go(
                      //   '/dashboard/guru/kelas/$kelasMapelId/lihat-pengerjaan-ujian',
                      //   // extra: true, // Mark as coming from detail screen
                      // );
                      context.go(RoutesNames.listPengerjaanUjian);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'lihat_pengerjaan',
                      child: Row(
                        children: [
                          Icon(Symbols.visibility, size: 20),
                          SizedBox(width: 8),
                          Text('Lihat Pengerjaan'),
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

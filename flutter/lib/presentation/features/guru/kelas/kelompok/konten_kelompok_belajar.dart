// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../controllers/guru/konten_kelas/kelompok_belajar_riverpod.dart';
import '../../../../shared_widgets/general_old/button_add_widget.dart';
import '../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../shared_widgets/general_old/header2_widget.dart';
import '../../../../shared_widgets/general_old/search_textfield_widget.dart';
import 'dialog_tambah_or_edit_kelompok.dart';
import 'list_card_kelompok.dart';

class KontenKelompokWidget extends ConsumerStatefulWidget {
  final String namaKelas;
  final int kelasMapelId;

  const KontenKelompokWidget({
    super.key,
    required this.namaKelas,
    required this.kelasMapelId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _KontenKelompokWidgetState();
}

class _KontenKelompokWidgetState extends ConsumerState<KontenKelompokWidget> {
  // void _navigateToTambahMateri(int kelasMapelId) {
  //   context.go(
  //     '/dashboard/guru/kelas/$kelasMapelId/tambah-materi',
  //     // extra: true, // Mark as coming from detail screen
  //   );
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final siswaKelasMapelState = ref.watch(kelompokBelajarRiverpodProvider);
    final notifier = ref.read(kelompokBelajarRiverpodProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[200]!, // warna border
              width: 1, // ketebalan border
            ),
            borderRadius: BorderRadius.circular(
              8,
            ), // opsional kalau mau rounded
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Header2Widget(
                        header2Title: "Daftar Kelompok",
                        subtitle:
                            "Daftar kelompok dalam kelas ${widget.namaKelas}",
                      ),
                      ButtonAddWidget(
                        addAction: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                const DialogTambahOrEditKelompok(
                                  dataKelompok: null,
                                ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SearchTextFieldWidget(
                        hintText: "Cari berdasarkan nama kelompok",
                        onChangedSearch: (value) {
                          ref
                              .read(kelompokBelajarRiverpodProvider.notifier)
                              .resetAndFetch(search: value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 15),
              siswaKelasMapelState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final errorMsg =
                        err.toString().contains("PostgrestException")
                        ? err
                              .toString()
                              .split("message:")
                              .last
                              .split(",")
                              .first
                              .trim()
                        : err.toString();

                    showDialog(
                      context: context,
                      builder: (context) =>
                          DialogErrorWidget(errorText: 'Error : $errorMsg'),
                    );
                  });

                  // tampilkan tabel dari cache data terakhir, bukan kosong
                  final cachedData = ref
                      .read(kelompokBelajarRiverpodProvider.notifier)
                      .items;

                  return ListCardKelompokWidget(daftarKelompok: cachedData);
                },
                data: (kelompokList) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListCardKelompokWidget(daftarKelompok: kelompokList),
                    // agar tombol + hanya tampil ketika masih ada data
                    if (notifier.hasMore && !notifier.isLoadingMore)
                      Center(
                        child: SizedBox(
                          height: 40,
                          width: 40,
                          child: FloatingActionButton(
                            backgroundColor: const Color(0xff016EB3),
                            onPressed: () => ref
                                .read(kelompokBelajarRiverpodProvider.notifier)
                                .loadMore(),
                            // mini: true,
                            shape: const CircleBorder(),
                            child: Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ignore_for_file: avoid_print
import 'package:elearning_sman2sidoarjo/presentation/features/guru/kelas/siswa/list_card_siswa.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../controllers/guru/konten_kelas/daftar_siswa_kelas_mapel_riverpod.dart';
import '../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../shared_widgets/general_old/header2_widget.dart';
import '../../../../shared_widgets/general_old/search_textfield_widget.dart';

class KontenSiswaKelasMapelWidget extends ConsumerStatefulWidget {
  final String namaKelas;
  final int kelasMapelId;

  const KontenSiswaKelasMapelWidget({
    super.key,
    required this.namaKelas,
    required this.kelasMapelId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _KontenSiswaKelasMapelWidgetState();
}

class _KontenSiswaKelasMapelWidgetState
    extends ConsumerState<KontenSiswaKelasMapelWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final siswaKelasMapelState = ref.watch(siswaKelasRiverpodProvider);
    final notifier = ref.read(siswaKelasRiverpodProvider.notifier);

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
                        header2Title: "Daftar Siswa",
                        subtitle:
                            "Daftar siswa dalam kelas ${widget.namaKelas}",
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SearchTextFieldWidget(
                        hintText: "Cari berdasarkan nama siswa",
                        onChangedSearch: (value) {
                          ref
                              .read(siswaKelasRiverpodProvider.notifier)
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
                      .read(siswaKelasRiverpodProvider.notifier)
                      .items;

                  return ListCardSiswaWidget(daftarSiswa: cachedData);
                },
                data: (materiList) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListCardSiswaWidget(daftarSiswa: materiList),
                    // agar tombol + hanya tampil ketika masih ada data
                    if (notifier.hasMore && !notifier.isLoadingMore)
                      Center(
                        child: SizedBox(
                          height: 40,
                          width: 40,
                          child: FloatingActionButton(
                            backgroundColor: const Color(0xff016EB3),
                            onPressed: () => ref
                                .read(siswaKelasRiverpodProvider.notifier)
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

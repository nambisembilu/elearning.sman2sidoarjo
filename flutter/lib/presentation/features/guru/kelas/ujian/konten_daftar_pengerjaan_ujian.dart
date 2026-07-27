// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../controllers/guru/daftar_pengerjaan_ujian/daftar_pengerjaan_ujian_riverpod.dart';
import '../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../shared_widgets/general_old/header2_widget.dart';
import '../../../../shared_widgets/general_old/search_textfield_widget.dart';
import 'widget/list_card_pengerjaan_ujian.dart';

class KontenDaftarPengerjaanUjian extends ConsumerStatefulWidget {
  const KontenDaftarPengerjaanUjian({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _KontenDaftarPengerjaanUjianState();
}

class _KontenDaftarPengerjaanUjianState
    extends ConsumerState<KontenDaftarPengerjaanUjian> {
  // void _navigateToTambahTugas(int kelasMapelId) {
  //   context.go('/dashboard/guru/kelas/$kelasMapelId/tambah-tugas');
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final daftarPengerjaanUjianState = ref.watch(
      daftarPengerjaanUjianRiverpodProvider,
    );

    return SingleChildScrollView(
      child: Column(
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
                          header2Title: "Daftar Pengerjaan Ujian",
                          subtitle:
                              "Berikut merupakan daftar pengerjaan ujian setiap siswa",
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SearchTextFieldWidget(
                          hintText: "Cari berdasarkan siswa...",
                          onChangedSearch: (value) {
                            ref
                                .read(
                                  daftarPengerjaanUjianRiverpodProvider
                                      .notifier,
                                )
                                .resetAndFetch(search: value);
                          },
                        ),
                        // bagian filter
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 15),
                daftarPengerjaanUjianState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
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
                        .read(daftarPengerjaanUjianRiverpodProvider.notifier)
                        .lastDaftarPengerjaanUjian;

                    return ListCardPengerjaanUjianWidget(
                      daftarPengumpulanUjian: cachedData,
                    );
                  },
                  data: (daftarPengerjaanUjian) =>
                      ListCardPengerjaanUjianWidget(
                        daftarPengumpulanUjian: daftarPengerjaanUjian,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

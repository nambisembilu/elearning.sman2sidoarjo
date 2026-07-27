// ignore_for_file: avoid_print
import 'package:elearning_sman2sidoarjo/core/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../../models/guru/filtering_model.dart';
import '../../../../../controllers/guru/tugas/tugas_kelas_riverpod.dart';
import '../../../../../shared_widgets/general_old/button_add_widget.dart';
import '../../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../../shared_widgets/general_old/header2_widget.dart';
import '../../../../../shared_widgets/general_old/search_textfield_widget.dart';
import 'list_card_tugas_widget.dart';

class KontenTugasWidget extends ConsumerStatefulWidget {
  final String namaKelas;
  final int kelasMapelId;

  const KontenTugasWidget({
    super.key,
    required this.namaKelas,
    required this.kelasMapelId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _KontenTugasWidgetState();
}

class _KontenTugasWidgetState extends ConsumerState<KontenTugasWidget> {
  List<Semester> listSemester = [];

  int? selectedSemesterId;
  String? selectedSemester;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSemester();
  }

  Future<void> _loadSemester() async {
    try {
      final list = await ref
          .read(tugasKelasRiverpodProvider.notifier)
          .fetchSemester();

      if (!mounted) return;

      setState(() {
        listSemester = list;
        final listSemesterAktif = list
            .where((e) => e.isActive == 'true')
            .toList();
        if (listSemesterAktif.isNotEmpty) {
          selectedSemester = listSemesterAktif.first.judulSemester;
          selectedSemesterId = listSemesterAktif.first.semesterId;
        }

        isLoading = false;
      });

      // Hanya panggil resetAndFetch jika mapelId tersedia
      if (selectedSemesterId != null) {
        await ref
            .read(tugasKelasRiverpodProvider.notifier)
            .resetAndFetch(
              search: '',
              page: 1,
              semesterId: selectedSemesterId!,
            );
      }
    } catch (e) {
      print("Error loading materi: $e");
      if (mounted) {
        setState(() {
          listSemester = [];

          isLoading = false;
        });
      }
    }
  }

  void _navigateToTambahTugas(int kelasMapelId) {
    context.go(RoutesNames.tambahTugas);
  }

  @override
  Widget build(BuildContext context) {
    final materiState = ref.watch(tugasKelasRiverpodProvider);
    final notifier = ref.read(tugasKelasRiverpodProvider.notifier);

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
                        header2Title: "Daftar Tugas",
                        subtitle:
                            "Daftar tugas dalam kelas ${widget.namaKelas}",
                      ),
                      ButtonAddWidget(
                        addAction: () =>
                            _navigateToTambahTugas(widget.kelasMapelId),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SearchTextFieldWidget(
                        hintText: "Cari berdasarkan judul tugas",
                        onChangedSearch: (value) {
                          ref
                              .read(tugasKelasRiverpodProvider.notifier)
                              .resetAndFetch(
                                search: value,
                                semesterId: selectedSemesterId!,
                              );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 15),
              materiState.when(
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
                      .read(tugasKelasRiverpodProvider.notifier)
                      .tugasList;

                  return ListCardTugas(daftarTugas: cachedData);
                },
                data: (tugasList) {
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListCardTugas(daftarTugas: tugasList),
                        // agar tombol + hanya tampil ketika masih ada data
                        if (notifier.hasMore &&
                            !notifier.isLoadingMore &&
                            tugasList.isNotEmpty)
                          Center(
                            child: SizedBox(
                              height: 40,
                              width: 40,
                              child: FloatingActionButton(
                                backgroundColor: const Color(0xff016EB3),
                                onPressed: () => ref
                                    .read(tugasKelasRiverpodProvider.notifier)
                                    .loadMore(),
                                // mini: true,
                                shape: const CircleBorder(),
                                child: Icon(Icons.add, color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

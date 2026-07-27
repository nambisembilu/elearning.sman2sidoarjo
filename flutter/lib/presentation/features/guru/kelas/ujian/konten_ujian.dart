// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:elearning_sman2sidoarjo/core/routes/routes_name.dart';
import 'package:elearning_sman2sidoarjo/presentation/shared_widgets/general_old/header2_widget.dart'
    show Header2Widget;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../models/guru/filtering_model.dart';
import '../../../../controllers/guru/ujian/ujian_kelas_riverpod.dart';
import '../../../../shared_widgets/general_old/button_add_widget.dart';
import '../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../shared_widgets/general_old/filter_dropdown.dart';
import '../../../../shared_widgets/general_old/search_textfield_widget.dart';
import 'list_card_ujian.dart';

class KontenUjianKelasMapelWidget extends ConsumerStatefulWidget {
  final String namaKelas;
  final int kelasMapelId;

  const KontenUjianKelasMapelWidget({
    super.key,
    required this.namaKelas,
    required this.kelasMapelId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _KontenUjianKelasMapelWidgetState();
}

class _KontenUjianKelasMapelWidgetState
    extends ConsumerState<KontenUjianKelasMapelWidget> {
  // void _navigateToTambahMateri(int kelasMapelId) {
  //   context.go(
  //     '/dashboard/guru/kelas/$kelasMapelId/tambah-materi',
  //     // extra: true, // Mark as coming from detail screen
  //   );
  // }
  List<Semester> listSemester = [];

  int? selectedSemesterId;
  String? selectedSemester;
  String? selectedTipeUjian;

  void _navigateToTambahUjian(int kelasMapelId) {
    // context.go(
    //   '/dashboard/guru/kelas/$kelasMapelId/tambah-ujian',
    //   // extra: true, // Mark as coming from detail screen
    // );
    context.go(RoutesNames.kelolaUjian);
  }

  @override
  void initState() {
    super.initState();
    selectedTipeUjian = 'Sumatif Lingkup Materi';
    _loadSemester();
  }

  Future<void> _loadSemester() async {
    try {
      final list = await ref
          .read(ujianKelasRiverpodProvider.notifier)
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
      });

      // Hanya panggil resetAndFetch jika mapelId tersedia
      if (selectedSemesterId != null) {
        await ref
            .read(ujianKelasRiverpodProvider.notifier)
            .resetAndFetch(
              search: '',
              page: 1,
              semesterId: selectedSemesterId!,
              tipeUjian: selectedTipeUjian!,
            );
      }
    } catch (e) {
      print("Error loading mapel diampu: $e");
      if (mounted) {
        setState(() {
          listSemester = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ujianKelasState = ref.watch(ujianKelasRiverpodProvider);
    final notifier = ref.read(ujianKelasRiverpodProvider.notifier);

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
                        header2Title: "Daftar Ujian",
                        subtitle:
                            "Daftar ujian dalam kelas ${widget.namaKelas}",
                      ),
                      ButtonAddWidget(
                        addAction: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString(
                            'selectedTipeUjian',
                            selectedTipeUjian!,
                          );

                          if (notifier.ujianList.isNotEmpty &&
                              (selectedTipeUjian == 'STS' ||
                                  selectedTipeUjian == 'SAS')) {
                            showDialog(
                              context: context,
                              builder: (context) => DialogErrorWidget(
                                errorText:
                                    "Tidak bisa menambahkan STS lebih dari satu kali dalam 1 semester.",
                              ),
                            );
                          } else {
                            _navigateToTambahUjian(widget.kelasMapelId);
                          }

                          // showDialog(
                          //   context: context,
                          //   builder:
                          //       (context) => const DialogTambahOrEditKelompok(
                          //         dataKelompok: null,
                          //       ),
                          // );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SearchTextFieldWidget(
                        hintText: "Cari berdasarkan judul ujian",
                        onChangedSearch: (value) {
                          ref
                              .read(ujianKelasRiverpodProvider.notifier)
                              .resetAndFetch(
                                search: value,
                                semesterId: selectedSemesterId!,
                                tipeUjian: selectedTipeUjian!,
                              );
                        },
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Filter :",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          FilterDropdownWidget(
                            pHintText: 'Pilih Tipe Ujian',
                            valueParams: selectedTipeUjian,
                            pItems: ['Sumatif Lingkup Materi', 'STS', 'SAS'],
                            pOnChanged: (value) async {
                              if (value != null) {
                                setState(() {
                                  selectedTipeUjian = value;
                                });

                                ref
                                    .read(ujianKelasRiverpodProvider.notifier)
                                    .resetAndFetch(
                                      semesterId: selectedSemesterId!,
                                      tipeUjian: selectedTipeUjian!,
                                    );
                              }
                            },
                            widhtDropdown: 200,
                          ),
                          SizedBox(width: 10),
                          FilterDropdownWidget(
                            pHintText: 'Pilih Semester',
                            valueParams: selectedSemester,
                            pItems: listSemester
                                .map((e) => e.judulSemester)
                                .toList(),
                            pOnChanged: (value) {
                              if (value != null) {
                                final selected = listSemester.firstWhere(
                                  (e) => e.judulSemester == value,
                                );

                                setState(() {
                                  selectedSemester = selected.judulSemester;
                                  selectedSemesterId = selected.semesterId;
                                });
                                ref
                                    .read(ujianKelasRiverpodProvider.notifier)
                                    .resetAndFetch(
                                      semesterId: selectedSemesterId!,
                                      tipeUjian: selectedTipeUjian!,
                                    );
                              }
                            },
                            widhtDropdown: 200,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 15),
              ujianKelasState.when(
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
                      .read(ujianKelasRiverpodProvider.notifier)
                      .ujianList;

                  return ListCardUjian(daftarUjian: cachedData);
                },
                data: (ujianList) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListCardUjian(daftarUjian: ujianList),
                    // agar tombol + hanya tampil ketika masih ada data
                    if (notifier.hasMore && !notifier.isLoadingMore)
                      Center(
                        child: SizedBox(
                          height: 40,
                          width: 40,
                          child: FloatingActionButton(
                            backgroundColor: const Color(0xff016EB3),
                            onPressed: () => ref
                                .read(ujianKelasRiverpodProvider.notifier)
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

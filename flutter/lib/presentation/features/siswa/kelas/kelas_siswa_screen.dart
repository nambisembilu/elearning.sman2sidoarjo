import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/siswa/filtering_model.dart';
import '../../../controllers/siswa/kelas/kelas_siswa_riverpod.dart';
import '../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../shared_widgets/general_old/filter_dropdown.dart';
import '../../../shared_widgets/general_old/filter_dropdown_widget_2.dart';
import '../../../shared_widgets/general_old/header2_widget.dart';
import '../../../shared_widgets/general_old/search_textfield_widget.dart';
import 'widget/gridview_kelas.dart';

// Import screen detail kelas (ganti dengan path yang sesuai)

class KelasSiswaScreen extends ConsumerStatefulWidget {
  // final GlobalKey<NavigatorState> navigatorKey;

  const KelasSiswaScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _KelasSiswaScreenState();
}

class _KelasSiswaScreenState extends ConsumerState<KelasSiswaScreen> {
  String? selectedTahunAjaran;
  int? selectedTahunAjaranId;
  List<TahunAjaran> tahunAjaranList = [];

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final list = await ref
          .read(kelasSiswaNotifierProvider.notifier)
          .fetchTahunAjaran();

      if (!mounted) return;
      setState(() {
        tahunAjaranList = list;
        if (tahunAjaranList.isNotEmpty) {
          selectedTahunAjaran = tahunAjaranList.first.tahunAjaran;
          selectedTahunAjaranId = tahunAjaranList.first.id;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final kelasSiswaState = ref.watch(kelasSiswaNotifierProvider);
    return Padding(
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header2Widget(
              header2Title: "KELAS SAYA",
              subtitle: "Daftar kelas yang anda ikuti saat ini.",
            ),
            const SizedBox(height: 20),
            kelasSiswaState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final errorMsg = err.toString().contains("PostgrestException")
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
                    .read(kelasSiswaNotifierProvider.notifier)
                    .lastKelasSiswa;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 300,
                          child: SearchTextFieldWidget(
                            hintText: "Cari berdasarkan nama kelas....",
                            onChangedSearch: (value) {
                              ref
                                  .read(kelasSiswaNotifierProvider.notifier)
                                  .resetAndFetch(
                                    search: value,
                                    tahunAjaranId: selectedTahunAjaranId,
                                  );
                            },
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Tahun Ajaran : "),
                            FilterDropdownWidget2(
                              pHintText: "Semua Tahun Ajaran",
                              valueParams: selectedTahunAjaran,
                              pItems: [],
                              pOnChanged: (value) {},
                              widhtDropdown: 230,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    GridviewKelasWidget(daftarKelasSiswa: cachedData),
                  ],
                );
              },
              data: (kelasGuru) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 20,
                    runSpacing: 10,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      SearchTextFieldWidget(
                        hintText: "Cari berdasarkan nama kelas....",
                        onChangedSearch: (value) {
                          ref
                              .read(kelasSiswaNotifierProvider.notifier)
                              .resetAndFetch(
                                search: value,
                                tahunAjaranId: selectedTahunAjaranId,
                              );
                        },
                      ),
                      // Row(mainAxisSize: MainAxisSize.min),
                      // Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Text("Tahun Ajaran : "),
                          FilterDropdownWidget(
                            pHintText: "Semua Tahun Ajaran",
                            valueParams: selectedTahunAjaran,
                            pItems: tahunAjaranList
                                .map((e) => e.tahunAjaran)
                                .toList(),
                            pOnChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  final selected = tahunAjaranList.firstWhere(
                                    (e) => e.tahunAjaran == value,
                                  );

                                  selectedTahunAjaran = selected.tahunAjaran;
                                  selectedTahunAjaranId = selected.id;

                                  ref
                                      .read(kelasSiswaNotifierProvider.notifier)
                                      .filterKelas(
                                        pTahunAjaranId: selectedTahunAjaranId,
                                      );
                                });
                              }
                            },
                            widhtDropdown: 230,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (kelasGuru.isNotEmpty)
                    GridviewKelasWidget(daftarKelasSiswa: kelasGuru)
                  else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Text('Tidak ada kelas tersedia.'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../models/guru/filtering_model.dart';
import '../../../../models/guru/nilai_sumatif_lingkup_materi_model.dart';
import '../../../controllers/guru/nilai_sumatif_lm/nilai_sumatif_lm_riverpod.dart';
import '../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../shared_widgets/general_old/filter_dropdown.dart';
import '../../../shared_widgets/general_old/header2_widget.dart';
import '../../../shared_widgets/general_old/header_widget.dart';
import '../../../shared_widgets/general_old/search_textfield_widget.dart';
import '../../../shared_widgets/general_old/table_cell.dart';
import '../../../shared_widgets/general_old/table_header_cell.dart';

class NilaiSumatifLMScreen extends ConsumerStatefulWidget {
  const NilaiSumatifLMScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NilaiSumatifLMScreenState();
}

class _NilaiSumatifLMScreenState extends ConsumerState<NilaiSumatifLMScreen> {
  String? selectedSemester;
  String? selectedKmp;

  int? selectedSemesterId;
  int? selectedKmpId;

  List<Semester> semesterList = [];
  List<KelasMapelGuru> kmpList = [];

  // bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    // Panggil init filter saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(nilaiSumatifLMNotifierProvider.notifier);
      await notifier.resetAndFetch(
        page: 1,
      ); // ini akan isi lastListNilaiSumatifLM
      await _initFilters(); // baru jalan filter pakai data terakhir
    });
  }

  Future<void> _initFilters() async {
    try {
      final notifier = ref.read(nilaiSumatifLMNotifierProvider.notifier);

      if (notifier.lastListNilaiSumatifLM.isEmpty) {
        // Kalau kosong, berarti user belum pernah fetch sama sekali
        print("lastListNilaiSumatifLM kosong, tidak ada data filter terakhir.");
        // setState(() => _isInitializing = false);
        return;
      }

      // 🔹 1. Ambil filter terakhir
      final last = notifier.lastListNilaiSumatifLM.first;
      selectedSemesterId = last.semesterId;
      selectedKmpId = last.kmpId;

      // 🔹 2. Fetch daftar semester
      semesterList = await notifier.fetchSemester();
      final semester = semesterList.firstWhere(
        (s) => s.semesterId == selectedSemesterId,
        orElse: () => semesterList.first,
      );
      selectedSemester = semester.judulSemester;

      // 🔹 3. Fetch daftar kelas dari tahun ajaran semester tersebut
      kmpList = await notifier.fetchKelasMapelGuru(
        tahunAjaranId: semester.tahunAjaranId,
      );
      final kmp = kmpList.firstWhere(
        (k) => k.kmpId == selectedKmpId,
        orElse: () => kmpList.first,
      );
      selectedKmp = kmp.namaKmp;

      // 🔹 5. Fetch nilai sesuai filter terakhir
      await notifier.resetAndFetch(
        page: 1,
        search: '',
        semesterId: selectedSemesterId,
        kmpId: selectedKmpId,
      );
    } catch (e) {
      print("Error initializing filters: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final nilaiSumatifLMState = ref.watch(nilaiSumatifLMNotifierProvider);
    final notifier = ref.read(nilaiSumatifLMNotifierProvider.notifier);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWidget(
              headerTitle: "SUMATIF LINGKUP MATERI",
              btnAddTitle: "",
              showExportBtn: false,
              showImportBtn: false,
              showAddBtn: false,
              addAction: null,
              exportAction: () {},
              importAction: null,
            ),
            const SizedBox(height: 20),
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
                  Header2Widget(
                    header2Title: "Daftar Nilai Sumatif Lingkup Materi",
                    subtitle:
                        "Lakukan pencarian nilai sumatif dari setiap lingkup materi",
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SearchTextFieldWidget(
                        hintText: "Cari dengan nama siswa atau NIS...",
                        onChangedSearch: (value) {
                          notifier.resetAndFetch(search: value, page: 1);
                        },
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Filter :",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          FilterDropdownWidget(
                            pHintText: "Semua Semester",
                            valueParams: selectedSemester,
                            pItems: semesterList
                                .map((e) => e.judulSemester)
                                .toList(),
                            pOnChanged: (value) {
                              setState(() {
                                selectedKmpId = null;
                                final semester = semesterList.firstWhere(
                                  (e) => e.judulSemester == value,
                                );
                                selectedSemesterId = semester.semesterId;

                                notifier
                                    .fetchKelasMapelGuru(
                                      tahunAjaranId: semester.tahunAjaranId,
                                    )
                                    .then((getKmp) {
                                      setState(() {
                                        kmpList = getKmp;
                                      });
                                    });
                              });
                            },
                            widhtDropdown: 250,
                          ),
                          SizedBox(width: 10),
                          FilterDropdownWidget(
                            pHintText: "Semua Kelas Mata Pelajaran",
                            valueParams: selectedKmp,
                            pItems: kmpList.map((e) => e.namaKmp).toList(),
                            pOnChanged: (value) {
                              setState(() {
                                final kmp = kmpList.firstWhere(
                                  (e) => e.namaKmp == value,
                                );
                                selectedKmpId = kmp.kmpId;

                                notifier.resetAndFetch(
                                  search: '',
                                  page: 1,
                                  semesterId: selectedSemesterId,
                                  kmpId: selectedKmpId,
                                );
                              });
                            },
                            widhtDropdown: 230,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  nilaiSumatifLMState.when(
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
                      final cachedData = notifier.lastListNilaiSumatifLM;

                      return buildNilaiSumatifLMTable(context, cachedData, ref);
                    },
                    data: (nilaiSumatifLMList) => buildNilaiSumatifLMTable(
                      context,
                      nilaiSumatifLMList,
                      ref,
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

/// =====================
/// Pagination Helpers
/// =====================
List<Widget> _buildPaginationButtons(
  int totalPage,
  int currentPage,
  void Function(int) onPageSelected,
) {
  List<Widget> buttons = [];

  if (totalPage <= 5) {
    // Kalau halaman sedikit, tampil semua
    for (int i = 1; i <= totalPage; i++) {
      buttons.add(_pageButton(i, currentPage, onPageSelected));
    }
  } else {
    // Selalu tampilkan halaman 1
    buttons.add(_pageButton(1, currentPage, onPageSelected));

    // Ellipsis awal
    if (currentPage > 4) {
      buttons.add(
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text("..."),
        ),
      );
    }

    // Halaman sekitar currentPage
    int start = (currentPage - 1).clamp(2, totalPage - 3);
    int end = (currentPage + 1).clamp(4, totalPage - 1);

    for (int i = start; i <= end; i++) {
      buttons.add(_pageButton(i, currentPage, onPageSelected));
    }

    // Ellipsis akhir
    if (currentPage < totalPage - 3) {
      buttons.add(
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text("..."),
        ),
      );
    }

    // Halaman terakhir
    buttons.add(_pageButton(totalPage, currentPage, onPageSelected));
  }

  return buttons;
}

Widget _pageButton(int i, int currentPage, void Function(int) onPageSelected) {
  final bool isActive = i == currentPage;
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2.0),
    child: TextButton(
      style: TextButton.styleFrom(
        backgroundColor: isActive ? Colors.blue : null,
        foregroundColor: isActive ? Colors.white : Colors.black,
        minimumSize: const Size(36, 36),
        padding: EdgeInsets.zero,
      ),
      onPressed: () => onPageSelected(i),
      child: Text("$i"),
    ),
  );
}

Widget buildNilaiSumatifLMTable(
  BuildContext context,
  List<NilaiSumatifLM> nilaiSumatifLMList,
  WidgetRef ref,
) {
  if (nilaiSumatifLMList.isEmpty) {
    return const Center(
      child: Text("Nilai sumatif lingkup materi tidak tersedia."),
    );
  }

  final notifier = ref.read(nilaiSumatifLMNotifierProvider.notifier);

  // 🔹 1. Kumpulkan semua judul sumatif lm yang unik dari semua siswa
  final semuaJudulSumatifLM = <String>{};
  for (final nilaiSumatifLM in nilaiSumatifLMList) {
    for (final sumatifLM in nilaiSumatifLM.nilaiSumatifLM) {
      final judul = sumatifLM['judul_sumatif'];
      if (judul != null && judul.isNotEmpty) {
        semuaJudulSumatifLM.add(judul);
      }
    }
  }

  // 🔹 2. Urutkan judul sumatif lm (opsional, agar konsisten)
  final listJudulSumatifLM = semuaJudulSumatifLM.toList()..sort();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black26, width: 1.2),
        ),
        clipBehavior: Clip.hardEdge,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Table(
                  border: const TableBorder(
                    horizontalInside: BorderSide(
                      width: 1,
                      color: Colors.black26,
                    ),
                  ),
                  columnWidths: _buildColumnWidths(listJudulSumatifLM.length),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    // 🔹 3. Header tabel yang dinamis
                    _buildTableHeader(listJudulSumatifLM),

                    // 🔹 4. Baris data yang dinamis
                    ..._buildTableRows(nilaiSumatifLMList, listJudulSumatifLM),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 16),

      /// Pagination (tetap sama)
      LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Menampilkan ${nilaiSumatifLMList.length} dari ${notifier.total} data",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: notifier.currentPage > 1
                            ? () => notifier.fetchPreviousPage()
                            : null,
                        child: const Text("Sebelumnya"),
                      ),
                      const SizedBox(width: 8),
                      ..._buildPaginationButtons(
                        notifier.totalPage,
                        notifier.currentPage,
                        (page) => notifier.resetAndFetch(page: page),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: notifier.hasMore
                            ? () => notifier.fetchNextPage()
                            : null,
                        child: const Text("Selanjutnya"),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Menampilkan ${nilaiSumatifLMList.length} dari ${notifier.total} data",
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: notifier.currentPage > 1
                          ? () => notifier.fetchPreviousPage()
                          : null,
                      child: const Text("Sebelumnya"),
                    ),
                    const SizedBox(width: 8),
                    ..._buildPaginationButtons(
                      notifier.totalPage,
                      notifier.currentPage,
                      (page) => notifier.resetAndFetch(page: page),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: notifier.hasMore
                          ? () => notifier.fetchNextPage()
                          : null,
                      child: const Text("Selanjutnya"),
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    ],
  );
}

/// 🔹 Fungsi untuk menentukan lebar kolom yang dinamis
Map<int, TableColumnWidth> _buildColumnWidths(int jumlahSumatifLM) {
  final columnWidths = <int, TableColumnWidth>{
    0: FixedColumnWidth(80), // NIS tetap 80 px
    1: IntrinsicColumnWidth(), // Nama siswa lebih lebar
    2: IntrinsicColumnWidth(),
    3: IntrinsicColumnWidth(),
  };

  for (int i = 0; i < jumlahSumatifLM; i++) {
    columnWidths[2 + i] = IntrinsicColumnWidth(); // Semua sumatif lm rata sama
  }

  return columnWidths;
}

/// 🔹 Fungsi untuk membangun header tabel yang dinamis
TableRow _buildTableHeader(List<String> judulSumatifLM) {
  return TableRow(
    children: [
      TableHeaderCell("NIS"),
      TableHeaderCell("Nama Siswa"),
      TableHeaderCell("Kelas"),
      TableHeaderCell("Mata Pelajaran"),
      for (final judul in judulSumatifLM) TableHeaderCell(judul),
    ],
  );
}

/// 🔹 Fungsi untuk membangun baris data yang dinamis
/// 🔹 Fungsi untuk membangun baris data yang dinamis
List<TableRow> _buildTableRows(
  List<NilaiSumatifLM> nilaiSumatifLMList,
  List<String> judulSumatifLM,
) {
  return nilaiSumatifLMList.map((nilaiSumatifLM) {
    // 🔹 Buat map untuk memudahkan pencarian nilai berdasarkan judul sumatifLM
    final mapNilaiSumatifLM = <String, dynamic>{}; // 🔹 Ubah ke dynamic
    for (final sumatifLM in nilaiSumatifLM.nilaiSumatifLM) {
      final judul = sumatifLM['judul_sumatif'];
      final nilai = sumatifLM['nilai_ujian'];
      if (judul != null) {
        mapNilaiSumatifLM[judul] = nilai;
      }
    }

    return TableRow(
      children: [
        TableCellWidget(nilaiSumatifLM.nis.toString()),
        TableCellWidget(nilaiSumatifLM.namaSiswa),
        TableCellWidget(nilaiSumatifLM.namaKelas),
        TableCellWidget(nilaiSumatifLM.judulMapel),
        for (final judul in judulSumatifLM)
          TableCellWidget(_convertNilaiToString(mapNilaiSumatifLM[judul])),
      ],
    );
  }).toList();
}

/// 🔹 Fungsi untuk mengkonversi nilai dynamic ke String
String _convertNilaiToString(dynamic nilai) {
  if (nilai == null) return '-';

  if (nilai is double) {
    // Format double: hapus .0 jika tidak perlu
    return nilai % 1 == 0 ? nilai.toInt().toString() : nilai.toString();
  } else if (nilai is int) {
    return nilai.toString();
  } else if (nilai is String) {
    return nilai;
  } else {
    return nilai.toString();
  }
}

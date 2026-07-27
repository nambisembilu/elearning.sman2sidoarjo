// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../models/staff/filtering_model.dart';
import '../../../../models/staff/nilai_latsol_model.dart';
import '../../../controllers/staff/nilai_latsol/nilai_latsol_riverpod.dart';
import '../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../shared_widgets/general_old/filter_dropdown.dart';
import '../../../shared_widgets/general_old/header2_widget.dart';
import '../../../shared_widgets/general_old/header_widget.dart';
import '../../../shared_widgets/general_old/search_textfield_widget.dart';
import '../../../shared_widgets/general_old/table_cell.dart';
import '../../../shared_widgets/general_old/table_header_cell.dart';

class NilaiLatsolStaffScreen extends ConsumerStatefulWidget {
  const NilaiLatsolStaffScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NilaiLatsolStaffScreenState();
}

class _NilaiLatsolStaffScreenState extends ConsumerState<NilaiLatsolStaffScreen> {
  String? selectedSemester;
  String? selectedKelas;
  String? selectedMapel;

  int? selectedSemesterId;
  int? selectedKelasId;
  int? selectedMapelid;

  List<Semester> semesterList = [];
  List<KelasByTahunAjaran> kelasList = [];
  List<MapelByKelas> mapelList = [];

  // bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    // Panggil init filter saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(nilaiLatsolNotifierProvider.notifier);
      await notifier.resetAndFetch(page: 1); // ini akan isi lastListNilaiLatsol
      await _initFilters(); // baru jalan filter pakai data terakhir
    });
  }

  Future<void> _initFilters() async {
    try {
      final notifier = ref.read(nilaiLatsolNotifierProvider.notifier);

      if (notifier.lastListNilaiLatsol.isEmpty) {
        // Kalau kosong, berarti user belum pernah fetch sama sekali
        print("lastListNilaiLatsol kosong, tidak ada data filter terakhir.");
        // setState(() => _isInitializing = false);
        return;
      }

      // 🔹 1. Ambil filter terakhir
      final last = notifier.lastListNilaiLatsol.first;
      selectedSemesterId = last.semesterId;
      selectedKelasId = last.kelasId;
      selectedMapelid = last.mapelId;

      // 🔹 2. Fetch daftar semester
      semesterList = await notifier.fetchSemester();
      final semester = semesterList.firstWhere(
        (s) => s.semesterId == selectedSemesterId,
        orElse: () => semesterList.first,
      );
      selectedSemester = semester.judulSemester;

      // 🔹 3. Fetch daftar kelas dari tahun ajaran semester tersebut
      kelasList = await notifier.fetchKelasByTahunAjaran(
        tahunAjaranId: semester.TahunAjaranId,
      );
      final kelas = kelasList.firstWhere(
        (k) => k.id == selectedKelasId,
        orElse: () => kelasList.first,
      );
      selectedKelas = kelas.namaKelas;

      // 🔹 4. Fetch daftar mapel dari kelas
      mapelList = await notifier.fetchMapelByKelas(kelasId: kelas.id);
      final mapel = mapelList.firstWhere(
        (m) => m.mapelId == selectedMapelid,
        orElse: () => mapelList.first,
      );
      selectedMapel = mapel.judulMapel;

      // 🔹 5. Fetch nilai sesuai filter terakhir
      await notifier.resetAndFetch(
        page: 1,
        search: '',
        semesterId: selectedSemesterId,
        kelasId: selectedKelasId,
        mapelId: selectedMapelid,
      );
    } catch (e) {
      print("Error initializing filters: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final nilaiLatsolState = ref.watch(nilaiLatsolNotifierProvider);
    final notifier = ref.read(nilaiLatsolNotifierProvider.notifier);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWidget(
              headerTitle: "NILAI LATIHAN SOAL",
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
                    header2Title: "Daftar Nilai Latihan Soal",
                    subtitle: "Lakukan pencarian nilai latihan soal",
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
                                selectedKelas = null;
                                selectedMapel = null;
                                selectedKelasId = null;
                                selectedMapelid = null;
                                final semester = semesterList.firstWhere(
                                  (e) => e.judulSemester == value,
                                );
                                selectedSemesterId = semester.semesterId;

                                notifier
                                    .fetchKelasByTahunAjaran(
                                      tahunAjaranId: semester.TahunAjaranId,
                                    )
                                    .then((getKelas) {
                                      setState(() {
                                        kelasList = getKelas;
                                      });
                                    });
                              });
                            },
                            widhtDropdown: 250,
                          ),
                          SizedBox(width: 10),
                          FilterDropdownWidget(
                            pHintText: "Semua Kelas",
                            valueParams: selectedKelas,
                            pItems: kelasList.map((e) => e.namaKelas).toList(),
                            pOnChanged: (value) {
                              setState(() {
                                selectedMapel = null;
                                final kelas = kelasList.firstWhere(
                                  (e) => e.namaKelas == value,
                                );
                                selectedKelasId = kelas.id;

                                notifier
                                    .fetchMapelByKelas(kelasId: kelas.id)
                                    .then((getMapel) {
                                      setState(() {
                                        mapelList = getMapel;
                                      });
                                    });
                              });
                            },
                            widhtDropdown: 150,
                          ),
                          SizedBox(width: 10),
                          FilterDropdownWidget(
                            pHintText: "Semua Mata Pelajaran",
                            valueParams: selectedMapel,
                            pItems: mapelList.map((e) => e.judulMapel).toList(),
                            pOnChanged: (value) {
                              setState(() {
                                final mapel = mapelList.firstWhere(
                                  (e) => e.judulMapel == value,
                                );
                                selectedMapelid = mapel.mapelId;

                                notifier.resetAndFetch(
                                  search: '',
                                  page: 1,
                                  semesterId: selectedSemesterId,
                                  kelasId: selectedKelasId,
                                  mapelId: selectedMapelid,
                                );
                              });
                            },
                            widhtDropdown: 200,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  nilaiLatsolState.when(
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
                      final cachedData = notifier.lastListNilaiLatsol;

                      return buildNilaiLatsolTable(context, cachedData, ref);
                    },
                    data: (nilaiLatsolList) =>
                        buildNilaiLatsolTable(context, nilaiLatsolList, ref),
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

Widget buildNilaiLatsolTable(
  BuildContext context,
  List<NilaiLatsol> nilaiLatsolList,
  WidgetRef ref,
) {
  if (nilaiLatsolList.isEmpty) {
    return const Center(child: Text("Nilai latihan soal tidak tersedia."));
  }

  final notifier = ref.read(nilaiLatsolNotifierProvider.notifier);

  // 🔹 1. Kumpulkan semua judul latsol yang unik dari semua siswa
  final semuaJudulLatsol = <String>{};
  for (final nilaiLatsol in nilaiLatsolList) {
    for (final latsol in nilaiLatsol.nilaiLatsol) {
      final judul = latsol['judul_default'];
      if (judul != null && judul.isNotEmpty) {
        semuaJudulLatsol.add(judul);
      }
    }
  }

  // 🔹 2. Urutkan judul latsol (opsional, agar konsisten)
  final listJudulLatsol = semuaJudulLatsol.toList()..sort();

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
                  columnWidths: _buildColumnWidths(listJudulLatsol.length),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    // 🔹 3. Header tabel yang dinamis
                    _buildTableHeader(listJudulLatsol),

                    // 🔹 4. Baris data yang dinamis
                    ..._buildTableRows(nilaiLatsolList, listJudulLatsol),
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
                  "Menampilkan ${nilaiLatsolList.length} dari ${notifier.total} data",
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
                  "Menampilkan ${nilaiLatsolList.length} dari ${notifier.total} data",
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
Map<int, TableColumnWidth> _buildColumnWidths(int jumlahLatsol) {
  final columnWidths = <int, TableColumnWidth>{
    0: FixedColumnWidth(80), // NIS tetap 80 px
    1: IntrinsicColumnWidth(), // Nama siswa lebih lebar
    2: IntrinsicColumnWidth(),
    3: IntrinsicColumnWidth(),
  };

  for (int i = 0; i < jumlahLatsol; i++) {
    columnWidths[2 + i] = IntrinsicColumnWidth(); // Semua latsol rata sama
  }

  return columnWidths;
}

/// 🔹 Fungsi untuk membangun header tabel yang dinamis
TableRow _buildTableHeader(List<String> judulLatsol) {
  return TableRow(
    children: [
      TableHeaderCell("NIS"),
      TableHeaderCell("Nama Siswa"),
      TableHeaderCell("Kelas"),
      TableHeaderCell("Mata Pelajaran"),
      for (final judul in judulLatsol) TableHeaderCell(judul),
    ],
  );
}

/// 🔹 Fungsi untuk membangun baris data yang dinamis
/// 🔹 Fungsi untuk membangun baris data yang dinamis
List<TableRow> _buildTableRows(
  List<NilaiLatsol> nilaiLatsolList,
  List<String> judulLatsol,
) {
  return nilaiLatsolList.map((nilaiLatsol) {
    // 🔹 Buat map untuk memudahkan pencarian nilai berdasarkan judul latsol
    final mapNilaiLatsol = <String, dynamic>{}; // 🔹 Ubah ke dynamic
    for (final latsol in nilaiLatsol.nilaiLatsol) {
      final judul = latsol['judul_default'];
      final nilai = latsol['nilai'];
      if (judul != null) {
        mapNilaiLatsol[judul] = nilai;
      }
    }

    return TableRow(
      children: [
        TableCellWidget(nilaiLatsol.nis.toString()),
        TableCellWidget(nilaiLatsol.namaSiswa),
        TableCellWidget(nilaiLatsol.nama_kelas),
        TableCellWidget(nilaiLatsol.judul_mapel),
        for (final judul in judulLatsol)
          TableCellWidget(_convertNilaiToString(mapNilaiLatsol[judul])),
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

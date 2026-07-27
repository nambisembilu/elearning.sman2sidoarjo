// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:excel/excel.dart' as excel;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

import '../../../../models/guru/filtering_model.dart';
import '../../../../models/guru/nilai_akhir_model.dart';
import '../../../controllers/guru/nilai_akhir/nilai_akhir_riverpod.dart';
import '../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../../shared_widgets/general_old/filter_dropdown.dart';
import '../../../shared_widgets/general_old/header2_widget.dart';
import '../../../shared_widgets/general_old/header_widget.dart';
import '../../../shared_widgets/general_old/search_textfield_widget.dart';
import '../../../shared_widgets/general_old/table_cell.dart';
import '../../../shared_widgets/general_old/table_header_cell.dart';

class NilaiAkhirKelasScreen extends ConsumerStatefulWidget {
  const NilaiAkhirKelasScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NilaiAkhirKelasScreenState();
}

class _NilaiAkhirKelasScreenState extends ConsumerState<NilaiAkhirKelasScreen> {
  String? selectedSemester;
  String? selectedKelas;
  String? selectedMapel;

  int? selectedSemesterId;
  int? selectedKelasId;
  int? selectedMapelId;

  List<Semester> semesterList = [];
  List<KelasByTahunAjaran> kelasList = [];
  List<MataPelajaran> mapelList = [];

  @override
  void initState() {
    super.initState();
    // Panggil init filter saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(nilaiAkhirNotifierProvider.notifier);
      await notifier.resetAndFetch(page: 1); // ini akan isi lastListNilaiAkhir
      await _initFilters(); // baru jalan filter pakai data terakhir
    });
  }

  Future<void> _initFilters() async {
    try {
      final notifier = ref.read(nilaiAkhirNotifierProvider.notifier);

      if (notifier.lastListNilaiAkhir.isEmpty) {
        // Kalau kosong, berarti user belum pernah fetch sama sekali
        print("lastListNilaiAkhir kosong, tidak ada data filter terakhir.");
        return;
      }

      // 🔹 1. Ambil filter terakhir
      final last = notifier.lastListNilaiAkhir.first;
      selectedSemesterId = last.semesterId;
      selectedKelasId = last.kelasId;
      selectedMapelId = last.mapelId;

      // 🔹 2. Fetch daftar semester
      semesterList = await notifier.fetchSemester();
      final semester = semesterList.firstWhere(
        (s) => s.semesterId == selectedSemesterId,
        orElse: () => semesterList.first,
      );
      selectedSemester = semester.judulSemester;

      // 🔹 3. Fetch daftar kelas dari tahun ajaran semester tersebut
      kelasList = await notifier.fetchKelasByTahunAjaran(
        tahunAjaranId: semester.tahunAjaranId,
      );
      final kelas = kelasList.firstWhere(
        (k) => k.id == selectedKelasId,
        orElse: () => kelasList.first,
      );
      selectedKelas = kelas.namaKelas;

      // 🔹 4. Fetch daftar mapel dari kelas
      mapelList = await notifier.fetchMapelByKelas(kelasId: kelas.id);
      final mapel = mapelList.firstWhere(
        (m) => m.mapelId == selectedMapelId,
        orElse: () => mapelList.first,
      );
      selectedMapel = mapel.judulMapel;

      // 🔹 5. Fetch nilai sesuai filter terakhir
      await notifier.resetAndFetch(
        page: 1,
        search: '',
        semesterId: selectedSemesterId,
        kelasId: selectedKelasId,
        mapelId: selectedMapelId,
      );
    } catch (e) {
      print("Error initializing filters: $e");
    }
  }

  Future<void> _exportToExcel() async {
    final nilaiAkhirState = ref.read(nilaiAkhirNotifierProvider);
    final notifier = ref.read(nilaiAkhirNotifierProvider.notifier);
    await notifier.fetchAllPagesWithoutAffectingUI();

    // Validasi filter harus dipilih
    if (selectedSemester == null ||
        selectedKelas == null ||
        selectedMapel == null) {
      showDialog(
        context: context,
        builder: (context) => DialogErrorWidget(
          errorText:
              'Harap pilih Semester, Kelas, dan Mata Pelajaran terlebih dahulu',
        ),
      );
      return;
    }

    try {
      // Ambil data dari state terakhir
      final List<NilaiAkhir> dataToExport;

      if (nilaiAkhirState is AsyncData<List<NilaiAkhir>>) {
        dataToExport = notifier.allData;
      } else {
        // Gunakan data cache jika state sedang loading/error
        dataToExport = notifier.lastListNilaiAkhir;
      }

      if (dataToExport.isEmpty) {
        showDialog(
          context: context,
          builder: (context) =>
              DialogErrorWidget(errorText: 'Tidak ada data untuk diekspor'),
        );
        return;
      }

      // Generate KD_SEMESTER dari selectedSemester
      final kdSemester = _generateKdSemester(selectedSemester!);
      final semesterKe = _getSemesterKe(selectedSemester!);
      final tahun = _getTahunFromSemester(selectedSemester!);

      // Create Excel workbook
      final workbook = xlsio.Workbook();
      final sheet = workbook.worksheets[0];

      // var workbook = excel.Excel.createExcel();
      // var sheet = workbook['Sheet1'];

      // MERGE DAN ISI DATA
      sheet.getRangeByName('A1:F1').merge();
      sheet
          .getRangeByName('A1')
          .setText('FORMAR IMPORT NILAI AKHIR RAPOR SISWA');
      sheet.getRangeByName('A2:E2').merge();
      sheet.getRangeByName('A2').setText('SEKOLAH');
      sheet.getRangeByName('F2').setText(': SMA NEGERI 2 SIDOARJO');
      sheet.getRangeByName('A3:E3').merge();
      sheet.getRangeByName('A3').setText('KD SEMESTER');
      sheet.getRangeByName('F3').setText(': $kdSemester');
      sheet.getRangeByName('A4:E4').merge();
      sheet.getRangeByName('A4').setText('MATA PELAJARAN');
      sheet.getRangeByName('F4').setText(': $selectedMapel');
      sheet.getRangeByName('A5:E5').merge();
      sheet.getRangeByName('A5').setText('KELAS');
      sheet.getRangeByName('F5').setText(': $selectedKelas');
      sheet.getRangeByName('A6:E6').merge();
      sheet.getRangeByName('A6').setText('SEMESTER KE');
      sheet.getRangeByName('F6').setText(': $semesterKe');
      sheet.getRangeByName('A7:E7').merge();
      sheet.getRangeByName('A7').setText('ID FORMAT');
      sheet.getRangeByName('F7').setText('F_NILAI_RAPOR');
      sheet.getRangeByName('A8:A10').merge();
      sheet.getRangeByName('A8').setText('NO');
      sheet.getRangeByName('B8:E10').merge();
      sheet.getRangeByName('B8').setText('NAMA SISWA');
      sheet.getRangeByName('F8:F10').merge();
      sheet.getRangeByName('F8').setText('NISN');
      sheet.getRangeByName('G8:G10').merge();
      sheet.getRangeByName('G8').setText('NIS');
      sheet.getRangeByName('H8:J8').merge();
      sheet.getRangeByName('H8').setText('NILAI RAPOR SISWA');
      sheet.getRangeByName('H9:H10').merge();
      sheet.getRangeByName('H9:H10').setText('NILAI');
      sheet.getRangeByName('I9').setText('DESKRIPSI KETERCAPAIAN KOMPETENSI');
      sheet.getRangeByName('I9:J9').merge();
      sheet.getRangeByName('I10').setText('Capaian Tertinggi');
      sheet.getRangeByName('J10').setText('Capaian Terendah');

      // == STYLE ==
      final headerRange = sheet.getRangeByName('A1:F7');
      headerRange.cellStyle.bold = true;

      final header2Range = sheet.getRangeByName('A8:J10');
      header2Range.cellStyle.backColor = '#C6E0B4';
      header2Range.cellStyle.bold = true;
      header2Range.cellStyle.hAlign = xlsio.HAlignType.center;
      header2Range.cellStyle.vAlign = xlsio.VAlignType.center;

      int totalRow = 0;
      // === TABLE DATA ===
      for (int i = 0; i < dataToExport.length; i++) {
        final nilai = dataToExport[i];
        final rowIndex = 11 + i;
        totalRow = rowIndex;

        sheet.getRangeByIndex(rowIndex, 1).setText((i + 1).toString());
        sheet.getRangeByIndex(rowIndex, 1).cellStyle
          ..hAlign = xlsio.HAlignType.right
          ..vAlign = xlsio.VAlignType.top;
        sheet.getRangeByIndex(rowIndex, 1).columnWidth = 4.14;

        sheet.getRangeByIndex(rowIndex, 2).setText(nilai.namaSiswa);
        sheet.getRangeByName('B$rowIndex:E$rowIndex').merge();
        sheet.getRangeByName('B$rowIndex:E$rowIndex').cellStyle
          ..hAlign = xlsio.HAlignType.left
          ..vAlign = xlsio.VAlignType.top;
        sheet.getRangeByName('B$rowIndex:E$rowIndex').columnWidth = 8.43;

        sheet.getRangeByIndex(rowIndex, 6).setText(nilai.nisn.toString());
        sheet.getRangeByIndex(rowIndex, 6).cellStyle
          ..hAlign = xlsio.HAlignType.left
          ..vAlign = xlsio.VAlignType.top;
        sheet.getRangeByIndex(rowIndex, 6).columnWidth = 14.71;

        sheet.getRangeByIndex(rowIndex, 7).setText(nilai.nis.toString());
        sheet.getRangeByIndex(rowIndex, 7).merge();
        sheet.getRangeByIndex(rowIndex, 7).cellStyle
          ..hAlign = xlsio.HAlignType.left
          ..vAlign = xlsio.VAlignType.top;
        sheet.getRangeByIndex(rowIndex, 7).columnWidth = 8.43;

        sheet.getRangeByIndex(rowIndex, 8).setText(nilai.nilaiAkhir.toString());
        sheet.getRangeByIndex(rowIndex, 8).cellStyle
          ..hAlign = xlsio.HAlignType.left
          ..vAlign = xlsio.VAlignType.top;
        sheet.getRangeByIndex(rowIndex, 8).columnWidth = 8.43;

        sheet.getRangeByIndex(rowIndex, 9).setText(nilai.cpTertinggi ?? '');
        sheet.getRangeByIndex(rowIndex, 9).cellStyle
          ..hAlign = xlsio.HAlignType.justify
          ..vAlign = xlsio.VAlignType.top;
        sheet.getRangeByIndex(rowIndex, 9).columnWidth = 50;

        sheet.getRangeByIndex(rowIndex, 10).setText(nilai.cpTerendah ?? '');
        sheet.getRangeByIndex(rowIndex, 10).cellStyle
          ..hAlign = xlsio.HAlignType.justify
          ..vAlign = xlsio.VAlignType.top;
        sheet.getRangeByIndex(rowIndex, 10).columnWidth = 50;
      }

      sheet.getRangeByName('A8:J$totalRow').cellStyle
        ..borders.all.lineStyle = xlsio.LineStyle.thin
        ..borders.all.color = '#000000';

      // Save Excel file
      final fileBytes = workbook.saveAsStream();
      if (fileBytes != null) {
        if (kIsWeb) {
          final Uint8List data = Uint8List.fromList(fileBytes);
          final blob = html.Blob([data]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          final fileName =
              'NILAI_AKHIR_${selectedKelas!.replaceAll(' ', '_')}_${tahun}_$semesterKe.xlsx';

          final anchor = html.AnchorElement(href: url)
            ..setAttribute("download", fileName)
            ..click();

          html.Url.revokeObjectUrl(url);

          showDialog(
            context: context,
            builder: (context) => DialogSuccessWidget(
              succesText: 'File berhasil diunduh melalui browser: $fileName',
            ),
          );
        } else {
          // Get download directory
          final directory = await getDownloadsDirectory();
          if (directory != null) {
            final fileName =
                'NILAI_AKHIR_${selectedKelas!.replaceAll(' ', '_')}_${tahun}_$semesterKe.xlsx';
            final file = File('${directory.path}/$fileName');

            await file.writeAsBytes(fileBytes);

            showDialog(
              context: context,
              builder: (context) => DialogSuccessWidget(
                succesText:
                    'File berhasil diekspor: $fileName\nLokasi: ${directory.path}',
              ),
            );
          } else {
            // Fallback: use file picker if downloads directory is not available
            final String? savePath = await FilePicker.saveFile(
              fileName:
                  'NILAI_AKHIR_${selectedKelas!.replaceAll(' ', '_')}_${tahun}_$semesterKe.xlsx',
              dialogTitle: 'Simpan File Excel',
            );

            if (savePath != null) {
              final file = File(savePath);
              await file.writeAsBytes(fileBytes);
              showDialog(
                context: context,
                builder: (context) => DialogSuccessWidget(
                  succesText: 'File berhasil diekspor: $savePath',
                ),
              );
            } else {
              showDialog(
                context: context,
                builder: (context) => DialogSuccessWidget(
                  succesText: 'Tidak dapat mengakses folder download',
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      print('Error exporting to Excel: $e');
      showDialog(
        context: context,
        builder: (context) => DialogSuccessWidget(
          succesText: 'Terjadi kesalahan saat mengekspor data: $e',
        ),
      );
    }
  }

  // Helper functions
  String _generateKdSemester(String semester) {
    if (semester.toLowerCase().contains('ganjil')) {
      final year = _getTahunFromSemester(semester);
      return '${year}1/1';
    } else if (semester.toLowerCase().contains('genap')) {
      final year = _getTahunFromSemester(semester);
      return '${year}2/2';
    }
    return '';
  }

  int _getSemesterKe(String semester) {
    return semester.toLowerCase().contains('ganjil') ? 1 : 2;
  }

  String _getTahunFromSemester(String semester) {
    // Extract year from semester string, e.g., "Semester Ganjil 2024/2025" -> "2024"
    final regex = RegExp(r'(\d{4})');
    final match = regex.firstMatch(semester);
    return match?.group(1) ?? '2024'; // default to 2024 if not found
  }

  @override
  Widget build(BuildContext context) {
    final nilaiAkhirState = ref.watch(nilaiAkhirNotifierProvider);
    final notifier = ref.read(nilaiAkhirNotifierProvider.notifier);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWidget(
              headerTitle: "NILAI AKHIR",
              btnAddTitle: "",
              showExportBtn: true,
              showImportBtn: false,
              showAddBtn: false,
              addAction: null,
              exportAction: _exportToExcel,
              importAction: null,
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Header2Widget(
                    header2Title: "Daftar Nilai Akhir",
                    subtitle: "Lakukan pencarian nilai akhir",
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
                                selectedMapelId = null;
                                final semester = semesterList.firstWhere(
                                  (e) => e.judulSemester == value,
                                );
                                selectedSemesterId = semester.semesterId;

                                notifier
                                    .fetchKelasByTahunAjaran(
                                      tahunAjaranId: semester.tahunAjaranId,
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
                                selectedMapelId = mapel.mapelId;

                                notifier.resetAndFetch(
                                  search: '',
                                  page: 1,
                                  semesterId: selectedSemesterId,
                                  kelasId: selectedKelasId,
                                  mapelId: selectedMapelId,
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
                  nilaiAkhirState.when(
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
                          .read(nilaiAkhirNotifierProvider.notifier)
                          .lastListNilaiAkhir;

                      return builNilaiAkhirTable(context, cachedData, ref);
                    },
                    data: (nilaiAkhirList) =>
                        builNilaiAkhirTable(context, nilaiAkhirList, ref),
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

Widget builNilaiAkhirTable(
  BuildContext context,
  List<NilaiAkhir> nilaiAkhirList,
  WidgetRef ref,
) {
  if (nilaiAkhirList.isEmpty) {
    return const Center(child: Text("Data nilai akhir tidak tersedia."));
  }

  final notifier = ref.read(nilaiAkhirNotifierProvider.notifier);

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
                  columnWidths: const <int, TableColumnWidth>{
                    0: IntrinsicColumnWidth(),
                    1: IntrinsicColumnWidth(),
                    2: IntrinsicColumnWidth(),
                    3: IntrinsicColumnWidth(),
                    4: IntrinsicColumnWidth(),
                    5: IntrinsicColumnWidth(),
                    6: FixedColumnWidth(200),
                    7: FixedColumnWidth(200),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      children: const [
                        TableHeaderCell("NIS"),
                        TableHeaderCell("NISN"),
                        TableHeaderCell("Nama"),
                        TableHeaderCell("Kelas"),
                        TableHeaderCell("Mata Pelajaran"),
                        TableHeaderCell("Nilai Akhir"),
                        TableHeaderCell("Capaian Terendah"),
                        TableHeaderCell("Capaian Tertinggi"),
                      ],
                    ),
                    for (final nilaiAkhir in nilaiAkhirList)
                      TableRow(
                        children: [
                          TableCellWidget(nilaiAkhir.nis.toString()),
                          TableCellWidget(nilaiAkhir.nisn.toString()),
                          TableCellWidget(nilaiAkhir.namaSiswa),
                          TableCellWidget(nilaiAkhir.namaKelas),
                          TableCellWidget(nilaiAkhir.judulMapel),
                          TableCellWidget(nilaiAkhir.nilaiAkhir.toString()),
                          TableCellWidget(nilaiAkhir.cpTerendah ?? "-"),
                          TableCellWidget(nilaiAkhir.cpTertinggi ?? "-"),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 16),

      /// Pagination
      LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Menampilkan ${nilaiAkhirList.length} dari ${notifier.total} data",
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
                  "Menampilkan ${nilaiAkhirList.length} dari ${notifier.total} data",
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

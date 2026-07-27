import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../models/staff/data_siswa_model.dart';
import '../../../../models/staff/filtering_model.dart';
import '../../../controllers/staff/data_siswa_riverpod.dart';
import '../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../shared_widgets/general_old/dialog_konfirmasi_widget.dart';
import '../../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../../shared_widgets/general_old/filter_dropdown.dart';
import '../../../shared_widgets/general_old/header2_widget.dart';
import '../../../shared_widgets/general_old/header_widget.dart';
import '../../../shared_widgets/general_old/search_textfield_widget.dart';
import '../../../shared_widgets/general_old/table_cell.dart';
import '../../../shared_widgets/general_old/table_header_cell.dart';
import 'widget/dialog_tambah_or_edit_siswa.dart';

class DataSiswaScreen extends ConsumerStatefulWidget {
  const DataSiswaScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DataSiswaScreenState();
}

class _DataSiswaScreenState extends ConsumerState<DataSiswaScreen> {
  String? selectedTahunAjaran;
  int? selectedTahunAjaranId;
  String? selectedJenjang;
  String? selectedJurusan;

  List<TahunAjaran> tahunAjaranList = [];

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final list = await ref
          .read(dataSiswaNotifierProvider.notifier)
          .fetchTahunAjaran();

      if (!mounted) return;
      setState(() {
        tahunAjaranList = list;
        selectedTahunAjaran = tahunAjaranList.first.tahunAjaran;
        selectedTahunAjaranId = tahunAjaranList.first.id;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final siswaState = ref.watch(dataSiswaNotifierProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWidget(
              headerTitle: "DATA SISWA",
              btnAddTitle: "Tambah Siswa",
              showExportBtn: false,
              showImportBtn: true,
              showAddBtn: true,
              addAction: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      const DialogTambahOrEditSiswa(dataSiswa: null),
                );
              },
              exportAction: () {},
              importAction: () async {
                final resultMessage = await ref
                    .read(dataSiswaNotifierProvider.notifier)
                    .pickAndImportExcel();

                if (resultMessage != null && resultMessage.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return DialogSuccessWidget(succesText: resultMessage);
                    },
                  );
                }
              },
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Header2Widget(
                        header2Title: "Daftar Siswa",
                        subtitle: "Kelola atau lakukan pencarian data siswa",
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SearchTextFieldWidget(
                            hintText: "Cari dengan nama atau NIS/NISN...",
                            onChangedSearch: (value) {
                              ref
                                  .read(dataSiswaNotifierProvider.notifier)
                                  .resetAndFetch(search: value);
                            },
                          ),
                          // bagian filter
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
                                pHintText: "Semua Tahun Ajaran",
                                widhtDropdown: 210,
                                valueParams: selectedTahunAjaran,
                                pItems: tahunAjaranList
                                    .map((e) => e.tahunAjaran)
                                    .toList(),
                                pOnChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      final selected = tahunAjaranList
                                          .firstWhere(
                                            (e) => e.tahunAjaran == value,
                                          );

                                      selectedTahunAjaran =
                                          selected.tahunAjaran;
                                      selectedTahunAjaranId = selected.id;

                                      ref
                                          .read(
                                            dataSiswaNotifierProvider.notifier,
                                          )
                                          .filterDataSiswa(
                                            pTahunAjaranId:
                                                selectedTahunAjaranId,
                                            pJenjang: selectedJenjang,
                                            pJurusan: selectedJurusan,
                                          );
                                    });
                                  }
                                },
                              ),
                              SizedBox(width: 10),
                              FilterDropdownWidget(
                                pHintText: "Semua Jenjang",
                                valueParams: selectedJenjang,
                                pItems: ['Semua Jenjang', '10', '11', '12'],
                                pOnChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      if (value == 'Semua Jenjang') {
                                        selectedJenjang = null;
                                        selectedJurusan = null;
                                      } else {
                                        selectedJurusan = null;
                                        selectedJenjang = value;
                                      }
                                    });

                                    ref
                                        .read(
                                          dataSiswaNotifierProvider.notifier,
                                        )
                                        .filterDataSiswa(
                                          pTahunAjaranId: selectedTahunAjaranId,
                                          pJenjang: selectedJenjang,
                                          pJurusan: selectedJurusan,
                                        );
                                  }
                                },
                                widhtDropdown: 180,
                              ),
                              SizedBox(width: 10),
                              FilterDropdownWidget(
                                pHintText: "Semua Jurusan",
                                valueParams: selectedJurusan,
                                pItems: selectedJenjang == '10'
                                    ? ["Fase E"]
                                    : [
                                        "Semua Jurusan",
                                        "MIPA",
                                        "IPS",
                                        "Bahasa",
                                      ],
                                pOnChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      if (value == "Semua Jurusan") {
                                        selectedJurusan = null;
                                      } else {
                                        selectedJurusan = value;
                                      }
                                      ref
                                          .read(
                                            dataSiswaNotifierProvider.notifier,
                                          )
                                          .filterDataSiswa(
                                            pTahunAjaranId:
                                                selectedTahunAjaranId,
                                            pJenjang: selectedJenjang,
                                            pJurusan: selectedJurusan,
                                          );
                                    });
                                  }
                                },
                                widhtDropdown: 180,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  siswaState.when(
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
                          .read(dataSiswaNotifierProvider.notifier)
                          .lastSiswaList;

                      return buildSiswaTable(context, cachedData, ref);
                    },
                    data: (siswaList) =>
                        buildSiswaTable(context, siswaList, ref),
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

Widget buildSiswaTable(
  BuildContext context,
  List<Siswa> siswaList,
  WidgetRef ref,
) {
  if (siswaList.isEmpty) {
    return const Center(child: Text("Data siswa tidak tersedia."));
  }

  final notifier = ref.read(dataSiswaNotifierProvider.notifier);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black26, width: 1.2), // border luar
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
                    ), // garis antar baris
                    // tidak pakai left/right/top/bottom supaya tidak double border
                  ),
                  columnWidths: const <int, TableColumnWidth>{
                    0: IntrinsicColumnWidth(),
                    1: IntrinsicColumnWidth(),
                    2: IntrinsicColumnWidth(),
                    3: IntrinsicColumnWidth(),
                    4: IntrinsicColumnWidth(),
                    5: IntrinsicColumnWidth(),
                    6: FixedColumnWidth(50),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      children: const [
                        TableHeaderCell("NIS"),
                        TableHeaderCell("NISN"),
                        TableHeaderCell("Nama"),
                        TableHeaderCell("Kelas"),
                        TableHeaderCell("Nomor Telepon"),
                        TableHeaderCell("Alamat"),
                        TableHeaderCell("Aksi"),
                      ],
                    ),
                    for (final siswa in siswaList)
                      TableRow(
                        children: [
                          TableCellWidget(siswa.nis.toString()),
                          TableCellWidget(siswa.nisn.toString()),
                          TableCellWidget(siswa.nama),
                          TableCellWidget(
                            siswa.kelas.isNotEmpty
                                ? siswa.kelas
                                      .map((e) => e["nama_kelas"] ?? "-")
                                      .join("")
                                : "-",
                          ),
                          TableCellWidget(siswa.nomorTelepon.toString()),
                          TableCellWidget(siswa.alamat),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                materialTapTargetSize: MaterialTapTargetSize
                                    .shrinkWrap, // biar lebih kecil
                              ),
                              child: PopupMenuButton<String>(
                                position: PopupMenuPosition.under,
                                color: Colors.white,
                                icon: const Icon(
                                  Symbols.more_horiz,
                                ), // tombol "..."
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    // Aksi edit
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          DialogTambahOrEditSiswa(
                                            dataSiswa: siswa,
                                          ),
                                    );
                                  } else if (value == 'hapus') {
                                    // Aksi hapus
                                    showDialog(
                                      context: context,
                                      builder: (context) => DialogKonfirmasiWidget(
                                        confirmText:
                                            "Apakah anda yakin ingin menghapus siswa '${siswa.nama} (NISN : ${siswa.nisn})' ?",
                                        confirmAction: () async {
                                          // Tampilkan dialog loading
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) => const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );

                                          try {
                                            final success = await ref
                                                .read(
                                                  dataSiswaNotifierProvider
                                                      .notifier,
                                                )
                                                .deleteSiswa(
                                                  userId: siswa.userId,
                                                );
                                            Navigator.pop(context);

                                            if (success) {
                                              // Close dialog
                                              Navigator.pop(context);

                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    DialogSuccessWidget(
                                                      succesText:
                                                          "Data siswa berhasil dihapus",
                                                    ),
                                              );
                                            }
                                          } catch (e) {
                                            // Remove loading indicator
                                            Navigator.pop(context);

                                            showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  DialogSuccessWidget(
                                                    succesText:
                                                        "Gagal menghapus guru: ${e.toString()}",
                                                  ),
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: SizedBox(
                                      height: 15,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            color: Colors.orange,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Lihat Detail & Edit',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'hapus',
                                    child: SizedBox(
                                      height: 15,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Hapus',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
          // Gunakan breakpoint 600px untuk menentukan layout
          if (constraints.maxWidth < 600) {
            // Layout untuk layar kecil (mobile)
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Teks informasi di atas
                Text(
                  "Menampilkan ${siswaList.length} dari ${notifier.total} data",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),

                // Kontrol pagination di bawah
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

                      /// Pagination dengan ellipsis
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
            // Layout untuk layar besar (desktop)
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Menampilkan ${siswaList.length} dari ${notifier.total} data",
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

                    /// Pagination dengan ellipsis
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

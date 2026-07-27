import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../controllers/staff/mata_pelajaran_riverpod.dart';
import '../../../shared_widgets/general_old/dialog_konfirmasi_widget.dart';
import '../../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../../shared_widgets/general_old/filter_dropdown.dart';
import '../../../shared_widgets/general_old/header2_widget.dart';
import '../../../shared_widgets/general_old/header_widget.dart';
import '../../../shared_widgets/general_old/search_textfield_widget.dart';
import '../../../shared_widgets/general_old/table_cell.dart';
import '../../../shared_widgets/general_old/table_header_cell.dart';
import 'widget/dialog_tambah_or_edit_mapel.dart';

class MataPelajaranScreen extends ConsumerStatefulWidget {
  const MataPelajaranScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MataPelajaranScreenState();
}

class _MataPelajaranScreenState extends ConsumerState<MataPelajaranScreen> {
  String? selectedJenjang;
  String? selectedJurusan;

  @override
  Widget build(BuildContext context) {
    final mapelState = ref.watch(mataPelajaranNotifierProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWidget(
              headerTitle: "MATA PELAJARAN",
              btnAddTitle: "Tambah Mata Pelajaran",
              showExportBtn: false,
              showImportBtn: false,
              showAddBtn: true,
              addAction: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      DialogTambahOrEditMapel(dataMapel: null),
                );
              },
              exportAction: () {},
              importAction: () {},
            ),
            SizedBox(height: 20),
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
                    header2Title: "Daftar Mata Pelajaran",
                    subtitle: "Kelola atau lakukan pencarian mata pelajaran.",
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SearchTextFieldWidget(
                        hintText: "Cari berdasarkan kode atau judul...",
                        onChangedSearch: (value) {
                          ref
                              .read(mataPelajaranNotifierProvider.notifier)
                              .resetAndFetch(search: value, page: 1);
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
                            pHintText: "Semua Jenjang",
                            valueParams: selectedJenjang,
                            pItems: ["Semua Jenjang", "10", "11", "12"],
                            pOnChanged: (value) {
                              setState(() {
                                if (value == 'Semua Jenjang') {
                                  selectedJenjang = null;
                                  selectedJurusan = null;
                                } else {
                                  selectedJenjang = value;
                                  selectedJurusan = null;
                                }
                                ref
                                    .read(
                                      mataPelajaranNotifierProvider.notifier,
                                    )
                                    .filterMataPelajaran(
                                      pJenjang: selectedJenjang,
                                      pJurusan: selectedJurusan,
                                    );
                              });
                            },
                            widhtDropdown: 180,
                          ),
                          SizedBox(width: 10),
                          FilterDropdownWidget(
                            pHintText: "Semua Jurusan",
                            valueParams: selectedJurusan,
                            pItems: selectedJenjang == "10"
                                ? ["Fase E"]
                                : [
                                    "Semua Jurusan",
                                    "Fase E",
                                    "MIPA",
                                    "IPS",
                                    "Bahasa",
                                  ],
                            pOnChanged: (value) {
                              setState(() {
                                if (value == "Semua Jurusan") {
                                  selectedJurusan = null;
                                } else {
                                  selectedJurusan = value;
                                }

                                ref
                                    .read(
                                      mataPelajaranNotifierProvider.notifier,
                                    )
                                    .filterMataPelajaran(
                                      pJenjang: selectedJenjang,
                                      pJurusan: selectedJurusan,
                                    );
                              });
                            },
                            widhtDropdown: 180,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  mapelState.when(
                    data: (mapelList) {
                      if (mapelList.isEmpty) {
                        return const Center(
                          child: Text("Data kelas tidak tersedia."),
                        );
                      }

                      final notifier = ref.read(
                        mataPelajaranNotifierProvider.notifier,
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: Colors.black26,
                                width: 1.2,
                              ), // border luar
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: constraints.maxWidth,
                                    ),
                                    child: Table(
                                      border: const TableBorder(
                                        horizontalInside: BorderSide(
                                          width: 1,
                                          color: Colors.black26,
                                        ), // garis antar baris
                                        // tidak pakai left/right/top/bottom supaya tidak double border
                                      ),
                                      columnWidths:
                                          const <int, TableColumnWidth>{
                                            0: IntrinsicColumnWidth(),
                                            1: IntrinsicColumnWidth(),
                                            2: IntrinsicColumnWidth(),
                                            3: IntrinsicColumnWidth(),
                                            4: IntrinsicColumnWidth(),
                                            5: IntrinsicColumnWidth(),
                                            6: FixedColumnWidth(50),
                                          },
                                      defaultVerticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      children: [
                                        TableRow(
                                          children: const [
                                            TableHeaderCell("Kode"),
                                            TableHeaderCell(
                                              "Nama Mata Pelajaran",
                                            ),
                                            TableHeaderCell("Jenjang"),
                                            TableHeaderCell("Jurusan"),
                                            TableHeaderCell(
                                              "Koordinator Mapel",
                                            ),
                                            TableHeaderCell("Aksi"),
                                          ],
                                        ),
                                        for (final mapel in mapelList)
                                          TableRow(
                                            children: [
                                              TableCellWidget(mapel.kode),
                                              TableCellWidget(mapel.namaMapel),
                                              TableCellWidget(mapel.jenjang),
                                              TableCellWidget(mapel.jurusan),
                                              // TableCellWidget(
                                              //   mapel.guruPengampu.isNotEmpty
                                              //       ? mapel.guruPengampu
                                              //           .map(
                                              //             (e) =>
                                              //                 e["Guru Pengampu"] ??
                                              //                 "-",
                                              //           )
                                              //           .join(", ")
                                              //       : "-",
                                              // ),
                                              TableCellWidget(
                                                mapel.koorMapel ?? '-',
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  6.0,
                                                ),
                                                child: Theme(
                                                  data: Theme.of(context).copyWith(
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap, // biar lebih kecil
                                                  ),
                                                  child: PopupMenuButton<String>(
                                                    position:
                                                        PopupMenuPosition.under,
                                                    color: Colors.white,
                                                    icon: const Icon(
                                                      Symbols.more_horiz,
                                                    ),
                                                    onSelected: (value) {
                                                      if (value == 'detail') {
                                                        // Aksi lihat detail
                                                      } else if (value ==
                                                          'edit') {
                                                        // Aksi edit
                                                        // showDialog(
                                                        //   context: context,
                                                        //   builder:
                                                        //       (context) =>
                                                        //           DialogEditKelas(
                                                        //             dataKelas: kelas,
                                                        //           ),
                                                        // );
                                                      } else if (value ==
                                                          'hapus') {
                                                        // Aksi hapus
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => DialogKonfirmasiWidget(
                                                            confirmText:
                                                                "Apakah anda yakin ingin menghapus mata pelajaran '${mapel.namaMapel}' ?",
                                                            confirmAction: () async {
                                                              // Tampilkan dialog loading
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                barrierDismissible:
                                                                    false,
                                                                builder: (context) =>
                                                                    const Center(
                                                                      child:
                                                                          CircularProgressIndicator(),
                                                                    ),
                                                              );

                                                              try {
                                                                final success = await ref
                                                                    .read(
                                                                      mataPelajaranNotifierProvider
                                                                          .notifier,
                                                                    )
                                                                    .deleteMataPelajaran(
                                                                      mapelId:
                                                                          mapel
                                                                              .id,
                                                                    );
                                                                Navigator.pop(
                                                                  context,
                                                                );

                                                                if (success) {
                                                                  // Close dialog
                                                                  Navigator.pop(
                                                                    context,
                                                                  );

                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (
                                                                          context,
                                                                        ) => DialogSuccessWidget(
                                                                          succesText:
                                                                              "Mata pelajaran berhasil dihapus",
                                                                        ),
                                                                  );
                                                                }
                                                              } catch (e) {
                                                                // Remove loading indicator
                                                                Navigator.pop(
                                                                  context,
                                                                );

                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (
                                                                        context,
                                                                      ) => DialogSuccessWidget(
                                                                        succesText:
                                                                            "Gagal menghapus mata pelajaran: ${e.toString()}",
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
                                                        value: 'detail',
                                                        child: SizedBox(
                                                          height: 15,
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .visibility,
                                                                color:
                                                                    Colors.blue,
                                                                size: 18,
                                                              ),
                                                              SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                'Lihat Detail',
                                                                style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      // const PopupMenuItem(
                                                      //   value: 'edit',
                                                      //   child: SizedBox(
                                                      //     height: 15,
                                                      //     child: Row(
                                                      //       children: [
                                                      //         Icon(
                                                      //           Icons.edit,
                                                      //           color:
                                                      //               Colors.orange,
                                                      //           size: 18,
                                                      //         ),
                                                      //         SizedBox(width: 8),
                                                      //         Text(
                                                      //           'Edit',
                                                      //           style: TextStyle(
                                                      //             fontSize: 12,
                                                      //           ),
                                                      //         ),
                                                      //       ],
                                                      //     ),
                                                      //   ),
                                                      // ),
                                                      const PopupMenuItem(
                                                        value: 'hapus',
                                                        child: SizedBox(
                                                          height: 15,
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons.delete,
                                                                color:
                                                                    Colors.red,
                                                                size: 18,
                                                              ),
                                                              SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                'Hapus',
                                                                style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                    ),
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
                                      "Menampilkan ${mapelList.length} dari ${notifier.total} data",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 12),

                                    // Kontrol pagination di bawah
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                            onPressed: notifier.currentPage > 1
                                                ? () => notifier
                                                      .fetchPreviousPage()
                                                : null,
                                            child: const Text("Sebelumnya"),
                                          ),
                                          const SizedBox(width: 8),

                                          /// Pagination dengan ellipsis
                                          ..._buildPaginationButtons(
                                            notifier.totalPage,
                                            notifier.currentPage,
                                            (page) => notifier.resetAndFetch(
                                              page: page,
                                            ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Menampilkan ${mapelList.length} dari ${notifier.total} data",
                                    ),
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed: notifier.currentPage > 1
                                              ? () =>
                                                    notifier.fetchPreviousPage()
                                              : null,
                                          child: const Text("Sebelumnya"),
                                        ),
                                        const SizedBox(width: 8),

                                        /// Pagination dengan ellipsis
                                        ..._buildPaginationButtons(
                                          notifier.totalPage,
                                          notifier.currentPage,
                                          (page) => notifier.resetAndFetch(
                                            page: page,
                                          ),
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
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text("Error: $err")),
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

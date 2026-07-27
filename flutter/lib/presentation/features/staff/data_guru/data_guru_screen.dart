// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../models/staff/data_guru_model.dart';
import '../../../controllers/staff/data_guru_riverpod.dart';
import '../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../shared_widgets/general_old/dialog_konfirmasi_widget.dart';
import '../../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../../shared_widgets/general_old/header_widget.dart';
import '../../../shared_widgets/general_old/search_textfield_widget.dart';
import '../../../shared_widgets/general_old/table_cell.dart';
import '../../../shared_widgets/general_old/table_header_cell.dart';
import 'widget/dialog_detail_guru.dart';
import 'widget/dialog_tambah_or_edit_guru.dart';

class DataGuruScreen extends ConsumerWidget {
  const DataGuruScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guruState = ref.watch(dataGuruNotifierProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWidget(
              headerTitle: "DATA GURU",
              btnAddTitle: "Tambah Guru",
              showExportBtn: false,
              showImportBtn: false,
              showAddBtn: true,
              addAction: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      const DialogTambahOrEditGuru(dataGuru: null),
                );
              },
              exportAction: () {},
              importAction: () {},
            ),
            const SizedBox(height: 20),
            SearchTextFieldWidget(
              hintText: "Cari dengan nama atau NIP/NUPTK...",
              onChangedSearch: (value) {
                ref
                    .read(dataGuruNotifierProvider.notifier)
                    .resetAndFetch(search: value, page: 1);
              },
            ),
            const SizedBox(height: 20),
            guruState.when(
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
                    .read(dataGuruNotifierProvider.notifier)
                    .lastGuruList;

                return buildGuruTable(context, cachedData, ref);
              },
              data: (guruList) => buildGuruTable(context, guruList, ref),
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

Widget buildGuruTable(
  BuildContext context,
  List<Guru> guruList,
  WidgetRef ref,
) {
  if (guruList.isEmpty) {
    return const Center(child: Text("Data guru tidak tersedia."));
  }

  final notifier = ref.read(dataGuruNotifierProvider.notifier);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black26, width: 1.2), // border luar
        ),
        clipBehavior: Clip.hardEdge, // penting biar isi ikut radius
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
                    3: FixedColumnWidth(200),
                    4: FixedColumnWidth(20),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      // decoration: BoxDecoration(
                      //   color: Colors.grey.shade200,
                      // ),
                      children: const [
                        TableHeaderCell("NIP/NUPTK"),
                        TableHeaderCell("Nama"),
                        TableHeaderCell("Telepon"),
                        TableHeaderCell("Mata Pelajaran"),
                        TableHeaderCell("Aksi"),
                      ],
                    ),
                    for (final guru in guruList)
                      TableRow(
                        children: [
                          TableCellWidget(guru.nipNuptk.toString()),
                          TableCellWidget(guru.nama),
                          TableCellWidget(guru.nomorTelepon.toString()),
                          TableCellWidget(
                            guru.mataPelajaran.isNotEmpty
                                ? guru.mataPelajaran
                                      .map((e) => e["judul"] ?? "-")
                                      .join(", ")
                                : "-",
                          ),
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
                                  if (value == 'detail') {
                                    // Aksi lihat detail
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          DialogDetailGuru(guru: guru),
                                    );
                                    print("Lihat detail");
                                  } else if (value == 'edit') {
                                    // Aksi edit
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          DialogTambahOrEditGuru(
                                            dataGuru: guru,
                                          ),
                                    );
                                    print("Edit data");
                                  } else if (value == 'hapus') {
                                    // Aksi hapus
                                    showDialog(
                                      context: context,
                                      builder: (context) => DialogKonfirmasiWidget(
                                        confirmText:
                                            "Apakah anda yakin ingin menghapus guru '${guru.nama} (NIP/NUPTK : ${guru.nipNuptk})' ?",
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
                                                  dataGuruNotifierProvider
                                                      .notifier,
                                                )
                                                .deleteGuru(
                                                  userId: guru.userId,
                                                );
                                            Navigator.pop(context);

                                            if (success) {
                                              // Close dialog
                                              Navigator.pop(context);

                                              // Show success message
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

                                            // Show error message
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Gagal menghapus guru: ${e.toString()}',
                                                ),
                                                backgroundColor: Colors.red,
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
                                            Icons.visibility,
                                            color: Colors.blue,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Lihat Detail',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
                                            'Edit',
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
                  "Menampilkan ${guruList.length} dari ${notifier.total} data",
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
                  "Menampilkan ${guruList.length} dari ${notifier.total} data",
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

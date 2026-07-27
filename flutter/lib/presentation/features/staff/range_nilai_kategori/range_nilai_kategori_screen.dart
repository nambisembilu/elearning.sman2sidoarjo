import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../models/staff/range_nilai_kategori_model.dart';
import '../../../controllers/staff/range_nilai_kategori/range_nilai_kategori_riverpod.dart';
import '../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../shared_widgets/general_old/dialog_konfirmasi_widget.dart';
import '../../../shared_widgets/general_old/header2_widget.dart';
import '../../../shared_widgets/general_old/header_widget.dart';
import '../../../shared_widgets/general_old/table_cell.dart';
import '../../../shared_widgets/general_old/table_header_cell.dart';
import 'widget/dialog_tambah_kategori.dart';

class RangeNilaiKategoriScreen extends ConsumerStatefulWidget {
  const RangeNilaiKategoriScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RangeNilaiKategoriScreenState();
}

class _RangeNilaiKategoriScreenState
    extends ConsumerState<RangeNilaiKategoriScreen> {
  @override
  Widget build(BuildContext context) {
    final rangeNilaiKategoriState = ref.watch(
      rangeNilaiKategoriNotifierProvider,
    );

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWidget(
              headerTitle: "RANGE NILAI KATEGORI",
              btnAddTitle: "Tambah Kategori",
              showExportBtn: false,
              showImportBtn: false,
              showAddBtn: true,
              addAction: () {
                showDialog(
                  context: context,
                  builder: (context) => const DialogTambahKategori(),
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
                    header2Title: "Pengaturan Range Nilai Kategori",
                    subtitle:
                        "Tentukan range nilai untuk setiap kategori penilaian",
                  ),
                  SizedBox(height: 15),
                  rangeNilaiKategoriState.when(
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
                          .read(rangeNilaiKategoriNotifierProvider.notifier)
                          .lastRange;

                      return buildRangeTable(context, cachedData, ref);
                    },
                    data: (rangeList) =>
                        buildRangeTable(context, rangeList, ref),
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

Widget buildRangeTable(
  BuildContext context,
  List<RangeNilaiKategori> rangeList,
  WidgetRef ref,
) {
  if (rangeList.isEmpty) {
    return const Center(
      child: Text("Data range nilai kategori tidak tersedia"),
    );
  }
  // final notifier = ref.read(
  //   rangeNilaiKategoriNotifierProvider.notifier,
  // );

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
                    4: FixedColumnWidth(50),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,

                  children: [
                    TableRow(
                      children: const [
                        TableHeaderCell("Kategori"),
                        TableHeaderCell("Nilai Minimum"),
                        TableHeaderCell("Nilai Maksimum"),
                        TableHeaderCell("Deskripsi"),
                        TableHeaderCell("Aksi"),
                      ],
                    ),
                    for (final rangeNilai in rangeList)
                      TableRow(
                        children: [
                          TableCellWidget(rangeNilai.kategoriNilai),
                          TableCellWidget(rangeNilai.nilaiMinimum.toString()),
                          TableCellWidget(rangeNilai.nilaiMaksimum.toString()),
                          TableCellWidget(rangeNilai.deskripsi),
                          IconButton(
                            onPressed: () {
                              // abaikan dulu
                              showDialog(
                                context: context,
                                builder: (context) => DialogKonfirmasiWidget(
                                  confirmText:
                                      "Apakah anda yakin ingin menghapus kategori '${rangeNilai.kategoriNilai}'?",
                                  confirmAction: () async {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );

                                    try {
                                      final success = await ref
                                          .read(
                                            rangeNilaiKategoriNotifierProvider
                                                .notifier,
                                          )
                                          .deleteRangeNilaiKategori(
                                            kategoriNilaiId: rangeNilai.id,
                                          );
                                      Navigator.pop(context);

                                      if (success) {
                                        // Close dialog
                                        Navigator.pop(context);

                                        // Show success message
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Kategori nilai berhasil dihapus',
                                            ),
                                            backgroundColor: Colors.green,
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
                                            'Gagal menghapus kategori nilai: ${e.toString()}',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                            icon: const Icon(Symbols.delete, color: Colors.red),
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
    ],
  );
}

// // ignore_for_file: avoid_print

// import 'package:elearning_guru/general_widgets/button_add_widget.dart';
// import 'package:elearning_guru/general_widgets/dialog_success_widget.dart';
// import 'package:elearning_guru/models/filtering_model.dart';
// import 'package:elearning_guru/models/materi_kelas_model.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:material_symbols_icons/material_symbols_icons.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../general_widgets/dialog_error_widget.dart';
// import '../../../general_widgets/dialog_konfirmasi_widget.dart';
// import '../../../general_widgets/filter_dropdown.dart';
// import '../../../general_widgets/header2_widget.dart';
// import '../../../general_widgets/search_textfield_widget.dart';
// import '../../../general_widgets/table_cell.dart';
// import '../../../general_widgets/table_header_cell.dart';

// class KontenMateriWidget extends ConsumerStatefulWidget {
//   final String namaKelas;
//   final int kelasMapelId;

//   const KontenMateriWidget({
//     super.key,
//     required this.namaKelas,
//     required this.kelasMapelId,
//   });

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _KontenMateriWidgetState();
// }

// class _KontenMateriWidgetState extends ConsumerState<KontenMateriWidget> {
//   String? selectedSemester;
//   int? selectedSemesterId;

//   List<Semester> semesterList = [];

//   // void _navigateToTambahMateri(int kelasMapelId) {
//   //   context.go('/dashboard/guru/kelas/$kelasMapelId/tambah-materi');
//   // }

//   void _navigateToTambahMateri(int kelasMapelId) {
//     context.go(
//       '/dashboard/guru/kelas/$kelasMapelId/tambah-materi',
//       // extra: true, // Mark as coming from detail screen
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initSemesterList();

//     // Load pertama kali
//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     //   ref
//     //       .read(materiKelasRiverpodProvider.notifier)
//     //       .resetAndFetch(
//     //         kelasMapelId: widget.kelasMapelId,
//     //         search: '',
//     //         page: 1,
//     //       );
//     // });
//   }

//   Future<void> _initSemesterList() async {
//     final materiNotifier = ref.read(materiKelasRiverpodProvider.notifier);
//     try {
//       final result = await materiNotifier.fetchSemester();
//       setState(() {
//         semesterList = result;
//       });
//     } catch (e) {
//       print('Gagal mengambil semester: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final materiState = ref.watch(materiKelasRiverpodProvider);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           padding: EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             border: Border.all(
//               color: Colors.grey[200]!, // warna border
//               width: 1, // ketebalan border
//             ),
//             borderRadius: BorderRadius.circular(
//               8,
//             ), // opsional kalau mau rounded
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Header2Widget(
//                         header2Title: "Daftar Materi",
//                         subtitle: "Materi pembelajaran untuk $widget.namaKelas",
//                       ),
//                       ButtonAddWidget(
//                         addAction:
//                             () => _navigateToTambahMateri(widget.kelasMapelId),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       SearchTextFieldWidget(
//                         hintText: "Cari berdasarkan judul materi",
//                         onChangedSearch: (value) {
//                           ref
//                               .read(materiKelasRiverpodProvider.notifier)
//                               .resetAndFetch(search: value);
//                         },
//                       ),
//                       // bagian filter
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             "Filter :",
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           FilterDropdownWidget(
//                             pHintText: "Semua Semester",
//                             widhtDropdown: 210,
//                             valueParams: selectedSemester,
//                             pItems: [
//                               'Semua Semester', // tambahkan ini dulu
//                               ...semesterList.map((e) => e.judulSemester),
//                             ],
//                             pOnChanged: (value) {
//                               if (value == 'Semua Semester') {
//                                 ref
//                                     .read(materiKelasRiverpodProvider.notifier)
//                                     .resetAndFetch();
//                               } else {
//                                 setState(() {
//                                   final semester = semesterList.firstWhere(
//                                     (s) => s.judulSemester == value,
//                                   );

//                                   selectedSemesterId = semester.semesterId;

//                                   ref
//                                       .read(
//                                         materiKelasRiverpodProvider.notifier,
//                                       )
//                                       .resetAndFetch(
//                                         semesterId: selectedSemesterId,
//                                       );
//                                 });
//                               }
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               SizedBox(height: 15),
//               materiState.when(
//                 loading: () => const Center(child: CircularProgressIndicator()),
//                 error: (err, _) {
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     final errorMsg =
//                         err.toString().contains("PostgrestException")
//                             ? err
//                                 .toString()
//                                 .split("message:")
//                                 .last
//                                 .split(",")
//                                 .first
//                                 .trim()
//                             : err.toString();

//                     showDialog(
//                       context: context,
//                       builder:
//                           (context) =>
//                               DialogErrorWidget(errorText: 'Error : $errorMsg'),
//                     );
//                   });

//                   // tampilkan tabel dari cache data terakhir, bukan kosong
//                   final cachedData =
//                       ref
//                           .read(materiKelasRiverpodProvider.notifier)
//                           .lastMateriKelas;

//                   return buildMateriTable(
//                     context,
//                     cachedData,
//                     ref,
//                     widget.kelasMapelId,
//                   );
//                 },
//                 data:
//                     (materiList) => buildMateriTable(
//                       context,
//                       materiList,
//                       ref,
//                       widget.kelasMapelId,
//                     ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// /// =====================
// /// Pagination Helpers
// /// =====================
// List<Widget> _buildPaginationButtons(
//   int totalPage,
//   int currentPage,
//   void Function(int) onPageSelected,
// ) {
//   List<Widget> buttons = [];

//   if (totalPage <= 5) {
//     // Kalau halaman sedikit, tampil semua
//     for (int i = 1; i <= totalPage; i++) {
//       buttons.add(_pageButton(i, currentPage, onPageSelected));
//     }
//   } else {
//     // Selalu tampilkan halaman 1
//     buttons.add(_pageButton(1, currentPage, onPageSelected));

//     // Ellipsis awal
//     if (currentPage > 4) {
//       buttons.add(
//         const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 4.0),
//           child: Text("..."),
//         ),
//       );
//     }

//     // Halaman sekitar currentPage
//     int start = (currentPage - 1).clamp(2, totalPage - 3);
//     int end = (currentPage + 1).clamp(4, totalPage - 1);

//     for (int i = start; i <= end; i++) {
//       buttons.add(_pageButton(i, currentPage, onPageSelected));
//     }

//     // Ellipsis akhir
//     if (currentPage < totalPage - 3) {
//       buttons.add(
//         const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 4.0),
//           child: Text("..."),
//         ),
//       );
//     }

//     // Halaman terakhir
//     buttons.add(_pageButton(totalPage, currentPage, onPageSelected));
//   }

//   return buttons;
// }

// Widget _pageButton(int i, int currentPage, void Function(int) onPageSelected) {
//   final bool isActive = i == currentPage;
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 2.0),
//     child: TextButton(
//       style: TextButton.styleFrom(
//         backgroundColor: isActive ? Colors.blue : null,
//         foregroundColor: isActive ? Colors.white : Colors.black,
//         minimumSize: const Size(36, 36),
//         padding: EdgeInsets.zero,
//       ),
//       onPressed: () => onPageSelected(i),
//       child: Text("$i"),
//     ),
//   );
// }

// Widget buildMateriTable(
//   BuildContext context,
//   List<MateriKelas> materiList,
//   WidgetRef ref,
//   int kelasMapelId,
// ) {
//   if (materiList.isEmpty) {
//     return const Center(child: Text("Data materi tidak tersedia."));
//   }

//   final notifier = ref.read(materiKelasRiverpodProvider.notifier);

//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(5),
//           border: Border.all(color: Colors.black26, width: 1.2), // border luar
//         ),
//         clipBehavior: Clip.hardEdge, // penting biar isi ikut radius
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(minWidth: constraints.maxWidth),
//                 child: Table(
//                   border: const TableBorder(
//                     horizontalInside: BorderSide(
//                       width: 1,
//                       color: Colors.black26,
//                     ), // garis antar baris
//                     // tidak pakai left/right/top/bottom supaya tidak double border
//                   ),
//                   columnWidths: const <int, TableColumnWidth>{
//                     0: IntrinsicColumnWidth(),
//                     1: IntrinsicColumnWidth(),
//                     2: IntrinsicColumnWidth(),
//                     3: IntrinsicColumnWidth(),
//                     4: FixedColumnWidth(200),
//                     5: FixedColumnWidth(20),
//                   },
//                   defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//                   children: [
//                     TableRow(
//                       // decoration: BoxDecoration(
//                       //   color: Colors.grey.shade200,
//                       // ),
//                       children: const [
//                         TableHeaderCell("Judul Materi"),
//                         TableHeaderCell("Lingkup Materi"),
//                         TableHeaderCell("Tanggal Dibuat"),
//                         TableHeaderCell("Status"),
//                         TableHeaderCell("Aksi"),
//                       ],
//                     ),
//                     for (final materi in materiList)
//                       TableRow(
//                         children: [
//                           TableCellWidget(materi.judulMateri),
//                           TableCellWidget(materi.lingkupMateri),
//                           TableCellWidget(materi.tanggalDibuat),
//                           TableCellWidget(materi.statusMateri),
//                           Padding(
//                             padding: const EdgeInsets.all(6.0),
//                             child: Theme(
//                               data: Theme.of(context).copyWith(
//                                 materialTapTargetSize:
//                                     MaterialTapTargetSize
//                                         .shrinkWrap, // biar lebih kecil
//                               ),
//                               child: PopupMenuButton<String>(
//                                 position: PopupMenuPosition.under,
//                                 color: Colors.white,
//                                 icon: const Icon(
//                                   Symbols.more_horiz,
//                                 ), // tombol "..."
//                                 onSelected: (value) async {
//                                   if (value == 'pratinjau') {
//                                     // Aksi pratinjau
//                                     print("Pratinjau");
//                                     final prefs =
//                                         await SharedPreferences.getInstance();
//                                     await prefs.setInt(
//                                       'materiId',
//                                       materi.materiId,
//                                     );

//                                     context.go(
//                                       '/dashboard/guru/kelas/$kelasMapelId/detail-materi',
//                                       // extra: true, // Mark as coming from detail screen
//                                     );
//                                   } else if (value == 'edit') {
//                                     // Aksi edit
//                                     print("Edit data");
//                                     final prefs =
//                                         await SharedPreferences.getInstance();
//                                     await prefs.setInt(
//                                       'materiId',
//                                       materi.materiId,
//                                     );

//                                     context.go(
//                                       '/dashboard/guru/kelas/$kelasMapelId/edit-materi',
//                                       // extra: true, // Mark as coming from detail screen
//                                     );
//                                   } else if (value == 'hapus') {
//                                     // Aksi hapus
//                                     showDialog(
//                                       context: context,
//                                       builder:
//                                           (context) => DialogKonfirmasiWidget(
//                                             confirmText:
//                                                 "Apakah anda yakin ingin menghapus materi '${materi.judulMateri}' ?",
//                                             confirmAction: () async {
//                                               // Tampilkan dialog loading
//                                               showDialog(
//                                                 context: context,
//                                                 barrierDismissible: false,
//                                                 builder:
//                                                     (context) => const Center(
//                                                       child:
//                                                           CircularProgressIndicator(),
//                                                     ),
//                                               );

//                                               try {
//                                                 // Ambil semua URL dari fileMateri
//                                                 List<String> filesToDelete =
//                                                     materi.fileMateri
//                                                         .map(
//                                                           (file) =>
//                                                               file['link_file_materi'] ??
//                                                               '',
//                                                         )
//                                                         .where(
//                                                           (url) =>
//                                                               url.isNotEmpty,
//                                                         )
//                                                         .toList();

//                                                 // tambahkan function for panjang materilist maka akan menambahkan materiList['link_file_materi]
//                                                 final success = await ref
//                                                     .read(
//                                                       materiKelasRiverpodProvider
//                                                           .notifier,
//                                                     )
//                                                     .deleteMateri(
//                                                       materiId: materi.materiId,
//                                                       filesToDelete:
//                                                           filesToDelete,
//                                                     );
//                                                 Navigator.pop(context);

//                                                 if (success) {
//                                                   // Close dialog
//                                                   Navigator.pop(context);

//                                                   // Show success message
//                                                   showDialog(
//                                                     context: context,
//                                                     builder:
//                                                         (
//                                                           context,
//                                                         ) => DialogSuccessWidget(
//                                                           succesText:
//                                                               "Materi berhasil dihapus",
//                                                         ),
//                                                   );
//                                                 }
//                                               } catch (e) {
//                                                 // Remove loading indicator
//                                                 Navigator.pop(context);

//                                                 // Show error message
//                                                 ScaffoldMessenger.of(
//                                                   context,
//                                                 ).showSnackBar(
//                                                   SnackBar(
//                                                     content: Text(
//                                                       'Gagal menghapus materi: ${e.toString()}',
//                                                     ),
//                                                     backgroundColor: Colors.red,
//                                                   ),
//                                                 );
//                                               }
//                                             },
//                                           ),
//                                     );
//                                   } else if (value == 'Sembunyikan') {
//                                     // Aksi hide
//                                     showDialog(
//                                       context: context,
//                                       builder:
//                                           (context) => DialogKonfirmasiWidget(
//                                             confirmText:
//                                                 "Apakah anda yakin ingin menyembunyikan materi '${materi.judulMateri}' ?",
//                                             confirmAction: () async {
//                                               // Tampilkan dialog loading
//                                               showDialog(
//                                                 context: context,
//                                                 barrierDismissible: false,
//                                                 builder:
//                                                     (context) => const Center(
//                                                       child:
//                                                           CircularProgressIndicator(),
//                                                     ),
//                                               );

//                                               try {
//                                                 final success = await ref
//                                                     .read(
//                                                       materiKelasRiverpodProvider
//                                                           .notifier,
//                                                     )
//                                                     .updateStatusMateri(
//                                                       materiId: materi.materiId,
//                                                       statusMateri: "Hide",
//                                                     );
//                                                 Navigator.pop(context);

//                                                 if (success) {
//                                                   // Close dialog
//                                                   Navigator.pop(context);

//                                                   // Show success message
//                                                   showDialog(
//                                                     context: context,
//                                                     builder:
//                                                         (
//                                                           context,
//                                                         ) => DialogSuccessWidget(
//                                                           succesText:
//                                                               "Status materi berhasil diperbarui",
//                                                         ),
//                                                   );
//                                                 }
//                                               } catch (e) {
//                                                 // Remove loading indicator
//                                                 Navigator.pop(context);

//                                                 // Show error message
//                                                 ScaffoldMessenger.of(
//                                                   context,
//                                                 ).showSnackBar(
//                                                   SnackBar(
//                                                     content: Text(
//                                                       'Gagal memperbarui sttaus materi: ${e.toString()}',
//                                                     ),
//                                                     backgroundColor: Colors.red,
//                                                   ),
//                                                 );
//                                               }
//                                             },
//                                           ),
//                                     );
//                                   } else if (value == 'Tampilkan') {
//                                     // Aksi hide
//                                     showDialog(
//                                       context: context,
//                                       builder:
//                                           (context) => DialogKonfirmasiWidget(
//                                             confirmText:
//                                                 "Apakah anda yakin ingin menampilkan materi '${materi.judulMateri}' ?",
//                                             confirmAction: () async {
//                                               // Tampilkan dialog loading
//                                               showDialog(
//                                                 context: context,
//                                                 barrierDismissible: false,
//                                                 builder:
//                                                     (context) => const Center(
//                                                       child:
//                                                           CircularProgressIndicator(),
//                                                     ),
//                                               );

//                                               try {
//                                                 final success = await ref
//                                                     .read(
//                                                       materiKelasRiverpodProvider
//                                                           .notifier,
//                                                     )
//                                                     .updateStatusMateri(
//                                                       materiId: materi.materiId,
//                                                       statusMateri: "Visible",
//                                                     );
//                                                 Navigator.pop(context);

//                                                 if (success) {
//                                                   // Close dialog
//                                                   Navigator.pop(context);

//                                                   // Show success message
//                                                   showDialog(
//                                                     context: context,
//                                                     builder:
//                                                         (
//                                                           context,
//                                                         ) => DialogSuccessWidget(
//                                                           succesText:
//                                                               "Status materi berhasil diperbarui",
//                                                         ),
//                                                   );
//                                                 }
//                                               } catch (e) {
//                                                 // Remove loading indicator
//                                                 Navigator.pop(context);

//                                                 // Show error message
//                                                 ScaffoldMessenger.of(
//                                                   context,
//                                                 ).showSnackBar(
//                                                   SnackBar(
//                                                     content: Text(
//                                                       'Gagal memperbarui sttaus materi: ${e.toString()}',
//                                                     ),
//                                                     backgroundColor: Colors.red,
//                                                   ),
//                                                 );
//                                               }
//                                             },
//                                           ),
//                                     );
//                                   }
//                                 },
//                                 itemBuilder:
//                                     (BuildContext context) => [
//                                       const PopupMenuItem(
//                                         value: 'pratinjau',
//                                         child: SizedBox(
//                                           height: 15,
//                                           child: Row(
//                                             children: [
//                                               Icon(
//                                                 Symbols.info,
//                                                 color: Colors.blue,
//                                                 size: 18,
//                                               ),
//                                               SizedBox(width: 8),
//                                               Text(
//                                                 'Pratinjau',
//                                                 style: TextStyle(fontSize: 12),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                       const PopupMenuItem(
//                                         value: 'edit',
//                                         child: SizedBox(
//                                           height: 15,
//                                           child: Row(
//                                             children: [
//                                               Icon(
//                                                 Icons.edit,
//                                                 color: Colors.orange,
//                                                 size: 18,
//                                               ),
//                                               SizedBox(width: 8),
//                                               Text(
//                                                 'Edit',
//                                                 style: TextStyle(fontSize: 12),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                       const PopupMenuItem(
//                                         value: 'hapus',
//                                         child: SizedBox(
//                                           height: 15,
//                                           child: Row(
//                                             children: [
//                                               Icon(
//                                                 Icons.delete,
//                                                 color: Colors.red,
//                                                 size: 18,
//                                               ),
//                                               SizedBox(width: 8),
//                                               Text(
//                                                 'Hapus',
//                                                 style: TextStyle(fontSize: 12),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                       PopupMenuItem(
//                                         value:
//                                             materi.statusMateri == "Visible"
//                                                 ? 'Sembunyikan'
//                                                 : 'Tampilkan',
//                                         child: SizedBox(
//                                           height: 15,
//                                           child: Row(
//                                             children: [
//                                               // Icon berubah sesuai status
//                                               Icon(
//                                                 materi.statusMateri == "Visible"
//                                                     ? Icons.visibility_off
//                                                     : Icons.visibility,
//                                                 color: Colors.red,
//                                                 size: 18,
//                                               ),
//                                               SizedBox(width: 8),
//                                               Text(
//                                                 materi.statusMateri == "Visible"
//                                                     ? 'Sembunyikan'
//                                                     : 'Tampilkan',
//                                                 style: TextStyle(fontSize: 12),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//       const SizedBox(height: 16),

//       /// Pagination
//       LayoutBuilder(
//         builder: (context, constraints) {
//           // Gunakan breakpoint 600px untuk menentukan layout
//           if (constraints.maxWidth < 600) {
//             // Layout untuk layar kecil (mobile)
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Teks informasi di atas
//                 Text(
//                   "Menampilkan ${materiList.length} dari ${notifier.total} data",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 14),
//                 ),
//                 const SizedBox(height: 12),

//                 // Kontrol pagination di bawah
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       TextButton(
//                         onPressed:
//                             notifier.currentPage > 1
//                                 ? () => notifier.fetchPreviousPage()
//                                 : null,
//                         child: const Text("Sebelumnya"),
//                       ),
//                       const SizedBox(width: 8),

//                       /// Pagination dengan ellipsis
//                       ..._buildPaginationButtons(
//                         notifier.totalPage,
//                         notifier.currentPage,
//                         (page) => notifier.resetAndFetch(page: page),
//                       ),

//                       const SizedBox(width: 8),
//                       TextButton(
//                         onPressed:
//                             notifier.hasMore
//                                 ? () => notifier.fetchNextPage()
//                                 : null,
//                         child: const Text("Selanjutnya"),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           } else {
//             // Layout untuk layar besar (desktop)
//             return Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Menampilkan ${materiList.length} dari ${notifier.total} data",
//                 ),
//                 Row(
//                   children: [
//                     TextButton(
//                       onPressed:
//                           notifier.currentPage > 1
//                               ? () => notifier.fetchPreviousPage()
//                               : null,
//                       child: const Text("Sebelumnya"),
//                     ),
//                     const SizedBox(width: 8),

//                     /// Pagination dengan ellipsis
//                     ..._buildPaginationButtons(
//                       notifier.totalPage,
//                       notifier.currentPage,
//                       (page) => notifier.resetAndFetch(page: page),
//                     ),

//                     const SizedBox(width: 8),
//                     TextButton(
//                       onPressed:
//                           notifier.hasMore
//                               ? () => notifier.fetchNextPage()
//                               : null,
//                       child: const Text("Selanjutnya"),
//                     ),
//                   ],
//                 ),
//               ],
//             );
//           }
//         },
//       ),
//     ],
//   );
// }


// //tes
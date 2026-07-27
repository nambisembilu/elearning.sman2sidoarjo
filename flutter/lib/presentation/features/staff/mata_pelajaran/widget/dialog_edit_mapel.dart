// import 'package:e_learning/%5Brole%5D-admin/controllers/data_guru_riverpod.dart';
// import 'package:e_learning/%5Brole%5D-admin/controllers/kelas_riverpod.dart';
// import 'package:e_learning/%5Brole%5D-admin/general_widgets/dialog_error_widget.dart';
// import 'package:e_learning/%5Brole%5D-admin/general_widgets/dropdown_widget.dart';
// import 'package:e_learning/%5Brole%5D-admin/models/filtering_model.dart';
// import 'package:e_learning/%5Brole%5D-admin/models/mata_pelajaran_model.dart';
// import 'package:flutter/material.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:material_symbols_icons/symbols.dart';

// import '../../../general_widgets/dialog_success_widget.dart';

// class DialogEditMapel extends ConsumerStatefulWidget {
//   final MataPelajaran? dataMapel;

//   const DialogEditMapel({super.key, required this.dataMapel});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _DialogEditMapelState();
// }

// class _DialogEditMapelState extends ConsumerState<DialogEditMapel> {
//   final _formKey = GlobalKey<FormState>();

//   String? selectedGuru;
//   int? selectedGuruUserId;

//   List<FilterGuru> listGuruNonKoor = [];

//   bool isSubmitted = false;

//   @override
//   void initState() {
//     super.initState();

//     if (widget.dataMapel != null) {
//       selectedGuru = widget.dataMapel!.koorMapel;
//       final ruang = widget.dataMapel!.ruangKelas; // "R.XII BAHASA - Gedung D"
//       if (ruang.contains("Gedung")) {
//         selectedGedung = ruang.split("Gedung ").last.trim(); // hasil: "D"
//       }
//       final getWalas = widget.dataMapel!.waliKelas[0];
//       selectedGuru = getWalas['nama_walas'];
//       selectedUserIdGuru = int.parse(getWalas['walas_id'].toString());
//     }

//     // panggil fetch data guru pertama kali
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(dataGuruNotifierProvider.notifier).resetAndFetch();
//     });
//   }

//     Future<void> _loadGuruNonKoor() async {
//     try {
//       final listGuru =
//           await ref
//               .read(mataPelajaranNotifierProvider.notifier)
//               .fetchGuruNonKoorMapel();

//       if (!mounted) return;

//       setState(() {
//         listGuruNonKoor = listGuru;
//       });
//     } catch (e) {
//       print("Error loading guru non koor mapel : $e");
//       if (mounted) {
//         setState(() {
//           listGuruNonKoor = [];
//           selectedGuru = listGuruNonKoor.first.namaGuru;
//           selectedGuruUserId = listGuruNonKoor.first.userId;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dataGuruAsync = ref.watch(dataGuruNotifierProvider);

//     return AlertDialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Edit Kelas",
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                 ),
//               ),
//               Text(
//                 "Perbarui informasi kelas",
//                 style: TextStyle(color: Colors.grey[600], fontSize: 14),
//               ),
//             ],
//           ),
//           IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: Icon(Symbols.close, color: Colors.black, weight: 600),
//           ),
//         ],
//       ),
//       content: ConstrainedBox(
//         constraints: BoxConstraints(
//           maxHeight: MediaQuery.of(context).size.height * 0.6,
//         ),
//         child: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   width: MediaQuery.of(context).size.width * 0.3,
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.grey.shade300),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: const Color.fromARGB(255, 233, 242, 248),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Informasi Kelas",
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "Nama Kelas :",
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     SizedBox(height: 5),
//                                     Text(
//                                       widget.dataMapel!.namaKelas,
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey[500],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "Jenjang :",
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     SizedBox(height: 5),
//                                     Text(
//                                       "Kelas ${widget.dataMapel!.jenjang}",
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey[500],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "Jurusan :",
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     SizedBox(height: 5),
//                                     Text(
//                                       widget.dataMapel!.jurusan,
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey[500],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),

//                       SizedBox(height: 15),
//                       Row(
//                         children: [
//                           DropdownGeneralWidget(
//                             pTitle: "Gedung",
//                             pHintText: "Pilih Gedung",
//                             valueParams: selectedGedung,
//                             pItems: ["A", "B", "C", "D"],
//                             pOnChanged: (value) {
//                               selectedGedung = value;
//                             },
//                             isRequired: true,
//                             isSubmitted: isSubmitted,
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 16),
//                       Row(
//                         children: [
//                           DropdownGeneralWidget(
//                             pTitle: "Wali Kelas",
//                             pHintText: "Pilih Wali Kelas",
//                             valueParams: selectedGuru,
//                             pItems: dataGuruAsync.when(
//                               data: (walasList) {
//                                 daftarNamaGuru =
//                                     walasList.map((e) => e.nama).toList();
//                                 daftarUserIdGuru =
//                                     walasList.map((e) => e.userId).toList();

//                                 return daftarNamaGuru;
//                               },
//                               loading: () => [],
//                               error: (err, st) => [],
//                             ),
//                             pOnChanged: (value) {
//                               selectedGuru = value;

//                               final index = daftarNamaGuru.indexOf(value ?? "");

//                               if (index != -1) {
//                                 selectedUserIdGuru = daftarUserIdGuru[index];
//                               }
//                             },
//                             isRequired: true,
//                             isSubmitted: isSubmitted,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       actions: [
//         ElevatedButton(
//           onPressed: () async {
//             setState(() {
//               isSubmitted = true;
//             });

//             final isValid = _formKey.currentState!.validate();

//             if (selectedGedung == null ||
//                 selectedGuru == null ||
//                 selectedUserIdGuru == null) {
//               showDialog(
//                 context: context,
//                 builder:
//                     (context) => DialogErrorWidget(
//                       errorText: "Semua Informasi Kelas Wajib Diisi",
//                     ),
//               );
//               return;
//             }

//             if (isValid) {
//               showDialog(
//                 context: context,
//                 barrierDismissible: false,
//                 builder:
//                     (context) =>
//                         const Center(child: CircularProgressIndicator()),
//               );

//               try {
//                 final success = await ref
//                     .read(kelasNotifierProvider.notifier)
//                     .updateKelas(
//                       kelas_id: widget.dataMapel!.kelasId,
//                       gedung: selectedGedung!,
//                       user_id: selectedUserIdGuru!,
//                     );

//                 // Remove loading indicator
//                 Navigator.pop(context);

//                 if (success) {
//                   // Close dialog
//                   Navigator.pop(context);

//                   showDialog(
//                     context: context,
//                     builder:
//                         (context) => DialogSuccessWidget(
//                           succesText: 'Kelas berhasil diperbarui',
//                         ),
//                   );
//                 }
//               } catch (e) {
//                 // Close dialog
//                 Navigator.pop(context);
//               }
//             }
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xff016EB3),
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(5),
//             ),
//             minimumSize: const Size(70, 40),
//           ),
//           child: const Text("Simpan"),
//         ),
//       ],
//     );
//   }
// }

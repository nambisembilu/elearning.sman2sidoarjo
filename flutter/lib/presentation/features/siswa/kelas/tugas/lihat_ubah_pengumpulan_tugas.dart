// // lihat_ubah_pengumpulan_tugas.dart
// import 'dart:io';
// import 'package:elearning_siswa/conntroller/tugas/tugas_riverpod.dart';
// import 'package:elearning_siswa/general_widgets/dialog_error_widget.dart';
// import 'package:elearning_siswa/general_widgets/dialog_success_widget.dart';
// import 'package:elearning_siswa/general_widgets/file_textfield_widget.dart';
// import 'package:elearning_siswa/general_widgets/header2_widget.dart';
// import 'package:elearning_siswa/models/pengumpulan_tugas_model.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:material_symbols_icons/symbols.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:universal_html/html.dart' as html;

// class LihatUbahPengumpulanTugasScreen extends ConsumerStatefulWidget {
//   const LihatUbahPengumpulanTugasScreen({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _LihatUbahPengumpulanTugasScreenState();
// }

// class _LihatUbahPengumpulanTugasScreenState
//     extends ConsumerState<LihatUbahPengumpulanTugasScreen> {
//   final _formKey = GlobalKey<FormState>();

//   List<PlatformFile> pickedFiles = [];
//   List<PengumpulanTugasDetailModel> detailPengumpulan = [];
//   bool isLoading = true;
//   bool isSubmitted = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadDetailPengumpulan();
//   }

//   Future<void> _loadDetailPengumpulan() async {
//     try {
//       final list =
//           await ref
//               .read(tugasKelasRiverpodProvider.notifier)
//               .getDetailPengumpulanTugasSiswa();

//       if (!mounted) return;

//       setState(() {
//         detailPengumpulan = list;
//         isLoading = false;
//       });
//     } catch (e) {
//       print("Error loading detail pengumpulan: $e");
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _pilihFile() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: [
//         'pdf',
//         'doc',
//         'docx',
//         'xls',
//         'xlsx',
//         'pptx',
//         'mp4',
//         'mp3',
//         'txt',
//         'jpg',
//         'png',
//         'jpeg',
//         'csv',
//       ],
//       allowMultiple: true,
//       withData: true,
//     );

//     if (result != null && result.files.isNotEmpty) {
//       const maxFileSize = 5 * 1024 * 1024;

//       final validFiles =
//           result.files.where((file) {
//             if (file.size > maxFileSize) {
//               print(
//                 '❌ File "${file.name}" terlalu besar (${(file.size / 1024 / 1024).toStringAsFixed(2)} MB)',
//               );

//               showDialog(
//                 context: context,
//                 builder:
//                     (context) => DialogErrorWidget(
//                       errorText:
//                           'Ukuran file "${file.name}" melebihi 5 MB dan tidak ditambahkan.',
//                     ),
//               );
//               return false;
//             }
//             return true;
//           }).toList();

//       if (validFiles.isNotEmpty) {
//         setState(() {
//           pickedFiles.addAll(validFiles);
//         });
//       }
//     }
//   }

//   void _tutupLoadingIndicator() {
//     if (Navigator.of(context, rootNavigator: true).canPop()) {
//       Navigator.of(context, rootNavigator: true).pop();
//     }
//   }

//   Future<void> openFileWeb(Uint8List bytes, String fileName) async {
//     final ext = fileName.toLowerCase().split('.').last;
//     String mimeType = 'application/octet-stream';

//     switch (ext) {
//       case 'jpg':
//       case 'jpeg':
//       case 'png':
//         mimeType = 'image/$ext';
//         break;
//       case 'pdf':
//         mimeType = 'application/pdf';
//         break;
//       case 'txt':
//       case 'csv':
//         mimeType = 'text/plain';
//         break;
//       case 'mp4':
//         mimeType = 'video/mp4';
//         break;
//       case 'mp3':
//         mimeType = 'audio/mpeg';
//         break;
//       case 'doc':
//       case 'docx':
//         mimeType =
//             'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
//         break;
//       case 'xls':
//       case 'xlsx':
//         mimeType =
//             'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
//         break;
//       case 'pptx':
//         mimeType =
//             'application/vnd.openxmlformats-officedocument.presentationml.presentation';
//         break;
//     }

//     final blob = html.Blob([bytes], mimeType);
//     final url = html.Url.createObjectUrlFromBlob(blob);
//     html.window.open(url, "_blank");

//     Future.delayed(const Duration(seconds: 2), () {
//       html.Url.revokeObjectUrl(url);
//     });
//   }

//   Future<void> openFileNonWeb(String filePath) async {
//     final result = await OpenFilex.open(filePath);
//     if (result.type != ResultType.done) {
//       print('❌ Gagal membuka file: ${result.message}');
//     }
//   }

//   String _getFileNameFromUrl(String url) {
//     try {
//       final uri = Uri.parse(url);
//       final pathSegments = uri.pathSegments;
//       if (pathSegments.isNotEmpty) {
//         String fileName = pathSegments.last;
//         final parts = fileName.split('_');
//         if (parts.length > 1) {
//           return parts.sublist(1).join('_');
//         }
//         return fileName;
//       }
//       return 'File';
//     } catch (e) {
//       return 'File';
//     }
//   }

//   IconData _getFileIcon(String fileName) {
//     final extension = fileName.toLowerCase().split('.').last;
//     switch (extension) {
//       case 'pdf':
//         return Symbols.picture_as_pdf;
//       case 'doc':
//       case 'docx':
//         return Symbols.description;
//       case 'xls':
//       case 'xlsx':
//         return Symbols.table_chart;
//       case 'ppt':
//       case 'pptx':
//         return Symbols.slideshow;
//       case 'jpg':
//       case 'jpeg':
//       case 'png':
//       case 'gif':
//         return Symbols.image;
//       case 'mp3':
//       case 'wav':
//         return Symbols.audiotrack;
//       case 'mp4':
//       case 'avi':
//       case 'mov':
//         return Symbols.video_file;
//       case 'zip':
//       case 'rar':
//         return Symbols.folder_zip;
//       default:
//         return Symbols.insert_drive_file;
//     }
//   }

//   Future<void> _updatePengumpulanTugas() async {
//     setState(() {
//       isSubmitted = true;
//     });

//     if (pickedFiles.isEmpty && detailPengumpulan.first.files!.isEmpty) {
//       showDialog(
//         context: context,
//         builder:
//             (context) => const DialogErrorWidget(
//               errorText: "Belum ada file yang ditambahkan",
//             ),
//       );
//       return;
//     }

//     // Show loading indicator
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => const Center(child: CircularProgressIndicator()),
//     );

//     try {
//       // Konversi file baru ke Uint8List
//       final fileBytes =
//           pickedFiles.map((f) {
//             if (f.bytes != null) {
//               return f.bytes!;
//             } else if (f.path != null) {
//               return File(f.path!).readAsBytesSync();
//             } else {
//               throw Exception("File tidak valid");
//             }
//           }).toList();

//       final fileNames = pickedFiles.map((f) => f.name).toList();

//       final success = await ref
//           .read(tugasKelasRiverpodProvider.notifier)
//           .submitTugas(fileBytes: fileBytes, fileNames: fileNames);

//       // Tutup loading indicator setelah selesai
//       _tutupLoadingIndicator();

//       if (success) {
//         if (!mounted) return;

//         // Tampilkan dialog sukses
//         await showDialog(
//           context: context,
//           builder:
//               (context) => DialogSuccessWidget(
//                 succesText: 'Pengumpulan tugas berhasil diupdate',
//               ),
//         );

//         if (!mounted) return;
//         context.pop(); // Kembali ke halaman detail tugas
//       }
//     } catch (e) {
//       // Tutup loading indicator jika error
//       _tutupLoadingIndicator();

//       // Tampilkan dialog error
//       if (mounted) {
//         showDialog(
//           context: context,
//           builder:
//               (context) =>
//                   DialogErrorWidget(errorText: "Terjadi kesalahan: $e"),
//         );
//       }
//     }
//   }

//   Widget _buildFileList() {
//     if (detailPengumpulan.isEmpty || detailPengumpulan.first.files == null) {
//       return const SizedBox();
//     }

//     final files = detailPengumpulan.first.files!;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "File yang sudah dikumpulkan:",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 10),
//         ...files.asMap().entries.map((entry) {
//           final index = entry.key;
//           final fileUrl = entry.value;
//           final fileName = _getFileNameFromUrl(fileUrl);
//           final fileIcon = _getFileIcon(fileName);

//           return Column(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(5),
//                   border: Border.all(color: Colors.grey.shade400),
//                 ),
//                 child: ListTile(
//                   leading: Icon(fileIcon, size: 20),
//                   title: Text(fileName, style: const TextStyle(fontSize: 12)),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.remove_red_eye, size: 20),
//                         onPressed: () async {
//                           // TODO: Implement preview file yang sudah dikumpulkan
//                           // Untuk sekarang kita hanya bisa preview file baru
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text(
//                                 "Fitur preview file sedang dikembangkan",
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//             ],
//           );
//         }).toList(),
//       ],
//     );
//   }

//   Widget _buildNewFileList() {
//     if (pickedFiles.isEmpty) {
//       return const SizedBox();
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "File baru yang akan diupload:",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 10),
//         ...pickedFiles
//             .map(
//               (file) => Column(
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(5),
//                       border: Border.all(color: Colors.grey.shade400),
//                     ),
//                     child: ListTile(
//                       leading: const Icon(Icons.file_present, size: 20),
//                       title: Text(
//                         file.name,
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                       trailing: IconButton(
//                         icon: const Icon(
//                           Icons.delete,
//                           color: Colors.red,
//                           size: 20,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             pickedFiles.remove(file);
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                 ],
//               ),
//             )
//             .toList(),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           if (isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           return SingleChildScrollView(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(minHeight: constraints.maxHeight),
//               child: IntrinsicHeight(
//                 child: Padding(
//                   padding: const EdgeInsets.all(30),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Header2Widget(
//                           header2Title: "Lihat & Ubah Pengumpulan Tugas",
//                           subtitle:
//                               "Lihat file yang sudah dikumpulkan dan tambah file baru jika perlu.",
//                         ),
//                         const SizedBox(height: 20),
//                         Container(
//                           padding: const EdgeInsets.all(20),
//                           decoration: BoxDecoration(
//                             border: Border.all(
//                               color: Colors.grey[200]!,
//                               width: 1,
//                             ),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Informasi Pengumpulan
//                               if (detailPengumpulan.isNotEmpty)
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Text(
//                                       "Informasi Pengumpulan:",
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 10),
//                                     Row(
//                                       children: [
//                                         const Icon(Symbols.schedule, size: 16),
//                                         const SizedBox(width: 8),
//                                         Text(
//                                           "Waktu Pengumpulan: ${detailPengumpulan.first.waktuPengumpulan?.toString() ?? 'Tidak tersedia'}",
//                                           style: const TextStyle(fontSize: 14),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Row(
//                                       children: [
//                                         const Icon(Symbols.flag, size: 16),
//                                         const SizedBox(width: 8),
//                                         Text(
//                                           "Status: ${detailPengumpulan.first.statusPengumpulan ?? 'Tidak tersedia'}",
//                                           style: const TextStyle(fontSize: 14),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 20),
//                                   ],
//                                 ),

//                               // File yang sudah dikumpulkan
//                               _buildFileList(),

//                               const SizedBox(height: 20),

//                               // Tambah file baru
//                               FileTextFieldWidget(
//                                 title: "Tambah File Baru (Opsional)",
//                                 addFileAction: _pilihFile,
//                               ),

//                               const SizedBox(height: 20),

//                               // Daftar file baru
//                               _buildNewFileList(),

//                               const SizedBox(height: 20),

//                               // Tombol Aksi
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.end,
//                                 children: [
//                                   OutlinedButton(
//                                     onPressed: () => context.pop(),
//                                     style: OutlinedButton.styleFrom(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 30,
//                                         vertical: 12,
//                                       ),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(5),
//                                       ),
//                                     ),
//                                     child: const Text('Batal'),
//                                   ),
//                                   const SizedBox(width: 10),
//                                   ElevatedButton(
//                                     onPressed: _updatePengumpulanTugas,
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: const Color(0xff016EB3),
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 30,
//                                         vertical: 12,
//                                       ),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(5),
//                                       ),
//                                     ),
//                                     child: const Text(
//                                       'Update Pengumpulan',
//                                       style: TextStyle(color: Colors.white),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

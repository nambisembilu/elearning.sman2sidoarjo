// import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:material_symbols_icons/material_symbols_icons.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// class PreviewPengumpulanTugas extends StatefulWidget {
//   final String hintText;
//   final TextEditingController pController;

//   const PreviewPengumpulanTugas({
//     super.key,
//     required this.hintText,
//     required this.pController,
//   });

//   @override
//   State<PreviewPengumpulanTugas> createState() =>
//       _PreviewPengumpulanTugasState();
// }

// class _PreviewPengumpulanTugasState extends State<PreviewPengumpulanTugas> {
//   bool _isDownloading = false;
//   int? _downloadingIndex;

//   String _getFileNameFromUrl(String url) {
//     try {
//       final uri = Uri.parse(url);
//       final pathSegments = uri.pathSegments;
//       if (pathSegments.isNotEmpty) {
//         String fileName = pathSegments.last;
//         // Hapus timestamp dari nama file jika ada
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

//   // Fungsi untuk membuka preview file dengan handling mobile
//   Future<void> _previewFile(String fileUrl, int index) async {
//     try {
//       setState(() {
//         _isDownloading = true;
//         _downloadingIndex = index;
//       });

//       // Untuk web dan desktop, gunakan url_launcher
//       if (kIsWeb) {
//         final uri = Uri.parse(fileUrl);
//         if (await canLaunchUrl(uri)) {
//           await launchUrl(uri);
//         } else {
//           _showErrorDialog('Tidak dapat membuka file');
//         }
//       }
//       // Untuk mobile, download dan buka dengan open_filex
//       else {
//         await _downloadAndOpenFile(fileUrl);
//       }
//     } catch (e) {
//       _showErrorDialog('Error: $e');
//     } finally {
//       setState(() {
//         _isDownloading = false;
//         _downloadingIndex = null;
//       });
//     }
//   }

//   // Download dan buka file di mobile
//   Future<void> _downloadAndOpenFile(String fileUrl) async {
//     try {
//       final dio = Dio();
//       final fileName = _getFileNameFromUrl(fileUrl);

//       // Dapatkan directory untuk menyimpan file
//       final Directory tempDir = await getTemporaryDirectory();
//       final String filePath = '${tempDir.path}/$fileName';

//       // Download file
//       await dio.download(
//         fileUrl,
//         filePath,
//         onReceiveProgress: (received, total) {
//           if (total != -1) {
//             print(
//               'Download progress: ${(received / total * 100).toStringAsFixed(0)}%',
//             );
//           }
//         },
//       );

//       // Buka file dengan open_filex
//       final result = await OpenFilex.open(filePath);

//       if (result.type != ResultType.done) {
//         _showErrorDialog('Tidak dapat membuka file: ${result.message}');
//       }
//     } catch (e) {
//       _showErrorDialog('Download gagal: $e');
//     }
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Error'),
//             content: Text(message),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       // Berikan constraints agar widget ini tidak unbounded
//       constraints: BoxConstraints(
//         minWidth: 300, // Atur lebar minimum sesuai kebutuhan
//         maxWidth: 400, // Atur lebar maksimum sesuai kebutuhan
//       ),
//       child: Container(
//         padding: EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade300),
//           borderRadius: BorderRadius.circular(5),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Pengumpulan Tugas",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             // 🔹 Area komentar scrollable yang mengisi ruang tersisa
//             Expanded(
//               child: ListView(
//                 padding: const EdgeInsets.all(8),
//                 children: const [
//                   Center(
//                     child: Column(
//                       children: [
//                         SizedBox(height: 100),
//                         Text(
//                           "Anda belum mengumpulkan.",
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: avoid_print, use_build_context_synchronously

// import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

import '../../../../../models/siswa/tugas_kelas_model.dart';
import '../../../../controllers/siswa/tugas/tugas_riverpod.dart';
import '../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../shared_widgets/general_old/dialog_konfirmasi_widget.dart';
import '../../../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../../../shared_widgets/general_old/file_textfield_widget.dart';
import '../../../../shared_widgets/general_old/header2_widget.dart';

class EditPengumpulanTugasSiswaScreen extends ConsumerStatefulWidget {
  const EditPengumpulanTugasSiswaScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditPengumpulanTugasSiswaScreenState();
}

class _EditPengumpulanTugasSiswaScreenState extends ConsumerState<EditPengumpulanTugasSiswaScreen> {
  final _formKey = GlobalKey<FormState>();

  List<PlatformFile> pickedFiles = [];
  List<Map<String, String>> existingFiles = [];
  List<String> filesToDelete = [];
  List<TugasKelas> detailPengumpulanTugasList = [];

  bool isSubmitted = false;
  bool isLoading = true;
  bool _isDownloading = false;
  int? _downloadingIndex;
  int? pengumpulanTugasId;
  String? tanggalDeadline;
  String? statusPengumpulan;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final tugasId = prefs.getInt('tugasId');
    final deadline = prefs.getString('tanggalDeadline');

    if (tugasId == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      final pengumpulanDetail = await ref
          .read(tugasKelasRiverpodProvider.notifier)
          .getDetailTugas(tugasId: tugasId);

      if (!mounted) return;

      setState(() {
        detailPengumpulanTugasList = pengumpulanDetail;

        if (detailPengumpulanTugasList.isNotEmpty) {
          final detail = detailPengumpulanTugasList.first;
          // jmlPengumpulanController.text = tugas.maxFilePengumpulan.toString();
          existingFiles = List.from(detail.filePengumpulanTugas);
          pengumpulanTugasId = detail.penumpulanTugasId!;

          statusPengumpulan = detail.statusPengumpulanTugas;
        }
        isLoading = false;

        tanggalDeadline = deadline;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showErrorDialog('Gagal memuat data: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => DialogErrorWidget(errorText: message),
    );
  }

  // Fungsi untuk mengecek apakah deadline sudah lewat
  bool _isDeadlinePassed() {
    if (tanggalDeadline == null || tanggalDeadline!.isEmpty) {
      return false;
    }

    try {
      // Format tanggalDeadline: "2025-08-03 12:44:08"
      final deadlineParts = tanggalDeadline!.split(' ');
      if (deadlineParts.length != 2) return false;

      final dateParts = deadlineParts[0].split('-');
      final timeParts = deadlineParts[1].split(':');

      if (dateParts.length != 3 || timeParts.length != 3) return false;

      final deadlineDateTime = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        int.parse(timeParts[2]),
      );

      final now = DateTime.now();

      return now.isAfter(deadlineDateTime);
    } catch (e) {
      print('Error parsing deadline: $e');
      return false;
    }
  }

  Future<void> _pilihFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'pptx',
        'mp4',
        'mp3',
        'txt',
        'jpg',
        'png',
        'jpeg',
        'csv',
      ],
      allowMultiple: true,
      withData: true, // penting untuk web agar file.size terbaca
    );

    if (result != null && result.files.isNotEmpty) {
      const maxFileSize = 5 * 1024 * 1024; // 5 MB (dalam byte)

      final validFiles = result.files.where((file) {
        if (file.size > maxFileSize) {
          // ✅ Tampilkan peringatan di console
          print(
            '❌ File "${file.name}" terlalu besar (${(file.size / 1024 / 1024).toStringAsFixed(2)} MB)',
          );

          showDialog(
            context: context,
            builder: (context) => DialogErrorWidget(
              errorText:
                  'Ukuran file "${file.name}" melebihi 5 MB dan tidak ditambahkan.',
            ),
          );
          return false;
        }
        return true;
      }).toList();

      if (validFiles.isNotEmpty) {
        setState(() {
          pickedFiles.addAll(validFiles);
        });
      }
    }
  }

  void _tutupLoadingIndicator() {
    // Tutup loading indicator dengan rootNavigator
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> openPickedFileWeb(PlatformFile file) async {
    final bytes = file.bytes;
    if (bytes == null) {
      print('⚠️ File tidak memiliki bytes');
      return;
    }

    // Ambil ekstensi file
    final ext = file.extension?.toLowerCase();
    if (ext == null ||
        ![
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'pptx',
          'mp4',
          'mp3',
          'txt',
          'jpg',
          'png',
          'jpeg',
          'csv',
        ].contains(ext)) {
      print('❌ Tipe file tidak didukung');
      return;
    }

    // Tentukan MIME type
    String mimeType = 'application/octet-stream';
    switch (ext) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        mimeType = 'image/$ext';
        break;
      case 'pdf':
        mimeType = 'application/pdf';
        break;
      case 'txt':
      case 'csv':
        mimeType = 'text/plain';
        break;
      case 'mp4':
        mimeType = 'video/mp4';
        break;
      case 'mp3':
        mimeType = 'audio/mpeg';
        break;
      case 'doc':
      case 'docx':
        mimeType =
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        break;
      case 'xls':
      case 'xlsx':
        mimeType =
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
        break;
      case 'pptx':
        mimeType =
            'application/vnd.openxmlformats-officedocument.presentationml.presentation';
        break;
    }

    // Buka file di tab baru
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, "_blank");

    // Revoke URL setelah beberapa detik
    Future.delayed(const Duration(seconds: 2), () {
      html.Url.revokeObjectUrl(url);
    });
  }

  Future<void> openPickedFileNonWeb(PlatformFile file) async {
    final ext = file.extension?.toLowerCase();
    if (ext == null ||
        ![
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'pptx',
          'mp4',
          'mp3',
          'txt',
          'jpg',
          'png',
          'jpeg',
          'csv',
        ].contains(ext)) {
      print('❌ Tipe file tidak didukung');
      return;
    }

    if (file.path != null) {
      final result = await OpenFilex.open(file.path!);
      if (result.type != ResultType.done) {
        print('❌ Gagal membuka file: ${result.message}');
      }
    } else {
      print('⚠️ File tidak memiliki path');
    }
  }

  // Fungsi untuk membuka preview file dengan handling mobile
  Future<void> _previewFile(String fileUrl, int index) async {
    try {
      setState(() {
        _isDownloading = true;
        _downloadingIndex = index;
      });

      // Untuk web dan desktop, gunakan url_launcher
      if (kIsWeb) {
        final uri = Uri.parse(fileUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          _showErrorDialog('Tidak dapat membuka file');
        }
      }
      // Untuk mobile, download dan buka dengan open_filex
      else {
        await _downloadAndOpenFile(fileUrl);
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() {
        _isDownloading = false;
        _downloadingIndex = null;
      });
    }
  }

  // Download dan buka file di mobile
  Future<void> _downloadAndOpenFile(String fileUrl) async {
    try {
      final dio = Dio();
      final fileName = _getFileNameFromUrl(fileUrl);

      // Dapatkan directory untuk menyimpan file
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/$fileName';

      // Download file
      await dio.download(
        fileUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print(
              'Download progress: ${(received / total * 100).toStringAsFixed(0)}%',
            );
          }
        },
      );

      // Buka file dengan open_filex
      final result = await OpenFilex.open(filePath);

      if (result.type != ResultType.done) {
        _showErrorDialog('Tidak dapat membuka file: ${result.message}');
      }
    } catch (e) {
      _showErrorDialog('Download gagal: $e');
    }
  }

  void _hapusFileBaru(PlatformFile file) {
    setState(() {
      pickedFiles.remove(file);
    });
  }

  void _hapusFileExisting(Map<String, String> file) {
    setState(() {
      final fileUrl = file['link_file'] ?? '';
      if (fileUrl.isNotEmpty) {
        filesToDelete.add(fileUrl);
      }
      existingFiles.remove(file);
    });
  }

  String _getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        String fileName = pathSegments.last;
        final parts = fileName.split('_');
        if (parts.length > 1) {
          return parts.sublist(1).join('_');
        }
        return fileName;
      }
      return 'File';
    } catch (e) {
      return 'File';
    }
  }

  Future<void> _prosesPengumpulanTugas() async {
    // Validasi file
    if (pickedFiles.isEmpty && existingFiles.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const DialogErrorWidget(
          errorText: "Belum ada file yang ditambahkan",
        ),
      );
      return;
    }

    // Validasi form
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    setState(() {
      isSubmitted = true;
    });

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Konversi file ke Uint8List
      final fileBytes = pickedFiles.map((f) {
        if (f.bytes != null) {
          return f.bytes!;
        } else if (f.path != null) {
          return File(f.path!).readAsBytesSync();
        } else {
          throw Exception("File tidak valid");
        }
      }).toList();

      final fileNames = pickedFiles.map((f) => f.name).toList();

      final success = await ref
          .read(tugasKelasRiverpodProvider.notifier)
          .updatePengumpulanTugas(
            pengumpulanTugasId: pengumpulanTugasId!,
            statusPengumpulan: statusPengumpulan!,
            filesToDelete: filesToDelete,
            filesToKeep: existingFiles,
            fileBytes: fileBytes,
            fileNames: fileNames,
          );

      // Tutup loading indicator setelah selesai
      _tutupLoadingIndicator();

      if (success) {
        if (!mounted) return;

        // Tampilkan dialog sukses
        await showDialog(
          context: context,
          builder: (context) => DialogSuccessWidget(
            succesText: 'Pengumpulan tugas berhasil diperbarui',
          ),
        );

        if (!mounted) return;
        context.pop(); // Kembali ke halaman sebelumnya
      }
    } catch (e) {
      // Tutup loading indicator jika error
      _tutupLoadingIndicator();

      // Tampilkan dialog error
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) =>
              DialogErrorWidget(errorText: "Terjadi kesalahan: $e"),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Header2Widget(
                          header2Title: "Pengumpulan Tugas",
                          subtitle: "Tambahkan file untuk mengumpulkan tugas.",
                        ),
                        const SizedBox(height: 10),
                        // const Divider(color: Colors.black, thickness: 1),
                        Container(
                          padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 20,
                            top: 0,
                          ),
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
                              FileTextFieldWidget(
                                title: "",
                                addFileAction: _pilihFile,
                              ),
                              const SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // SizedBox(
                                  //   width:
                                  //       MediaQuery.of(context).size.width * 0.1,
                                  // ),
                                  ...existingFiles.map(
                                    (file) => Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                    color: Colors.grey.shade400,
                                                  ),
                                                ),
                                                child: InkWell(
                                                  onTap: _isDownloading
                                                      ? null
                                                      : () {
                                                          final fileUrl =
                                                              file['link_file'] ??
                                                              '';
                                                          if (fileUrl
                                                              .isNotEmpty) {
                                                            final index =
                                                                existingFiles
                                                                    .indexOf(
                                                                      file,
                                                                    );
                                                            _previewFile(
                                                              fileUrl,
                                                              index,
                                                            );
                                                          } else {
                                                            _showErrorDialog(
                                                              'Link file tidak ditemukan',
                                                            );
                                                          }
                                                        },
                                                  child: ListTile(
                                                    leading: const Icon(
                                                      Symbols.attachment,
                                                      size: 20,
                                                    ),
                                                    title: Text(
                                                      _getFileNameFromUrl(
                                                        file['link_file'] ?? '',
                                                      ),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    trailing: IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () =>
                                                          _hapusFileExisting(
                                                            file,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  if (pickedFiles.isNotEmpty)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Tambahan file baru :",
                                              ),
                                              const SizedBox(height: 10),
                                              ...pickedFiles.map(
                                                (e) => Column(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              5,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors
                                                              .grey
                                                              .shade400,
                                                        ),
                                                      ),
                                                      child: InkWell(
                                                        onTap: () => kIsWeb
                                                            ? openPickedFileWeb(
                                                                e,
                                                              )
                                                            : openPickedFileNonWeb(
                                                                e,
                                                              ),
                                                        child: ListTile(
                                                          leading: const Icon(
                                                            Icons.book,
                                                            size: 20,
                                                          ),
                                                          title: Text(
                                                            e.name.toString(),
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 12,
                                                                ),
                                                          ),
                                                          trailing: IconButton(
                                                            icon: const Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                            ),
                                                            onPressed: () {
                                                              setState(() {
                                                                final index =
                                                                    pickedFiles
                                                                        .indexOf(
                                                                          e,
                                                                        );
                                                                if (index !=
                                                                    -1) {
                                                                  pickedFiles
                                                                      .removeAt(
                                                                        index,
                                                                      );
                                                                }
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (_isDeadlinePassed()) {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              DialogKonfirmasiWidget(
                                                confirmText:
                                                    "Tugas ini sudah melewati deadline, sehingga statusnya akan menjadi 'Terlambat'. Apakah Anda ingin tetap memperbarui pengumpulan tugas?",
                                                confirmAction: () async {
                                                  // Tutup dialog konfirmasi
                                                  Navigator.of(context).pop();

                                                  setState(() {
                                                    statusPengumpulan =
                                                        'Terlambat';
                                                  });

                                                  await _prosesPengumpulanTugas();
                                                },
                                              ),
                                        );
                                      } else {
                                        await _prosesPengumpulanTugas();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff016EB3),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ), // 👈 bikin kotak
                                      ),
                                    ),
                                    child: const Text(
                                      'Kumpulkan Ulang',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ignore_for_file: avoid_print, use_build_context_synchronously

// import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:universal_html/html.dart' as html;

import '../../../../controllers/siswa/tugas/tugas_riverpod.dart';
import '../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../../../shared_widgets/general_old/file_textfield_widget.dart';
import '../../../../shared_widgets/general_old/header2_widget.dart';

class PengumpulanTugasSiswaScreen extends ConsumerStatefulWidget {
  const PengumpulanTugasSiswaScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PengumpulanTugasSiswaScreenState();
}

class _PengumpulanTugasSiswaScreenState
    extends ConsumerState<PengumpulanTugasSiswaScreen> {
  final _formKey = GlobalKey<FormState>();

  List<PlatformFile> pickedFiles = [];

  bool isSubmitted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // SizedBox(
                                  //   width:
                                  //       MediaQuery.of(context).size.width * 0.1,
                                  // ),
                                  if (pickedFiles.isNotEmpty)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("File yang ditambahkan :"),
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
                                                      color:
                                                          Colors.grey.shade400,
                                                    ),
                                                  ),
                                                  child: InkWell(
                                                    onTap: () => kIsWeb
                                                        ? openPickedFileWeb(e)
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
                                                        style: const TextStyle(
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
                                                                    .indexOf(e);
                                                            if (index != -1) {
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
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      setState(() {
                                        isSubmitted = true;
                                      });

                                      final isValid = _formKey.currentState!
                                          .validate();
                                      // final isMateriValid =
                                      //     quillFieldKey.currentState!
                                      //         .validate();

                                      if (pickedFiles.isEmpty) {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              const DialogErrorWidget(
                                                errorText:
                                                    "Belum ada file yang ditambahkan",
                                              ),
                                        );
                                        return;
                                      }

                                      if (isValid) {
                                        // Show loading indicator
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );

                                        try {
                                          // Konversi file ke Uint8List
                                          final fileBytes = pickedFiles.map((
                                            f,
                                          ) {
                                            if (f.bytes != null) {
                                              return f.bytes!;
                                            } else if (f.path != null) {
                                              return File(
                                                f.path!,
                                              ).readAsBytesSync();
                                            } else {
                                              throw Exception(
                                                "File tidak valid",
                                              );
                                            }
                                          }).toList();

                                          final fileNames = pickedFiles
                                              .map((f) => f.name)
                                              .toList();

                                          final success = await ref
                                              .read(
                                                tugasKelasRiverpodProvider
                                                    .notifier,
                                              )
                                              .submitTugas(
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
                                              builder: (context) =>
                                                  DialogSuccessWidget(
                                                    succesText:
                                                        'Materi berhasil ditambahkan',
                                                  ),
                                            );

                                            if (!mounted) return;
                                            context
                                                .pop(); // Kembali ke halaman sebelumnya
                                          }
                                        } catch (e) {
                                          // Tutup loading indicator jika error
                                          _tutupLoadingIndicator();

                                          // Tampilkan dialog error
                                          if (mounted) {
                                            showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  DialogErrorWidget(
                                                    errorText:
                                                        "Terjadi kesalahan: $e",
                                                  ),
                                            );
                                          }
                                        }
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
                                      'Kirim',
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

// ignore_for_file: avoid_print, use_build_context_synchronously

// import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
// import 'package:elearning_guru/general_widgets/quill_textfiled_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../models/guru/filtering_model.dart';
import '../../../../../models/guru/materi_kelas_model.dart';
import '../../../../controllers/guru/materi/materi_kelas_riverpod.dart';
import '../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../../../shared_widgets/general_old/dropdown2_widget.dart';
import '../../../../shared_widgets/general_old/file_textfield_widget.dart';
import '../../../../shared_widgets/general_old/header2_widget.dart';
import '../../../../shared_widgets/general_old/rich_textfield_widget.dart';
import '../../../../shared_widgets/general_old/textfield2_widget.dart';

class EditMateriScreen extends ConsumerStatefulWidget {
  const EditMateriScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditMateriScreenState();
}

class _EditMateriScreenState extends ConsumerState<EditMateriScreen> {
  final _formKey = GlobalKey<FormState>();
  // final quillFieldKey = GlobalKey<QuillTextfiledWidgetState>();
  final TextEditingController judulController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  // late quill.QuillController _materiController;

  List<PlatformFile> pickedFiles = [];
  List<Map<String, String>> existingFiles = [];
  List<String> filesToDelete = [];
  String? selectedLingkupMateri;
  int? selectedLingkupMateriId;
  List<LingkupMateri> lingkupMateriList = [];
  List<MateriKelas> detailMateriList = [];

  bool isSubmitted = false;
  bool isLoading = true;
  String statusMateri = 'Visible'; // Default status

  bool _isDownloading = false;
  int? _downloadingIndex;

  @override
  void initState() {
    super.initState();
    // _materiController = quill.QuillController.basic();
    _loadData();
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

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final materiId = prefs.getInt('materiId');

    if (materiId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final lingkupList = await ref
          .read(materiKelasRiverpodProvider.notifier)
          .fetchLingkupMateri();

      final materiDetail = await ref
          .read(materiKelasRiverpodProvider.notifier)
          .getDetailMateri(materiId: materiId);

      if (!mounted) return;

      setState(() {
        lingkupMateriList = lingkupList;
        detailMateriList = materiDetail;

        if (detailMateriList.isNotEmpty) {
          final materi = detailMateriList.first;
          judulController.text = materi.judulMateri;
          deskripsiController.text = materi.deskripsiMateri;
          selectedLingkupMateri = materi.lingkupMateri;
          selectedLingkupMateriId = materi.lingkupMateriId;
          existingFiles = List.from(materi.fileMateri);
          statusMateri = materi.statusMateri;
        }
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showErrorDialog('Gagal memuat data: $e');
    }
  }

  Future<void> _pilihFile() async {
    final result = await FilePicker.pickFiles(allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        pickedFiles.addAll(result.files);
      });
    }
  }

  void _hapusFileBaru(PlatformFile file) {
    setState(() {
      pickedFiles.remove(file);
    });
  }

  void _hapusFileExisting(Map<String, String> file) {
    setState(() {
      final fileUrl = file['link_file_materi'] ?? '';
      if (fileUrl.isNotEmpty) {
        filesToDelete.add(fileUrl);
      }
      existingFiles.remove(file);
    });
  }

  void _tutupLoadingIndicator() {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => DialogErrorWidget(errorText: message),
    );
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

  @override
  void dispose() {
    judulController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                          header2Title: "Edit Materi",
                          subtitle:
                              "Lengkapi form berikut untuk memperbarui materi.",
                        ),
                        const SizedBox(height: 10),
                        // const Divider(color: Colors.black, thickness: 1),
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
                              TextField2GeneralWidget(
                                title: "Judul Materi",
                                hintText: "Masukkan judul materi",
                                pController: judulController,
                                isRequired: true,
                              ),
                              const SizedBox(height: 20),
                              Dropdown2GeneralWidget(
                                pTitle: 'Lingkup Materi',
                                pHintText: 'Pilih lingkup materi',
                                valueParams: selectedLingkupMateri,
                                pItems: lingkupMateriList
                                    .map((e) => e.judulLM)
                                    .toList(),
                                pOnChanged: (value) {
                                  setState(() {
                                    selectedLingkupMateri = value;
                                    final selectedObj = lingkupMateriList
                                        .firstWhere((e) => e.judulLM == value);
                                    selectedLingkupMateriId =
                                        selectedObj.lingkupMateriId;
                                  });
                                },
                                isRequired: true,
                                isSubmitted: isSubmitted,
                              ),
                              const SizedBox(height: 10),
                              // QuillTextfiledWidget(
                              //   key: quillFieldKey,
                              //   textController: _materiController,
                              //   isRequired: true,
                              // ),
                              RichTextFieldGeneralWidget(
                                title: "Deskripsi Materi",
                                hintText: "Masukkan deskripsi materi",
                                isRequired: true,
                                pMinLines: 10,
                                p_controller: deskripsiController,
                              ),
                              const SizedBox(height: 20),
                              FileTextFieldWidget(
                                addFileAction: _pilihFile,
                                title: 'Pilih File',
                              ),
                              const SizedBox(height: 20),
                              // Tampilkan file yang sudah ada
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // SizedBox(
                                  //   width:
                                  //       MediaQuery.of(context).size.width * 0.1,
                                  // ),
                                  if (existingFiles.isNotEmpty) ...[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "File yang sudah ada:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          ...existingFiles.map(
                                            (file) => Column(
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
                                                    onTap: _isDownloading
                                                        ? null
                                                        : () {
                                                            final fileUrl =
                                                                file['link_file_materi'] ??
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
                                                          file['link_file_materi'] ??
                                                              '',
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
                                                const SizedBox(height: 5),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                  ),
                                  // Tampilkan file baru
                                  if (pickedFiles.isNotEmpty) ...[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "File baru yang ditambahkan:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          ...pickedFiles.map(
                                            (file) => Column(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          Colors.blue.shade200,
                                                    ),
                                                  ),
                                                  child: ListTile(
                                                    leading: const Icon(
                                                      Symbols.upload,
                                                      size: 20,
                                                      color: Colors.blue,
                                                    ),
                                                    title: Text(
                                                      file.name,
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
                                                          _hapusFileBaru(file),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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

                                      if (judulController.text.trim().isEmpty ||
                                          // _materiController.document
                                          //     .toPlainText()
                                          //     .trim()
                                          //     .isEmpty ||
                                          // !isMateriValid ||
                                          selectedLingkupMateriId == null) {
                                        _showErrorDialog(
                                          "Semua field harus diisi",
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
                                          // Konversi file baru ke Uint8List
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

                                          // Simpan rich text Quill dalam format Delta JSON
                                          // final deskripsiJson = jsonEncode(
                                          //   _materiController.document
                                          //       .toDelta()
                                          //       .toJson(),
                                          // );

                                          final success = await ref
                                              .read(
                                                materiKelasRiverpodProvider
                                                    .notifier,
                                              )
                                              .updateMateri(
                                                materiId: detailMateriList
                                                    .first
                                                    .materiId,
                                                judul: judulController.text,
                                                lingkupMateriId:
                                                    selectedLingkupMateriId!,
                                                // deskripsi: deskripsiJson,
                                                deskripsi:
                                                    deskripsiController.text,
                                                status:
                                                    statusMateri, // Kirim status
                                                fileBytes: fileBytes,
                                                fileNames: fileNames,
                                                filesToDelete: filesToDelete,
                                                filesToKeep: existingFiles,
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
                                                        'Materi berhasil diperbarui',
                                                  ),
                                            );

                                            if (!mounted) return;
                                            context.pop();
                                          }
                                        } catch (e) {
                                          // Tutup loading indicator jika error
                                          _tutupLoadingIndicator();
                                          _showErrorDialog(
                                            "Terjadi kesalahan: $e",
                                          );
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
                                      'Simpan Perubahan',
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

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
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../models/guru/tugas_kelas_model.dart';
import '../../../../controllers/guru/tugas/tugas_kelas_riverpod.dart';
import '../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../../../shared_widgets/general_old/dropdown2_widget.dart';
import '../../../../shared_widgets/general_old/file_textfield_widget.dart';
import '../../../../shared_widgets/general_old/header2_widget.dart';
import '../../../../shared_widgets/general_old/rich_textfield_widget.dart';
import '../../../../shared_widgets/general_old/textfield2_widget.dart';

class EditTugasScreen extends ConsumerStatefulWidget {
  const EditTugasScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditTugasScreenState();
}

class _EditTugasScreenState extends ConsumerState<EditTugasScreen> {
  final _formKey = GlobalKey<FormState>();

  // final quillFieldKey = GlobalKey<QuillTextfiledWidgetState>();
  // late quill.QuillController _tugasController;

  final TextEditingController judulController = TextEditingController();
  final TextEditingController jmlPengumpulanController =
      TextEditingController();
  final TextEditingController deskrispsiController = TextEditingController();

  String? selectedStatusTugas;
  DateTime? selectedDeadline;

  List<PlatformFile> pickedFiles = [];
  List<Map<String, String>> existingFiles = [];
  List<String> filesToDelete = [];
  List<TugasKelas> detailTugasList = [];

  bool isSubmitted = false;
  bool isLoading = true;
  bool _isDownloading = false;
  int? _downloadingIndex;

  @override
  void initState() {
    super.initState();
    // _tugasController = quill.QuillController.basic();
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
    final tugasId = prefs.getInt('tugasId');

    if (tugasId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final tugasDetail = await ref
          .read(tugasKelasRiverpodProvider.notifier)
          .getDetailTugas(tugasId: tugasId);

      if (!mounted) return;

      setState(() {
        detailTugasList = tugasDetail;

        if (detailTugasList.isNotEmpty) {
          final tugas = detailTugasList.first;
          selectedStatusTugas = tugas.statusTugas;
          judulController.text = tugas.judulTugas;
          deskrispsiController.text = tugas.deskripsiTugas;
          // jmlPengumpulanController.text = tugas.maxFilePengumpulan.toString();
          existingFiles = List.from(tugas.fileTugas);

          // Load deadline dari data tugas
          if (tugas.tanggalDeadline != null &&
              tugas.tanggalDeadline.isNotEmpty) {
            try {
              // Konversi string deadline ke DateTime
              selectedDeadline = DateTime.parse(tugas.tanggalDeadline);
            } catch (e) {
              print("Gagal memparsing deadline: $e");
              selectedDeadline = null;
            }
          } else {
            selectedDeadline = null;
          }

          // Load deskripsi Quill
          final deskripsi = tugas.deskripsiTugas;
          if (deskripsi.isNotEmpty) {
            try {
              // final decoded = jsonDecode(deskripsi);
              // _tugasController = quill.QuillController(
              //   document: quill.Document.fromJson(decoded),
              //   selection: const TextSelection.collapsed(offset: 0),
              // );
            } catch (e) {
              print("Gagal memuat deskripsi Quill: $e");
              // _tugasController = quill.QuillController.basic();
            }
          }
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
      final fileUrl = file['link_file_tugas'] ?? '';
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

  String formatDateTime(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00";
  }

  // Helper method untuk menampilkan tanggal dalam format yang lebih user-friendly
  String _formatDateTimeForDisplay(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _selectDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDeadline = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
            0, // Set detik menjadi 0
          );
        });
      }
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
                          header2Title: "Edit Penugasan",
                          subtitle:
                              "Lengkapi form berikut untuk memperbarui penugasan.",
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
                                title: "Judul Tugas",
                                hintText: "Masukkan judul tugas",
                                pController: judulController,
                                isRequired: true,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Dropdown2GeneralWidget(
                                      pTitle: "Status Tugas",
                                      pHintText: "Pilih status tugas",
                                      valueParams: selectedStatusTugas,
                                      pItems: ['Visible', 'Hide'],
                                      pOnChanged: (value) {
                                        setState(() {
                                          selectedStatusTugas = value;
                                        });
                                      },
                                      isRequired: true,
                                      isSubmitted: isSubmitted,
                                    ),
                                  ),
                                  // SizedBox(width: 20),
                                  // Expanded(
                                  //   child: TextField2GeneralWidget(
                                  //     title: "Batas jumlah file",
                                  //     hintText:
                                  //         "Batas jumlah file yang dikumpulkan",
                                  //     pController: jmlPengumpulanController,
                                  //     isRequired: true,
                                  //   ),
                                  // ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Deadline Tugas *",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  selectedDeadline != null
                                                      ? _formatDateTimeForDisplay(
                                                          selectedDeadline!,
                                                        )
                                                      : "Pilih tanggal dan waktu",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color:
                                                        selectedDeadline != null
                                                        ? Colors.black
                                                        : Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.calendar_today,
                                                ),
                                                onPressed: _selectDateTime,
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSubmitted &&
                                            selectedDeadline == null)
                                          Text(
                                            "Deadline harus diisi",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // QuillTextfiledWidget(
                              //   key: quillFieldKey,
                              //   textController: _tugasController,
                              //   isRequired: true,
                              // ),
                              RichTextFieldGeneralWidget(
                                title: "Deskrispi Tugas",
                                hintText: "Masukkan deskripsi tugas",
                                p_controller: deskrispsiController,
                                isRequired: true,
                                pMinLines: 10,
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
                                                                file['link_file_tugas'] ??
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
                                                          file['link_file_tugas'] ??
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
                                      // final isTugasValid =
                                      //     quillFieldKey.currentState!
                                      //         .validate();

                                      if (judulController.text.trim().isEmpty ||
                                          // jmlPengumpulanController.text
                                          //     .trim()
                                          //     .isEmpty ||
                                          deskrispsiController.text
                                              .trim()
                                              .isEmpty ||
                                          // _tugasController.document
                                          //     .toPlainText()
                                          //     .trim()
                                          //     .isEmpty ||
                                          // !isTugasValid ||
                                          selectedStatusTugas == null ||
                                          selectedDeadline == null) {
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
                                          //   _tugasController.document
                                          //       .toDelta()
                                          //       .toJson(),
                                          // );

                                          final success = await ref
                                              .read(
                                                tugasKelasRiverpodProvider
                                                    .notifier,
                                              )
                                              .updateTugas(
                                                tugasId: detailTugasList
                                                    .first
                                                    .tugasId,
                                                judul: judulController.text,
                                                // deskripsi: deskripsiJson,
                                                deskripsi:
                                                    deskrispsiController.text,
                                                statusTugas:
                                                    selectedStatusTugas!,
                                                // maxJmlPengumpulan: int.parse(
                                                //   jmlPengumpulanController.text,
                                                // ),
                                                deadline: formatDateTime(
                                                  selectedDeadline!,
                                                ),
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
                                                        'Informasi tugas berhasil diperbarui',
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

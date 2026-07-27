// ignore_for_file: avoid_print, use_build_context_synchronously

// import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../models/guru/pengumpulan_tugas_model.dart';
import '../../../../controllers/guru/tugas/tugas_kelas_riverpod.dart';
import '../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../../../shared_widgets/general_old/header2_widget.dart';
import '../../../../shared_widgets/general_old/rich_textfield_widget.dart';
import '../../../../shared_widgets/general_old/textfield2_widget.dart';

class BeriNilaiTugasScreen extends ConsumerStatefulWidget {
  const BeriNilaiTugasScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BeriNilaiTugasScreenState();
}

class _BeriNilaiTugasScreenState extends ConsumerState<BeriNilaiTugasScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, String>> existingFiles = [];
  List<PengumpulanTugasDetailModel> detailPengumpulanTugasList = [];

  TextEditingController nilaiController = TextEditingController();
  TextEditingController feedBackController = TextEditingController();

  bool isSubmitted = false;
  bool isLoading = true;
  bool _isDownloading = false;
  int? _downloadingIndex;
  int? pengumpulanTugasId;
  String? tanggalDeadline;
  String? statusPengumpulan;
  String? tanggalPengumpulan;
  String? namaSiswa;

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
    final namaSiswaZ = prefs.getString('namaSiswa');
    final nilaiSiswa = prefs.getString('nilaiSiswa');
    final feedback = prefs.getString('feedback');

    if (tugasId == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      // ✅ PERBAIKAN: Hanya 1 data yang diharapkan
      final pengumpulanDetail = await ref
          .read(tugasKelasRiverpodProvider.notifier)
          .getDetailPengumpulanTugasSiswa();

      if (!mounted) return;

      setState(() {
        // ✅ PERBAIKAN: Buat list dengan data tunggal
        detailPengumpulanTugasList = [pengumpulanDetail];

        // ✅ PERBAIKAN: Isi existingFiles dari files yang ada di response
        if (pengumpulanDetail.files != null &&
            pengumpulanDetail.files!.isNotEmpty) {
          statusPengumpulan = pengumpulanDetail.statusPengumpulan;
          tanggalPengumpulan = pengumpulanDetail.waktuPengumpulan;
          pengumpulanTugasId = pengumpulanDetail.pengumpulanTugasId;

          if (nilaiSiswa != null) {
            nilaiController.text = nilaiSiswa;
          }

          if (feedback != null) {
            feedBackController.text = feedback;
          }

          existingFiles = pengumpulanDetail.files!.map((fileUrl) {
            return {
              'link_file': fileUrl,
              'file_name': _getFileNameFromUrl(fileUrl), // Tambahkan nama file
            };
          }).toList();
        } else {
          existingFiles = []; // Kosongkan jika tidak ada file
        }

        if (pengumpulanDetail != null) {
          // jmlPengumpulanController.text = tugas.maxFilePengumpulan.toString();
          // existingFiles = List.from(detail.files);
          // pengumpulanTugasId = detail.penumpulanTugasId!;
          // statusPengumpulan = detail.statusPengumpulanTugas;
        }
        tanggalDeadline = deadline;
        namaSiswa = namaSiswaZ;
        isLoading = false;
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

  void _tutupLoadingIndicator() {
    // Tutup loading indicator dengan rootNavigator
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
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
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
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
                          header2Title: "Pengumpulan Tugas",
                          subtitle: "Informasi pengumpulan tugas.",
                        ),
                        const SizedBox(height: 10),
                        // const Divider(color: Colors.black, thickness: 1),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Card(
                                  color: Colors.blue[50],
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Nama Siswa"),
                                            SizedBox(height: 20),
                                            Text("Status"),
                                            SizedBox(height: 20),
                                            Text("Waktu Pengumpulan"),
                                          ],
                                        ),
                                        SizedBox(width: 20),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(": $namaSiswa"),
                                            SizedBox(height: 20),
                                            Text(": $statusPengumpulan"),
                                            SizedBox(height: 20),
                                            Text(": $tanggalPengumpulan"),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text("Lampiran File:"),
                                SizedBox(height: 20),
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
                                TextField2GeneralWidget(
                                  title: "Nilai",
                                  hintText: "Masukkan nilai",
                                  pController: nilaiController,
                                  isRequired: false,
                                ),
                                SizedBox(height: 20),
                                RichTextFieldGeneralWidget(
                                  title: "Umpan Balik",
                                  hintText:
                                      "Tambahkan umpan balik untuk siswa (opsional)",
                                  p_controller: feedBackController,
                                  isRequired: false,
                                  pMinLines: 5,
                                ),
                                SizedBox(height: 20),
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

                                        if (nilaiController.text
                                                .trim()
                                                .isEmpty ||
                                            // jmlPengumpulan.text.trim().isEmpty ||
                                            feedBackController.text
                                                .trim()
                                                .isEmpty) {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                const DialogErrorWidget(
                                                  errorText:
                                                      "Nilai dan umpan balik wajib diisi untuk mengirimkan nilai",
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
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );

                                          try {
                                            final success = await ref
                                                .read(
                                                  tugasKelasRiverpodProvider
                                                      .notifier,
                                                )
                                                .addNilaiTugas(
                                                  pengumpulanTugasId:
                                                      pengumpulanTugasId!,
                                                  nilai: double.parse(
                                                    nilaiController.text,
                                                  ),
                                                  feedback:
                                                      feedBackController.text,
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
                                                          'Nilai berhasil dikirim',
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
                                        backgroundColor: const Color(
                                          0xff016EB3,
                                        ),
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
                                        'Kirim Nilai',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
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

// ignore_for_file: avoid_print

import 'dart:io';
import 'package:elearning_sman2sidoarjo/core/routes/routes_name.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

import '../../../../../models/siswa/tugas_kelas_model.dart';
import '../../../../controllers/siswa/tugas/tugas_riverpod.dart';
import '../../../../shared_widgets/general_old/main_button_widget.dart';

class DetailTugasSiswaScreen extends ConsumerStatefulWidget {
  const DetailTugasSiswaScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DetailTugasSiswaScreenState();
}

class _DetailTugasSiswaScreenState
    extends ConsumerState<DetailTugasSiswaScreen> {
  List<TugasKelas> detailTugasList = [];
  bool isLoading = true;
  TextEditingController komentarController = TextEditingController();
  bool _isDownloading = false;
  int? _downloadingIndex;

  // Status pengumpulan (contoh: bisa disesuaikan dengan data dari API)
  String? statusPengumpulan;
  bool sudahDikumpulkan = false;
  int? pengumpulanTugasId;
  double? nilaiTugas;

  @override
  void initState() {
    super.initState();
    _loadDetailTugas();
  }

  Future<void> _loadDetailTugas() async {
    final prefs = await SharedPreferences.getInstance();
    final tugasId = prefs.getInt('tugasId');

    if (tugasId == null) {
      setState(() => isLoading = false);
      return;
    }

    final list = await ref
        .read(tugasKelasRiverpodProvider.notifier)
        .getDetailTugas(tugasId: tugasId);

    if (!mounted) return;

    setState(() {
      detailTugasList = list;
      sudahDikumpulkan = detailTugasList.first.sudahMengumpulkan ?? false;
      statusPengumpulan = detailTugasList.first.statusPengumpulanTugas;
      pengumpulanTugasId = detailTugasList.first.penumpulanTugasId;
      nilaiTugas = detailTugasList.first.nilaiTugas;
      isLoading = false;
    });
  }

  String _getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        String fileName = pathSegments.last;
        // Hapus timestamp dari nama file jika ada
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

  IconData _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Symbols.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Symbols.description;
      case 'xls':
      case 'xlsx':
        return Symbols.table_chart;
      case 'ppt':
      case 'pptx':
        return Symbols.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Symbols.image;
      case 'mp3':
      case 'wav':
        return Symbols.audiotrack;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Symbols.video_file;
      case 'zip':
      case 'rar':
        return Symbols.folder_zip;
      default:
        return Symbols.insert_drive_file;
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menangani aksi pengumpulan tugas
  void _handlePengumpulanTugas() async {
    final prefs = await SharedPreferences.getInstance();
    final kelasMapelId = prefs.getInt('kelasMapelId');

    context.go(RoutesNames.pengumpulanTugasSiswa);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (detailTugasList.isEmpty) {
            return const Center(child: Text('Tidak ada tugas ditemukan.'));
          }

          final tugas = detailTugasList.first;

          // Tentukan breakpoint untuk layout responsif
          final bool isSmallScreen = constraints.maxWidth < 1000;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: isSmallScreen
                ? // Layout untuk layar kecil (vertikal)
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bagian detail tugas
                        _buildDetailTugasSection(tugas),

                        const SizedBox(height: 30),

                        // Bagian pengumpulan tugas untuk layar kecil
                        _buildPengumpulanTugasSection(tugas, isSmallScreen),
                      ],
                    ),
                  )
                : // Layout untuk layar besar (horizontal)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // bagian detail tugas
                      Expanded(
                        child: SingleChildScrollView(
                          child: _buildDetailTugasSection(tugas),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // bagian pengumpulan tugas untuk layar besar
                      _buildPengumpulanTugasSection(tugas, isSmallScreen),
                    ],
                  ),
          );
        },
      ),
      // Bottom Navigation Bar untuk status dan aksi pengumpulan
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final bool isSmallScreen = constraints.maxWidth < 600;

          return Container(
            height: isSmallScreen
                ? 120
                : 70, // Tinggi lebih besar untuk layar kecil
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: isSmallScreen
                ? // Layout untuk layar kecil (vertikal)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Status pengumpulan
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status Pengumpulan',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (sudahDikumpulkan) ...[
                                    (statusPengumpulan == 'Terlambat')
                                        ? Icon(
                                            Symbols.check_circle,
                                            size: 16,
                                            color: Colors.red,
                                          )
                                        : Icon(
                                            Symbols.check_circle,
                                            size: 16,
                                            color: Colors.green,
                                          ),
                                  ],
                                  if (!sudahDikumpulkan)
                                    Icon(
                                      Symbols.pending,
                                      size: 16,
                                      color: Colors.orange,
                                    ),
                                  const SizedBox(width: 6),
                                  if (sudahDikumpulkan) ...[
                                    (statusPengumpulan == 'Terlambat')
                                        ? Text(
                                            'Terlambat',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red,
                                            ),
                                          )
                                        : Text(
                                            'Tepat Waktu',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green,
                                            ),
                                          ),
                                  ],
                                  if (!sudahDikumpulkan)
                                    Text(
                                      "Belum Mengumpulkan",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          if (sudahDikumpulkan) ...[
                            const Spacer(),
                            Text('Nilai : $nilaiTugas'),
                          ],
                        ],
                      ),

                      const SizedBox(height: 15),

                      // Button Kumpulkan Tugas (untuk layar kecil)
                      if (!sudahDikumpulkan)
                        SizedBox(
                          width: double.infinity,
                          child: MainButtonWidget(
                            btnAction: _handlePengumpulanTugas,
                            btnTitle: "Kumpulkan Tugas",
                            disabled: false,
                          ),
                        ),
                    ],
                  )
                : // Layout untuk layar besar (horizontal)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bagian kiri: Status pengumpulan
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Status Pengumpulan',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (sudahDikumpulkan) ...[
                                  (statusPengumpulan == 'Terlambat')
                                      ? Icon(
                                          Symbols.check_circle,
                                          size: 16,
                                          color: Colors.red,
                                        )
                                      : Icon(
                                          Symbols.check_circle,
                                          size: 16,
                                          color: Colors.green,
                                        ),
                                ],
                                if (!sudahDikumpulkan)
                                  Icon(
                                    Symbols.pending,
                                    size: 16,
                                    color: Colors.orange,
                                  ),
                                const SizedBox(width: 6),
                                if (sudahDikumpulkan) ...[
                                  (statusPengumpulan == 'Terlambat')
                                      ? Text(
                                          'Terlambat',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red,
                                          ),
                                        )
                                      : Text(
                                          'Tepat Waktu',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green,
                                          ),
                                        ),
                                ],
                                if (!sudahDikumpulkan)
                                  Text(
                                    "Belum Mengumpulkan",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Bagian kanan: Button aksi atau nilai
                      sudahDikumpulkan
                          ? Text('Nilai : $nilaiTugas')
                          : SizedBox(
                              width: 200,
                              child: MainButtonWidget(
                                btnAction: _handlePengumpulanTugas,
                                btnTitle: "Kumpulkan Tugas",
                                disabled: false,
                              ),
                            ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  // Widget untuk bagian detail tugas (digunakan di kedua layout)
  Widget _buildDetailTugasSection(TugasKelas tugas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Symbols.book, size: 20),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                tugas.judulTugas,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(tugas.lingkupMateri),
            const Icon(Symbols.circle, fill: 1, size: 5),
            Text("Deadline : ${tugas.tanggalDeadline}"),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(color: Colors.grey, thickness: 0.2),
        const SizedBox(height: 20),
        Text(
          tugas.deskripsiTugas,
          softWrap: true,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 20),
        const Divider(color: Colors.grey, thickness: 0.2),
        if (tugas.fileTugas.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'File Tugas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 4.5,
            ),
            itemCount: tugas.fileTugas.length,
            itemBuilder: (context, index) {
              final file = tugas.fileTugas[index];
              final fileName = _getFileNameFromUrl(
                file['link_file_tugas'] ?? '',
              );
              final fileIcon = _getFileIcon(fileName);
              final isDownloading =
                  _isDownloading && _downloadingIndex == index;

              return Card(
                color: Colors.white,
                elevation: 2,
                child: InkWell(
                  onTap: isDownloading
                      ? null
                      : () =>
                            _previewFile(file['link_file_tugas'] ?? '', index),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        if (isDownloading)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Icon(fileIcon, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                fileName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isDownloading
                                    ? 'Membuka...'
                                    : 'Tap untuk preview',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDownloading
                                      ? Colors.blue
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isDownloading)
                          const Icon(Symbols.chevron_right, size: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  // Widget untuk bagian pengumpulan tugas
  Widget _buildPengumpulanTugasSection(TugasKelas tugas, bool isSmallScreen) {
    final fileList = tugas.filePengumpulanTugas;

    return SizedBox(
      width: isSmallScreen ? double.infinity : 350,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize:
              MainAxisSize.min, // Pastikan tidak ada constraints unbounded
          children: [
            Text(
              "Pengumpulan Tugas",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 🔹 Area file pengumpulan tugas
            fileList.isNotEmpty
                ? SizedBox(
                    // height: 300,
                    height: !isSmallScreen ? 300 : null,
                    // height:
                    //     fileList.length > 2
                    //         ? 250
                    //         : null,
                    // Berikan height tetap jika banyak file
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: fileList.length,
                      itemBuilder: (context, index) {
                        final file = fileList[index];
                        final fileName = _getFileNameFromUrl(
                          file['link_file'] ?? '',
                        );
                        final fileIcon = _getFileIcon(fileName);
                        final isDownloading =
                            _isDownloading && _downloadingIndex == index;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            color: Colors.white,
                            elevation: 2,
                            child: InkWell(
                              onTap: isDownloading
                                  ? null
                                  : () => _previewFile(
                                      file['link_file'] ?? '',
                                      index,
                                    ),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    if (isDownloading)
                                      const SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    else
                                      Icon(fileIcon, size: 32),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            fileName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            isDownloading
                                                ? 'Membuka...'
                                                : 'Tap untuk preview',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDownloading
                                                  ? Colors.blue
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isDownloading)
                                      const Icon(
                                        Symbols.chevron_right,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        "Anda belum mengumpulkan.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

            const SizedBox(height: 20),

            // Tombol Ubah Pengumpulan
            if (sudahDikumpulkan)
              Center(
                child: Row(
                  children: [
                    Expanded(
                      child: MainButtonWidget(
                        btnAction: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final kelasMapelId = prefs.getInt('kelasMapelId');

                          await prefs.setString(
                            'tanggalDeadline',
                            tugas.tanggalDeadline,
                          );

                          // ignore: use_build_context_synchronously
                          context.go(
                           RoutesNames.editTugasSiswa
                          );
                        },
                        btnTitle: "Ubah Pengumpulan",
                        disabled: (nilaiTugas == 0) ? false : true,
                      ),
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

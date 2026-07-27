// ignore_for_file: avoid_print
import 'dart:io';

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

import '../../../../../models/siswa/materi_kelas_model.dart';
import '../../../../controllers/siswa/materi/materi_kelas_riverpod.dart';
import 'widget/komentar_materi_widget.dart';

class DetailMateriSiswaScreen extends ConsumerStatefulWidget {
  const DetailMateriSiswaScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DetailMateriSiswaScreenState();
}

class _DetailMateriSiswaScreenState extends ConsumerState<DetailMateriSiswaScreen> {
  List<MateriKelas> detailMateriList = [];
  bool isLoading = true;
  TextEditingController komentarController = TextEditingController();
  bool _isDownloading = false;
  int? _downloadingIndex;

  @override
  void initState() {
    super.initState();
    _loadDetailMateri();
    _checkPendingRoute();
  }

  // di dalam _DetailMateriSiswaScreenState
  Future<void> _checkPendingRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingRoute = prefs.getString('pendingRoute');

    if (pendingRoute != null) {
      // Hapus pending route setelah diproses
      await prefs.remove('pendingRoute');

      // Jika route mengandung '/detail-materi', kita sudah di halaman yang benar
      if (pendingRoute.contains('/detail-materi')) {
        // Refresh data jika perlu
        await _loadDetailMateri();
      } else {
        // Jika route berbeda, lakukan navigasi
        // Anda perlu menyesuaikan dengan routing structure Anda
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go(pendingRoute);
          }
        });
      }
    }
  }

  Future<void> _loadDetailMateri() async {
    final prefs = await SharedPreferences.getInstance();
    final materiId = prefs.getInt('materiId');

    if (materiId == null) {
      setState(() => isLoading = false);
      return;
    }

    final list = await ref
        .read(materiKelasRiverpodProvider.notifier)
        .getDetailMateri(materiId: materiId);

    if (!mounted) return;

    setState(() {
      detailMateriList = list;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: _buildBody());
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (detailMateriList.isEmpty) {
      return const Center(child: Text('Tidak ada materi ditemukan.'));
    }

    final materi = detailMateriList.first;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isLargeScreen = screenWidth > 900;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLargeScreen
                ? _buildLargeScreenLayout(materi, constraints)
                : _buildSmallScreenLayout(materi),
          ),
        );
      },
    );
  }

  Widget _buildLargeScreenLayout(
    MateriKelas materi,
    BoxConstraints constraints,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Konten materi - Flexible agar bisa scroll
        Flexible(
          flex: 2,
          child: SingleChildScrollView(child: _buildMateriContent(materi)),
        ),
        const SizedBox(width: 20),
        // Komentar Widget
        Flexible(flex: 1, child: KomentarMateriWidget(isExpanded: true)),
      ],
    );
  }

  Widget _buildSmallScreenLayout(MateriKelas materi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Konten materi
        _buildMateriContent(materi),
        const SizedBox(height: 20),
        // Komentar Widget
        KomentarMateriWidget(isExpanded: false),
      ],
    );
  }

  Widget _buildMateriContent(MateriKelas materi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Symbols.book, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                materi.judulMateri,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(materi.lingkupMateri),
            const Icon(Symbols.circle, fill: 1, size: 5),
            Text(materi.tanggalDibuat),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(color: Colors.grey, thickness: 0.2),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xffF8FAFC),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Text(
            materi.deskripsiMateri,
            softWrap: true,
            textAlign: TextAlign.justify,
          ),
        ),
        const SizedBox(height: 20),
        const Divider(color: Colors.grey, thickness: 0.2),
        // Tampilkan File Materi dalam Card
        if (materi.fileMateri.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'File Materi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 4.5,
            ),
            itemCount: materi.fileMateri.length,
            itemBuilder: (context, index) {
              final file = materi.fileMateri[index];
              final fileName = _getFileNameFromUrl(
                file['link_file_materi'] ?? '',
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
                            _previewFile(file['link_file_materi'] ?? '', index),
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
                          Row(children: [Icon(fileIcon, size: 24)]),
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
}

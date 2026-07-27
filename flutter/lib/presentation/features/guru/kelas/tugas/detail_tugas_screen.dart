// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

import '../../../../../models/guru/tugas_kelas_model.dart';
import '../../../../controllers/guru/daftar_pengumpulan_tugas/daftar_pengumpulan_tugas_riverpod.dart';
import '../../../../controllers/guru/tugas/tugas_kelas_riverpod.dart';
import '../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../shared_widgets/general_old/header2_widget.dart';
import '../../../../shared_widgets/general_old/search_textfield_widget.dart';
import 'widget/list_card_pengumpulan_tugas_widget.dart';

class DetailTugasScreen extends ConsumerStatefulWidget {
  const DetailTugasScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DetailTugasScreenState();
}

class _DetailTugasScreenState extends ConsumerState<DetailTugasScreen> {
  List<TugasKelas> detailTugasList = [];
  bool isLoading = true;
  TextEditingController komentarController = TextEditingController();
  bool _isDownloading = false;
  bool isLoadingPengumpulan = true; // ✅ Tambahkan state loading terpisah
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

    await ref
        .read(daftarPengumpulanTugasRiverpodProvider.notifier)
        .resetAndFetch();

    if (!mounted) return;

    setState(() {
      detailTugasList = list;
      isLoading = false;
      isLoadingPengumpulan = false;
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
    final pengumpulanTugasState = ref.watch(
      daftarPengumpulanTugasRiverpodProvider,
    );
    final notifier = ref.read(daftarPengumpulanTugasRiverpodProvider.notifier);

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

          return Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                                : () => _previewFile(
                                    file['link_file_tugas'] ?? '',
                                    index,
                                  ),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  if (isDownloading)
                                    const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  else
                                    Icon(fileIcon, size: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                    const Divider(color: Colors.grey, thickness: 0.2),
                    const SizedBox(height: 20),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: Container(
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
                              Header2Widget(
                                header2Title: "Pengumpulan Tugas",
                                subtitle: "Daftar pengumpulan tugas",
                              ),
                              SizedBox(height: 10),
                              SearchTextFieldWidget(
                                hintText: "Cari berdasarkan nama siswa",
                                onChangedSearch: (value) {},
                              ),
                              SizedBox(height: 15),
                              pengumpulanTugasState.when(
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (err, _) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    final errorMsg =
                                        err.toString().contains(
                                          "PostgrestException",
                                        )
                                        ? err
                                              .toString()
                                              .split("message:")
                                              .last
                                              .split(",")
                                              .first
                                              .trim()
                                        : err.toString();

                                    showDialog(
                                      context: context,
                                      builder: (context) => DialogErrorWidget(
                                        errorText: 'Error : $errorMsg',
                                      ),
                                    );
                                  });

                                  // tampilkan tabel dari cache data terakhir, bukan kosong
                                  final cachedData = ref
                                      .read(
                                        daftarPengumpulanTugasRiverpodProvider
                                            .notifier,
                                      )
                                      .daftarPengumpulanTugasList;

                                  return ListCardPengumpulanTugasWidget(
                                    daftarPengumpulanTugas: cachedData,
                                  );
                                },
                                data: (pengumpulanTugasList) {
                                  print(
                                    "✅ Data state di UI - items: ${pengumpulanTugasList.length}",
                                  );
                                  if (isLoadingPengumpulan) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListCardPengumpulanTugasWidget(
                                          daftarPengumpulanTugas:
                                              pengumpulanTugasList,
                                        ),
                                        if (notifier.hasMore &&
                                            !notifier.isLoadingMore &&
                                            pengumpulanTugasList.isNotEmpty)
                                          Center(
                                            child: SizedBox(
                                              height: 40,
                                              width: 40,
                                              child: FloatingActionButton(
                                                backgroundColor: const Color(
                                                  0xff016EB3,
                                                ),
                                                onPressed: () => ref
                                                    .read(
                                                      daftarPengumpulanTugasRiverpodProvider
                                                          .notifier,
                                                    )
                                                    .loadMore(),
                                                // mini: true,
                                                shape: const CircleBorder(),
                                                child: Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget untuk bagian detail tugas (digunakan di kedua layout)
  // Widget _buildDetailTugasSection(TugasKelas tugas) {
  //   final pengumpulanTugasState = ref.watch(
  //     daftarPengumpulanTugasRiverpodProvider,
  //   );
  //   final notifier = ref.read(daftarPengumpulanTugasRiverpodProvider.notifier);

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         children: [
  //           const Icon(Symbols.book, size: 20),
  //           const SizedBox(width: 20),
  //           Expanded(
  //             child: Text(
  //               tugas.judulTugas,
  //               style: const TextStyle(
  //                 fontSize: 24,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 20),
  //       Wrap(
  //         spacing: 10,
  //         crossAxisAlignment: WrapCrossAlignment.center,
  //         children: [
  //           Text(tugas.lingkupMateri),
  //           const Icon(Symbols.circle, fill: 1, size: 5),
  //           Text("Deadline : ${tugas.tanggalDeadline}"),
  //         ],
  //       ),
  //       const SizedBox(height: 20),
  //       const Divider(color: Colors.grey, thickness: 0.2),
  //       const SizedBox(height: 20),
  //       Text(
  //         tugas.deskripsiTugas,
  //         softWrap: true,
  //         textAlign: TextAlign.justify,
  //       ),
  //       const SizedBox(height: 20),
  //       const Divider(color: Colors.grey, thickness: 0.2),
  //       if (tugas.fileTugas.isNotEmpty) ...[
  //         const SizedBox(height: 20),
  //         const Text(
  //           'File Tugas',
  //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //         ),
  //         const SizedBox(height: 10),
  //         GridView.builder(
  //           shrinkWrap: true,
  //           physics: const NeverScrollableScrollPhysics(),
  //           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //             crossAxisCount: 2,
  //             crossAxisSpacing: 12,
  //             mainAxisSpacing: 12,
  //             childAspectRatio: 4.5,
  //           ),
  //           itemCount: tugas.fileTugas.length,
  //           itemBuilder: (context, index) {
  //             final file = tugas.fileTugas[index];
  //             final fileName = _getFileNameFromUrl(
  //               file['link_file_tugas'] ?? '',
  //             );
  //             final fileIcon = _getFileIcon(fileName);
  //             final isDownloading =
  //                 _isDownloading && _downloadingIndex == index;

  //             return Card(
  //               color: Colors.white,
  //               elevation: 2,
  //               child: InkWell(
  //                 onTap:
  //                     isDownloading
  //                         ? null
  //                         : () => _previewFile(
  //                           file['link_file_tugas'] ?? '',
  //                           index,
  //                         ),
  //                 borderRadius: BorderRadius.circular(8),
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(12),
  //                   child: Row(
  //                     children: [
  //                       if (isDownloading)
  //                         const SizedBox(
  //                           width: 24,
  //                           height: 24,
  //                           child: CircularProgressIndicator(strokeWidth: 2),
  //                         )
  //                       else
  //                         Icon(fileIcon, size: 24),
  //                       const SizedBox(width: 12),
  //                       Expanded(
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: [
  //                             Text(
  //                               fileName,
  //                               style: const TextStyle(
  //                                 fontSize: 12,
  //                                 fontWeight: FontWeight.w500,
  //                               ),
  //                               overflow: TextOverflow.ellipsis,
  //                               maxLines: 1,
  //                             ),
  //                             const SizedBox(height: 4),
  //                             Text(
  //                               isDownloading
  //                                   ? 'Membuka...'
  //                                   : 'Tap untuk preview',
  //                               style: TextStyle(
  //                                 fontSize: 10,
  //                                 color:
  //                                     isDownloading
  //                                         ? Colors.blue
  //                                         : Colors.grey[600],
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       if (!isDownloading)
  //                         const Icon(Symbols.chevron_right, size: 16),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //         const SizedBox(height: 20),
  //       ],
  //       const SizedBox(height: 20),
  //       const Divider(color: Colors.grey, thickness: 0.2),
  //       const SizedBox(height: 20),
  //       Row(
  //         children: [
  //           Expanded(
  //             child: Container(
  //               padding: EdgeInsets.all(20),
  //               decoration: BoxDecoration(
  //                 border: Border.all(
  //                   color: Colors.grey[200]!, // warna border
  //                   width: 1, // ketebalan border
  //                 ),
  //                 borderRadius: BorderRadius.circular(
  //                   8,
  //                 ), // opsional kalau mau rounded
  //               ),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Header2Widget(
  //                     header2Title: "Pengumpulan Tugas",
  //                     subtitle: "Daftar pengumpulan tugas",
  //                   ),
  //                   SizedBox(height: 10),
  //                   SearchTextFieldWidget(
  //                     hintText: "Cari berdasarkan nama siswa",
  //                     onChangedSearch: (value) {},
  //                   ),
  //                   SizedBox(height: 15),
  //                   pengumpulanTugasState.when(
  //                     loading:
  //                         () =>
  //                             const Center(child: CircularProgressIndicator()),
  //                     error: (err, _) {
  //                       WidgetsBinding.instance.addPostFrameCallback((_) {
  //                         final errorMsg =
  //                             err.toString().contains("PostgrestException")
  //                                 ? err
  //                                     .toString()
  //                                     .split("message:")
  //                                     .last
  //                                     .split(",")
  //                                     .first
  //                                     .trim()
  //                                 : err.toString();

  //                         showDialog(
  //                           context: context,
  //                           builder:
  //                               (context) => DialogErrorWidget(
  //                                 errorText: 'Error : $errorMsg',
  //                               ),
  //                         );
  //                       });

  //                       // tampilkan tabel dari cache data terakhir, bukan kosong
  //                       final cachedData =
  //                           ref
  //                               .read(
  //                                 daftarPengumpulanTugasRiverpodProvider
  //                                     .notifier,
  //                               )
  //                               .daftarPengumpulanTugasList;

  //                       return ListCardPengumpulanTugasWidget(
  //                         daftarPengumpulanTugas: cachedData,
  //                       );
  //                     },
  //                     data: (pengumpulanTugasList) {
  //                       print(
  //                         "✅ Data state di UI - items: ${pengumpulanTugasList.length}",
  //                       );
  //                       if (isLoadingPengumpulan) {
  //                         return const Center(
  //                           child: CircularProgressIndicator(),
  //                         );
  //                       } else {
  //                         return Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             ListCardPengumpulanTugasWidget(
  //                               daftarPengumpulanTugas: pengumpulanTugasList,
  //                             ),
  //                             if (notifier.hasMore &&
  //                                 !notifier.isLoadingMore &&
  //                                 pengumpulanTugasList.isNotEmpty)
  //                               Center(
  //                                 child: SizedBox(
  //                                   height: 40,
  //                                   width: 40,
  //                                   child: FloatingActionButton(
  //                                     backgroundColor: const Color(0xff016EB3),
  //                                     onPressed:
  //                                         () =>
  //                                             ref
  //                                                 .read(
  //                                                   daftarPengumpulanTugasRiverpodProvider
  //                                                       .notifier,
  //                                                 )
  //                                                 .loadMore(),
  //                                     // mini: true,
  //                                     shape: const CircleBorder(),
  //                                     child: Icon(
  //                                       Icons.add,
  //                                       color: Colors.white,
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                           ],
  //                         );
  //                       }
  //                     },
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );

  // }
}

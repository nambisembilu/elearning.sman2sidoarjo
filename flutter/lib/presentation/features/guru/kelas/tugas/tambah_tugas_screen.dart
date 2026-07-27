// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:universal_html/html.dart' as html;

import '../../../../../models/guru/filtering_model.dart';
import '../../../../controllers/guru/tugas/tugas_kelas_riverpod.dart';
import '../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../../../shared_widgets/general_old/dropdown2_widget.dart';
import '../../../../shared_widgets/general_old/file_textfield_widget.dart';
import '../../../../shared_widgets/general_old/header2_widget.dart';
import '../../../../shared_widgets/general_old/rich_textfield_widget.dart';
import '../../../../shared_widgets/general_old/textfield2_widget.dart';

class TambahTugasScreen extends ConsumerStatefulWidget {
  const TambahTugasScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TambahTugasScreenState();
}

class _TambahTugasScreenState extends ConsumerState<TambahTugasScreen> {
  final _formKey = GlobalKey<FormState>();

  // final quillFieldKey = GlobalKey<QuillTextfiledWidgetState>();
  // late quill.QuillController _tugasController;

  final TextEditingController judulController = TextEditingController();
  final TextEditingController jmlPengumpulan = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  String? selectedLingkupMateri;
  String? selectedTujuanPembelajaran;
  // String? selectedTipeTugas;
  String? selectedStatusTugas;
  int? selectedLingkupMateriId;
  int? selectedTujuanPembelajaranId;
  DateTime? selectedDeadline;

  List<PlatformFile> pickedFiles = [];
  List<LingkupMateri> lingkupMateriList = [];
  List<Map<String, dynamic>> tujuanPembelajaranList = [];

  bool isSubmitted = false;

  @override
  void initState() {
    super.initState();
    // _tugasController = quill.QuillController.basic();

    Future.microtask(() async {
      final list = await ref
          .read(tugasKelasRiverpodProvider.notifier)
          .fetchLingkupMateri();

      if (!mounted) return;
      setState(() {
        lingkupMateriList = list;
      });
    });
  }

  @override
  void dispose() {
    judulController.dispose();
    super.dispose();
  }

  String formatDateTime(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00";
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
                          header2Title: "Tambah Penugasan Baru",
                          subtitle:
                              "Lengkapi form berikut untuk menambahkan tugas.",
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
                                hintText: "Masukkan judul Tugas",
                                pController: judulController,
                                isRequired: true,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Dropdown2GeneralWidget(
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
                                              .firstWhere(
                                                (e) => e.judulLM == value,
                                              );
                                          selectedLingkupMateriId =
                                              selectedObj.lingkupMateriId;

                                          // Ambil tujuan dari item yang dipilih
                                          tujuanPembelajaranList =
                                              selectedObj.tujuanPembelajaran;
                                          selectedTujuanPembelajaran = null;
                                          selectedTujuanPembelajaranId = null;
                                        });
                                      },
                                      isRequired: true,
                                      isSubmitted: isSubmitted,
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: Dropdown2GeneralWidget(
                                      pTitle: "Tujuan Pembelajaran",
                                      pHintText: "Pilih tujuan pembelajaran",
                                      valueParams: selectedTujuanPembelajaran,
                                      pItems: tujuanPembelajaranList
                                          .map((e) => e['judul'] as String)
                                          .toList(),
                                      pOnChanged: (value) {
                                        setState(() {
                                          selectedTujuanPembelajaran = value;

                                          final selectedTP =
                                              tujuanPembelajaranList.firstWhere(
                                                (e) => e['judul'] == value,
                                              );

                                          selectedTujuanPembelajaranId =
                                              selectedTP['id']; // kalau butuh id
                                        });
                                      },
                                      isRequired: true,
                                      isSubmitted: isSubmitted,
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Deadline Tugas *",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          width: double.infinity,
                                          // padding: EdgeInsets.symmetric(
                                          //   horizontal: 10,
                                          //   vertical: 10,
                                          // ),
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
                                                      ? "${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year} ${selectedDeadline!.hour}:${selectedDeadline!.minute.toString().padLeft(2, '0')}"
                                                      : "Pilih tanggal dan waktu",
                                                  style: TextStyle(
                                                    fontSize: 12,
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
                                                  size: 16,
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Expanded(
                                  //   child:
                                  // Dropdown2GeneralWidget(
                                  //   pTitle: "Tipe Tugas",
                                  //   pHintText: "Pilih tipe tugas",
                                  //   valueParams: selectedTipeTugas,
                                  //   pItems: ['Individu', 'Kelompok'],
                                  //   pOnChanged: (value) {
                                  //     setState(() {
                                  //       selectedTipeTugas = value;
                                  //     });
                                  //   },
                                  //   isRequired: true,
                                  //   isSubmitted: isSubmitted,
                                  // ),
                                  // ),
                                  // SizedBox(width: 20),
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
                                  //     pController: jmlPengumpulan,
                                  //     isRequired: true,
                                  //   ),
                                  // ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // QuillTextfiledWidget(
                              //   key: quillFieldKey,
                              //   textController: _tugasController,
                              //   isRequired: true,
                              // ),
                              RichTextFieldGeneralWidget(
                                title: "Deskripsi Tugas",
                                hintText: "Masukkan deskripsi tugas",
                                p_controller: deskripsiController,
                                isRequired: true,
                                pMinLines: 10,
                              ),
                              const SizedBox(height: 20),
                              FileTextFieldWidget(
                                addFileAction: _pilihFile,
                                title: 'Pilih File',
                              ),
                              const SizedBox(height: 20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                              const SizedBox(height: 10),
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
                                          // jmlPengumpulan.text.trim().isEmpty ||
                                          deskripsiController.text
                                              .trim()
                                              .isEmpty ||
                                          // _tugasController.document
                                          //     .toPlainText()
                                          //     .trim()
                                          //     .isEmpty ||
                                          // !isMateriValid ||
                                          selectedLingkupMateriId == null ||
                                          selectedTujuanPembelajaranId ==
                                              null ||
                                          // selectedTipeTugas == null ||
                                          selectedStatusTugas == null ||
                                          selectedDeadline == null) {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              const DialogErrorWidget(
                                                errorText:
                                                    "Semua field harus diisi dan pilih minimal 1 mata pelajaran",
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

                                          // ✅ Simpan rich text Quill dalam format Delta JSON
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
                                              .addTugas(
                                                judul: judulController.text,
                                                // deskripsi: deskripsiJson,
                                                deskripsi:
                                                    deskripsiController.text,
                                                fileBytes: fileBytes,
                                                fileNames: fileNames,
                                                tujuanPembelajaranId:
                                                    selectedTujuanPembelajaranId!,
                                                // tolong ganti biar jadi timestamp saat dikirim ke database
                                                deadline: formatDateTime(
                                                  selectedDeadline!,
                                                ), // Format di sini
                                                // tipeTugas: selectedTipeTugas!,
                                                statusTugas:
                                                    selectedStatusTugas!,
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
                                                        'Tugas berhasil ditambahkan',
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
                                      'Unggah Tugas',
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

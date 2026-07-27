// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../models/guru/rubrik_mapel_sementara_model.dart';
import '../../../controllers/guru/rubrik_mapel/rubrik_mapel_riverpod.dart';
import '../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../../shared_widgets/general_old/header2_widget.dart';
import '../../../shared_widgets/general_old/main_button_widget.dart';
import '../../../shared_widgets/general_old/textfield_3_widget.dart';
import '../../../shared_widgets/general_old/textfield_horizontal_widget.dart';

class KelolaRubrikScreen extends ConsumerStatefulWidget {
  const KelolaRubrikScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _KelolaRubrikScreenState();
}

class _KelolaRubrikScreenState extends ConsumerState<KelolaRubrikScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isNew = true;

  // Data rubrik disimpan secara lokal
  final List<RubrikItem> _rubrikSementara = [];
  int _currentIndex = 0;
  bool isSubmitted = false;

  // Getter methods
  int get totalRubrik => _rubrikSementara.length;
  bool get hasPrevious => _currentIndex > 0;
  bool get hasNext => _currentIndex < _rubrikSementara.length - 1;
  bool get isLast => _currentIndex == _rubrikSementara.length - 1;
  RubrikItem? get currentRubrik {
    if (_currentIndex < 0 || _currentIndex >= _rubrikSementara.length) {
      return null;
    }
    return _rubrikSementara[_currentIndex];
  }

  final TextEditingController judulLMcontroller = TextEditingController();
  final TextEditingController deskripsiTPcontroller = TextEditingController();
  final TextEditingController perluBimbinganController =
      TextEditingController();
  final TextEditingController cukupController = TextEditingController();
  final TextEditingController baikController = TextEditingController();
  final TextEditingController sangatBaikController = TextEditingController();

  List<TujuanPembelajaran> _tujuanPembelajaranList = [];

  @override
  void initState() {
    super.initState();
    _initializeFirstTP();
    _getStatusKelola();
    _loadCurrentRubrik(); // Load data saat init
  }

  void _initializeFirstTP() {
    _tujuanPembelajaranList.add(
      TujuanPembelajaran(
        idTpTemp: DateTime.now().millisecondsSinceEpoch,
        deskripsi: '',
        perluBimbingan: '',
        cukup: '',
        baik: '',
        sangatBaik: '',
      ),
    );
  }

  Future<void> _getStatusKelola() async {
    final prefs = await SharedPreferences.getInstance();
    final isNewRubrik = prefs.getBool('isNewRubrik');

    if (isNewRubrik != null) {
      setState(() {
        isNew = isNewRubrik;
      });
    }
  }

  void _addTujuanPembelajaran() {
    setState(() {
      _tujuanPembelajaranList.add(
        TujuanPembelajaran(
          idTpTemp: DateTime.now().millisecondsSinceEpoch,
          deskripsi: '',
          perluBimbingan: '',
          cukup: '',
          baik: '',
          sangatBaik: '',
        ),
      );
    });
  }

  void _updateTujuanPembelajaran(int index, TujuanPembelajaran tp) {
    setState(() {
      _tujuanPembelajaranList[index] = tp;
    });
  }

  // Method untuk menambah rubrik item
  void _addRubrikItem(RubrikItem item) {
    setState(() {
      _rubrikSementara.add(item);
      _currentIndex = _rubrikSementara.length - 1;
    });
    print('✅ Rubrik ditambahkan. Total sekarang: ${_rubrikSementara.length}');
  }

  // Method untuk update rubrik current
  void _updateCurrentRubrik(RubrikItem updatedItem) {
    if (_currentIndex >= 0 && _currentIndex < _rubrikSementara.length) {
      setState(() {
        _rubrikSementara[_currentIndex] = updatedItem;
      });
      print('✅ Rubrik index $_currentIndex diupdate');
    } else {
      print('⚠️ Tidak bisa update: currentIndex $_currentIndex diluar range');
    }
  }

  void _saveCurrentRubrik() {
    // Validasi data
    if (judulLMcontroller.text.trim().isEmpty) {
      print('❌ Lingkup materi tidak boleh kosong');
      return;
    }

    // Validasi: pastikan minimal ada 1 TP dengan deskripsi
    bool hasValidTP = false;
    for (final tp in _tujuanPembelajaranList) {
      if (tp.deskripsi.trim().isNotEmpty) {
        hasValidTP = true;
        break;
      }
    }

    if (!hasValidTP) {
      print('❌ Minimal harus ada 1 Tujuan Pembelajaran dengan deskripsi');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Minimal harus ada 1 Tujuan Pembelajaran dengan deskripsi',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Buat rubrik item baru
    final rubrikItem = RubrikItem(
      idTemp: DateTime.now().millisecondsSinceEpoch,
      lingkupMateri: judulLMcontroller.text.trim(),
      tujuanPembelajaran: List<TujuanPembelajaran>.from(
        _tujuanPembelajaranList,
      ),
    );

    // Perbaiki logika pengecekan index
    if (_currentIndex >= 0 && _currentIndex < totalRubrik) {
      // Update rubrik yang sudah ada
      _updateCurrentRubrik(rubrikItem);
      print('✏️ Rubrik existing diupdate di index $_currentIndex');
    } else {
      // Tambah rubrik baru (baik index = -1 atau index >= totalRubrik)
      _addRubrikItem(rubrikItem);
      print('🆕 Rubrik baru ditambahkan. Total: ${totalRubrik + 1}');
    }
  }

  void _loadCurrentRubrik() {
    print('📥 Loading rubrik index: $_currentIndex');

    if (currentRubrik != null) {
      // Load data dari rubrik yang dipilih
      judulLMcontroller.text = currentRubrik!.lingkupMateri;
      _tujuanPembelajaranList = List<TujuanPembelajaran>.from(
        currentRubrik!.tujuanPembelajaran,
      );

      // Update controllers untuk semua TP
      _updateControllersFromTPList();
    } else {
      // Reset form untuk rubrik baru
      _resetForm();
      print('🆕 Form direset untuk rubrik baru');
    }

    setState(() {});
  }

  void _updateControllersFromTPList() {
    // Reset semua controller
    deskripsiTPcontroller.clear();
    perluBimbinganController.clear();
    cukupController.clear();
    baikController.clear();
    sangatBaikController.clear();

    // Update dengan data TP pertama (jika ada)
    if (_tujuanPembelajaranList.isNotEmpty) {
      final firstTp = _tujuanPembelajaranList[0];
      deskripsiTPcontroller.text = firstTp.deskripsi;
      perluBimbinganController.text = firstTp.perluBimbingan;
      cukupController.text = firstTp.cukup;
      baikController.text = firstTp.baik;
      sangatBaikController.text = firstTp.sangatBaik;
    }
  }

  void _resetForm() {
    judulLMcontroller.clear();
    _tujuanPembelajaranList.clear();
    _initializeFirstTP();
    _updateControllersFromTPList();

    // Pastikan UI update
    if (mounted) {
      setState(() {});
    }
  }

  void _goToPrevious() {
    if (hasPrevious) {
      // Simpan perubahan di rubrik current
      _saveCurrentRubrik();

      // Pindah ke rubrik sebelumnya
      setState(() {
        _currentIndex--;
      });

      // Load data rubrik yang baru
      _loadCurrentRubrik();

      print('⬅️ Navigasi ke rubrik ${_currentIndex + 1}');
    }
  }

  void _goToNext() {
    if (hasNext) {
      // Simpan perubahan di rubrik current
      _saveCurrentRubrik();

      // Pindah ke rubrik berikutnya
      setState(() {
        _currentIndex++;
      });

      // Load data rubrik yang baru
      _loadCurrentRubrik();

      print('➡️ Navigasi ke rubrik ${_currentIndex + 1}');
    }
  }

  void _addLingkupMateri() {
    // Validasi sebelum menyimpan
    if (judulLMcontroller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lingkup materi tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Simpan rubrik yang sedang diedit
    _saveCurrentRubrik();

    // Reset form untuk rubrik baru
    _resetForm();

    // Set current index ke rubrik baru (yang akan dibuat)
    setState(() {
      _currentIndex =
          _rubrikSementara.length; // Set ke index setelah yang terakhir
    });

    print('🔄 Form direset untuk rubrik baru');
    print('   Total rubrik sekarang: ${_rubrikSementara.length}');
    print('   Current index: $_currentIndex');
    print('   data temp : $_rubrikSementara');

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(
    //       'Lingkup materi berhasil disimpan. Silakan tambah yang baru.',
    //     ),
    //     backgroundColor: Colors.green,
    //   ),
    // );
  }

  void _printLingkupMateriSementara() {
    print('\n=== DEBUG STATE RUBRIK ===');
    print('Total Rubrik: ${_rubrikSementara.length}');
    print('Current Index: $_currentIndex');
    print('Has Previous: $hasPrevious');
    print('Has Next: $hasNext');
    print('===========================\n');

    print('=== LINGKUP MATERI YANG SUDAH DITAMBAHKAN ===');
    print('Total Lingkup Materi: ${_rubrikSementara.length}');
    print('==============================================');

    if (_rubrikSementara.isEmpty) {
      print('❌ Belum ada lingkup materi yang ditambahkan');
      return;
    }

    for (int i = 0; i < _rubrikSementara.length; i++) {
      final rubrik = _rubrikSementara[i];
      final isCurrent = i == _currentIndex;
      print('${isCurrent ? '➡️' : '  '} ${i + 1}. "${rubrik.lingkupMateri}"');
      print('      ID: ${rubrik.idTemp}');
      print('      Jumlah TP: ${rubrik.tujuanPembelajaran.length}');

      for (int j = 0; j < rubrik.tujuanPembelajaran.length; j++) {
        final tp = rubrik.tujuanPembelajaran[j];
        final deskripsiSingkat = tp.deskripsi.length > 30
            ? '${tp.deskripsi.substring(0, 30)}...'
            : tp.deskripsi;
        print('      - TP ${j + 1}: $deskripsiSingkat');
      }

      print(''); // Spasi antar rubrik
    }

    // Tampilkan summary
    final totalTP = _rubrikSementara.fold(
      0,
      (sum, rubrik) => sum + rubrik.tujuanPembelajaran.length,
    );
    print('SUMMARY:');
    print('- Total Lingkup Materi: ${_rubrikSementara.length}');
    print('- Total Tujuan Pembelajaran: $totalTP');

    // Print JSON
    print('\n=== FORMAT JSON ===');
    try {
      final jsonData = _rubrikSementara.map((item) => item.toJson()).toList();
      final jsonString = JsonEncoder.withIndent('  ').convert(jsonData);
      print(jsonString);
    } catch (e) {
      print('Error converting to JSON: $e');
    }
    print('====================================\n');
  }

  void _unggahRubrik() async {
    // Simpan rubrik yang sedang diedit
    _saveCurrentRubrik();

    // Print data untuk debugging
    _printLingkupMateriSementara();

    print('🚀 Mengunggah ${_rubrikSementara.length} rubrik ke server');

    // Tampilkan snackbar konfirmasi
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(
    //       '${_rubrikSementara.length} lingkup materi siap diunggah',
    //     ),
    //     backgroundColor: Colors.green,
    //   ),
    // );

    setState(() {
      isSubmitted = true;
    });

    final isValid = _formKey.currentState!.validate();

    if (_rubrikSementara.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const DialogErrorWidget(
          errorText: "Data rubrik mata pelajaran belum lengkap",
        ),
      );

      return;
    }

    if (isValid) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final success = await ref
            .read(rubrikMapelRiverpodProvider.notifier)
            .addNewRubrikMapel(rubrikJson: _rubrikSementara);

        // Tutup loading indicator dengan rootNavigator
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (success) {
          if (!mounted) return;

          // Tampilkan dialog sukses
          await showDialog(
            context: context,
            builder: (context) => DialogSuccessWidget(
              succesText: 'Rubrik mata pelajaran berhasil ditambahkan',
            ),
          );

          if (!mounted) return;
          context.pop();
        }
      } catch (e) {
        // Tutup loading indicator jika error
        // Tutup loading indicator dengan rootNavigator
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }

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
  }

  @override
  Widget build(BuildContext context) {
    final isEditingNew = _currentIndex == _rubrikSementara.length;
    final displayIndex = isEditingNew
        ? _rubrikSementara.length + 1
        : _currentIndex + 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Header2Widget(
                          header2Title: isNew
                              ? 'Tambah Rubrik Mata Pelajaran'
                              : 'Perbarui Rubrik Mata Pelajaran',
                          subtitle:
                              'Lengkapi form berikut untuk menambahkan rubrik mata pelajaran baru',
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Textfield3Widget(
                                title: 'Lingkup Materi - $displayIndex',
                                hintText: "Masukkan judul lingkup materi",
                                pController: judulLMcontroller,
                                isRequired: false,
                                onChanged: (value) {
                                  // Optional: real-time update jika diperlukan
                                },
                              ),
                              const SizedBox(height: 20),

                              // List Tujuan Pembelajaran
                              ..._tujuanPembelajaranList.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final tp = entry.value;

                                return _buildTujuanPembelajaranSection(
                                  index,
                                  tp,
                                );
                              }),

                              const SizedBox(height: 20),
                              MainButtonWidget(
                                btnAction: _addTujuanPembelajaran,
                                btnTitle: "Tambah Tujuan Pembelajaran",
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
      bottomNavigationBar: _buildBottomSheet(isEditingNew, displayIndex),
    );
  }

  Widget _buildTujuanPembelajaranSection(int index, TujuanPembelajaran tp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Textfield3Widget(
          title: 'Tujuan Pembelajaran - ${index + 1}',
          hintText: "Deskripsi Tujuan Pembelajaran",
          pController: index == 0 ? deskripsiTPcontroller : null,
          onChanged: (value) {
            final updatedTp = tp.copyWith(deskripsi: value);
            _updateTujuanPembelajaran(index, updatedTp);
          },
          isRequired: false,
        ),
        SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFieldHorizontalGeneralWidget(
                    title: "Perlu Bimbingan",
                    hintText: "Masukkan target capaian belajar",
                    pController: index == 0 ? perluBimbinganController : null,
                    onChanged: (value) {
                      final updatedTp = tp.copyWith(perluBimbingan: value);
                      _updateTujuanPembelajaran(index, updatedTp);
                    },
                    isRequired: false,
                  ),
                  SizedBox(height: 10),
                  TextFieldHorizontalGeneralWidget(
                    title: "Cukup",
                    hintText: "Masukkan target capaian belajar",
                    pController: index == 0 ? cukupController : null,
                    onChanged: (value) {
                      final updatedTp = tp.copyWith(cukup: value);
                      _updateTujuanPembelajaran(index, updatedTp);
                    },
                    isRequired: false,
                  ),
                  SizedBox(height: 10),
                  TextFieldHorizontalGeneralWidget(
                    title: "Baik",
                    hintText: "Masukkan target capaian belajar",
                    pController: index == 0 ? baikController : null,
                    onChanged: (value) {
                      final updatedTp = tp.copyWith(baik: value);
                      _updateTujuanPembelajaran(index, updatedTp);
                    },
                    isRequired: false,
                  ),
                  SizedBox(height: 10),
                  TextFieldHorizontalGeneralWidget(
                    title: "Sangat Baik",
                    hintText: "Masukkan target capaian belajar",
                    pController: index == 0 ? sangatBaikController : null,
                    onChanged: (value) {
                      final updatedTp = tp.copyWith(sangatBaik: value);
                      _updateTujuanPembelajaran(index, updatedTp);
                    },
                    isRequired: false,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (index < _tujuanPembelajaranList.length - 1)
          Divider(height: 40, color: Colors.grey[300]),
      ],
    );
  }

  Widget _buildBottomSheet(bool isEditingNew, int displayIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, -4), // ⬅️ shadow naik ke atas
          ),
        ],
      ),
      width: double.infinity,
      // color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Navigasi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tombol Sebelumnya - selalu tampilkan jika ada rubrik sebelumnya
              if (hasPrevious)
                TextButton.icon(
                  onPressed: _goToPrevious,
                  icon: Icon(Symbols.arrow_back_ios, size: 16),
                  label: Text('Sebelumnya'),
                )
              else
                SizedBox(width: 100), // Placeholder untuk alignment
              // Teks status
              Text(
                isEditingNew
                    ? 'Rubrik $displayIndex dari ${totalRubrik + 1}'
                    : 'Rubrik $displayIndex dari $totalRubrik',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),

              // Tombol Selanjutnya - tampilkan jika bukan rubrik baru
              if (!isEditingNew && hasNext)
                TextButton.icon(
                  onPressed: _goToNext,
                  icon: Icon(Symbols.arrow_forward_ios, size: 16),
                  label: Text('Selanjutnya'),
                )
              else
                SizedBox(width: 100), // Placeholder untuk alignment
            ],
          ),
          SizedBox(height: 10),
          // Row 2: Aksi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MainButtonWidget(
                btnAction: _addLingkupMateri,
                btnTitle: "Tambah Lingkup Materi",
              ),
              MainButtonWidget(
                btnAction: _unggahRubrik,
                btnTitle: "Unggah Rubrik Mata Pelajaran",
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    judulLMcontroller.dispose();
    deskripsiTPcontroller.dispose();
    perluBimbinganController.dispose();
    cukupController.dispose();
    baikController.dispose();
    sangatBaikController.dispose();
    super.dispose();
  }
}

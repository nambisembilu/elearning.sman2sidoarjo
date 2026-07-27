// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../models/guru/filtering_model.dart';
import '../../../../../models/guru/soal_ujian_model.dart';
import '../../../../controllers/guru/ujian/ujian_kelas_riverpod.dart';
import '../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../../../shared_widgets/general_old/dropdown_widget.dart';
import '../../../../shared_widgets/general_old/main_button_widget.dart';
import '../../../../shared_widgets/general_old/textfield_3_widget.dart';
import '../../../../shared_widgets/general_old/textfield_horizontal_widget.dart';

class KelolaUjianScreen extends ConsumerStatefulWidget {
  // final String tipeUjian;
  const KelolaUjianScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _KelolaUjianScreenState();
}

class _KelolaUjianScreenState extends ConsumerState<KelolaUjianScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentSection = 0; // 0: informasi ujian, 1: soal ujian
  int _currentSoalIndex = 0;

  DateTime? selectedTanggal;
  TimeOfDay? selectedJamMulai;
  TimeOfDay? selectedJamSelesai;

  String? selectedStatusNilai;
  String? selectedStatusUjian;
  String? selectedTipeSoal;
  String? selectedKunciJawaban;
  String? selectedMediaGambar;
  String? selectedTipeUjian;
  String? selectedLingkupMateri;
  String? selectedTujuanPembelajaran;

  int? selectedLingkupMateriId;
  int? selectedTujuanPembelajaranId;

  // Variabel untuk menyimpan informasi ujian
  InfoUjian? _infoUjian;

  // list untuk menyimpan soal
  final List<SoalUjian> _soalUjian = [];

  final TextEditingController deskripsiController = TextEditingController();
  // Controller untuk soal
  final TextEditingController soalController = TextEditingController();
  final TextEditingController bobotNilaiController = TextEditingController();

  // Controller untuk opsi jawaban - mulai dengan 2 opsi (A dan B)
  List<TextEditingController> _opsiControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  List<LingkupMateri> lingkupMateriList = [];
  List<Map<String, dynamic>> tujuanPembelajaranList = [];

  @override
  void initState() {
    super.initState();
    loadSelectedTipeUjian();
    // Set default tipe soal
    selectedTipeSoal = 'Pilihan Ganda';
    bobotNilaiController.text = '1';

    Future.microtask(() async {
      final list = await ref
          .read(ujianKelasRiverpodProvider.notifier)
          .fetchLingkupMateri();

      if (!mounted) return;
      setState(() {
        lingkupMateriList = list;
      });
    });
  }

  Future<void> loadSelectedTipeUjian() async {
    final prefs = await SharedPreferences.getInstance();
    selectedTipeUjian = prefs.getString('selectedTipeUjian');
  }

  void _tutupLoadingIndicator() {
    // Tutup loading indicator dengan rootNavigator
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _hapusSoal(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Soal'),
        content: Text('Apakah Anda yakin ingin menghapus soal ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _soalUjian.removeAt(index);

                // Penyesuaian index setelah penghapusan
                if (_soalUjian.isEmpty) {
                  _currentSoalIndex = 0;
                  _resetFormSoal();
                } else if (_currentSoalIndex >= _soalUjian.length) {
                  _currentSoalIndex = _soalUjian.length - 1;
                  _muatSoalUntukEdit(_currentSoalIndex);
                } else {
                  _muatSoalUntukEdit(_currentSoalIndex);
                }

                // Simpan perubahan informasi ujian
                _simpanInfoUjian();
                _printInfoUjianJson();
              });
            },
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _tambahSoal() {
    // ❗ Jika tidak valid → STOP
    if (!_validasiFormCurrentIndex()) return;

    setState(() {
      if (selectedTipeSoal == 'Pilihan Ganda') {
        _soalUjian.add(
          SoalUjian(
            idTpTemp: DateTime.now().millisecondsSinceEpoch,
            soal: soalController.text,
            tipeSoal: 'Pilihan Ganda',
            bobotNilai: 1,
            // opsi jawaban default
            opsiJawabanA: _opsiControllers[0].text,
            opsiJawabanB: _opsiControllers[1].text,
            opsiJawabanC:
                _opsiControllers.length > 2 &&
                    _opsiControllers[2].text.isNotEmpty
                ? _opsiControllers[2].text
                : null,
            opsiJawabanD:
                _opsiControllers.length > 3 &&
                    _opsiControllers[3].text.isNotEmpty
                ? _opsiControllers[3].text
                : null,
            opsiJawabanE:
                _opsiControllers.length > 4 &&
                    _opsiControllers[4].text.isNotEmpty
                ? _opsiControllers[4].text
                : null,

            // belum ada kunci jawaban
            kunciJawabanPilgan: selectedKunciJawaban,
          ),
        );
      } else if (selectedTipeSoal == 'Esai') {
        _soalUjian.add(
          SoalUjian(
            idTpTemp: DateTime.now().millisecondsSinceEpoch,
            soal: soalController.text,
            tipeSoal: 'Esai',
            bobotNilai: int.parse(bobotNilaiController.text),
          ),
        );
      }
      // _currentSoalIndex = _soalUjian.length - 1;
      _currentSoalIndex++;
      _resetFormSoal();
    });

    // Setelah menambah soal, simpan informasi ujian dan print JSON
    _simpanInfoUjian();
    _printInfoUjianJson();
  }

  void _resetFormSoal() {
    soalController.clear();
    bobotNilaiController.clear();
    selectedTipeSoal = 'Pilihan Ganda';
    bobotNilaiController.text = '1';
    selectedKunciJawaban = null;
    selectedMediaGambar = null;

    // Reset opsi controllers ke 2 opsi (A dan B)
    for (var controller in _opsiControllers) {
      controller.dispose();
    }
    _opsiControllers = [
      TextEditingController(), // Opsi A
      TextEditingController(), // Opsi B
    ];

    // Set placeholder text untuk opsi A dan B
    // _opsiControllers[0].text = 'Opsi A';
    // _opsiControllers[1].text = 'Opsi B';

    // Set kunci jawaban default ke A
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   setState(() {
    //     selectedKunciJawaban = 'A';
    //   });
    // });
  }

  void _tambahOpsiJawaban() {
    setState(() {
      if (_opsiControllers.length < 5) {
        _opsiControllers.add(TextEditingController());
        final newIndex = _opsiControllers.length - 1;
        final label = String.fromCharCode(65 + newIndex);
        _opsiControllers[newIndex].text = 'Opsi $label';

        // Set kunci jawaban ke opsi baru secara otomatis
        // selectedKunciJawaban = label;
      }
    });
  }

  void _hapusOpsiJawaban(int index) {
    // Hanya boleh menghapus opsi C, D, E (index 2,3,4) dan hanya opsi terakhir
    if (index >= 2 &&
        index < _opsiControllers.length &&
        index == _opsiControllers.length - 1) {
      setState(() {
        _opsiControllers[index].dispose();
        _opsiControllers.removeAt(index);
      });
    }

    _getAvailableOpsi();
  }

  void _simpanSoalSekarang() {
    // ❗ Jika tidak valid → STOP
    // if (!_validasiFormCurrentIndex()) return;

    if (selectedTipeSoal == 'Pilihan Ganda') {
      if (_currentSoalIndex < _soalUjian.length) {
        setState(() {
          _soalUjian[_currentSoalIndex] = SoalUjian(
            idTpTemp: _soalUjian[_currentSoalIndex].idTpTemp,
            soal: soalController.text,
            tipeSoal: selectedTipeSoal ?? 'Pilihan Ganda',
            opsiJawabanA: _opsiControllers[0].text,
            opsiJawabanB: _opsiControllers[1].text,
            opsiJawabanC:
                _opsiControllers.length > 2 &&
                    _opsiControllers[2].text.isNotEmpty
                ? _opsiControllers[2].text
                : null,
            opsiJawabanD:
                _opsiControllers.length > 3 &&
                    _opsiControllers[3].text.isNotEmpty
                ? _opsiControllers[3].text
                : null,
            opsiJawabanE:
                _opsiControllers.length > 4 &&
                    _opsiControllers[4].text.isNotEmpty
                ? _opsiControllers[4].text
                : null,
            kunciJawabanPilgan: selectedKunciJawaban,
            bobotNilai: selectedTipeSoal == 'Esai'
                ? int.tryParse(bobotNilaiController.text) ?? 1
                : 1,
          );
        });

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Soal ${_currentSoalIndex + 1} berhasil disimpan!'),
        //   ),
        // );
      }
    }
  }

  bool _validasiFormCurrentIndex() {
    if (_currentSection == 0) {
      if (deskripsiController.text.isEmpty ||
          selectedTanggal == null ||
          selectedJamMulai == null ||
          selectedJamSelesai == null ||
          selectedStatusNilai == null ||
          selectedStatusUjian == null) {
        showDialog(
          context: context,
          builder: (context) =>
              DialogErrorWidget(errorText: "Semua informasi ujian harus diisi"),
        );
        return false; // ❌ stop
      }

      setState(() {
        _currentSection = 1;
      });
      return true; // ✔ lanjut
    } else if (_currentSection == 1) {
      if (selectedTipeSoal == "Pilihan Ganda") {
        bool adaOpsiKosong = _opsiControllers.any(
          (controller) => controller.text.trim().isEmpty,
        );

        if (soalController.text.trim().isEmpty) {
          showDialog(
            context: context,
            builder: (context) =>
                DialogErrorWidget(errorText: "Soal harus diisi"),
          );
          return false;
        } else if (selectedTipeSoal == null) {
          showDialog(
            context: context,
            builder: (context) =>
                DialogErrorWidget(errorText: "Tipe soal belum dipilih"),
          );
          return false;
        } else if (bobotNilaiController.text.trim().isEmpty) {
          showDialog(
            context: context,
            builder: (context) =>
                DialogErrorWidget(errorText: "Bobot nilai harus diisi"),
          );
          return false;
        } else if (adaOpsiKosong) {
          showDialog(
            context: context,
            builder: (context) =>
                DialogErrorWidget(errorText: "Lengkapi semua opsi jawaban"),
          );
          return false;
        } else if (selectedKunciJawaban == null) {
          showDialog(
            context: context,
            builder: (context) =>
                DialogErrorWidget(errorText: "Kunci jawaban belum dipilih"),
          );
          return false;
        }
      } else if (selectedTipeSoal == "Esai") {
        if (soalController.text.trim().isEmpty) {
          showDialog(
            context: context,
            builder: (context) =>
                DialogErrorWidget(errorText: "Soal harus diisi"),
          );
          return false;
        } else if (bobotNilaiController.text.trim().isEmpty) {
          showDialog(
            context: context,
            builder: (context) =>
                DialogErrorWidget(errorText: "Bobot nilai harus diisi"),
          );
          return false;
        }
      }
    }
    return true; // Valid
  }

  void _muatSoalUntukEdit(int index) {
    if (index < _soalUjian.length) {
      final soal = _soalUjian[index];
      setState(() {
        soalController.text = soal.soal;
        selectedTipeSoal = soal.tipeSoal;
        bobotNilaiController.text = soal.bobotNilai?.toString() ?? '1';
        selectedKunciJawaban = soal.kunciJawabanPilgan;

        // Reset controllers
        for (var controller in _opsiControllers) {
          controller.dispose();
        }
        _opsiControllers = [];

        // Load opsi yang ada
        _opsiControllers.add(
          TextEditingController(text: soal.opsiJawabanA ?? 'Opsi A'),
        );
        _opsiControllers.add(
          TextEditingController(text: soal.opsiJawabanB ?? 'Opsi B'),
        );

        if (soal.opsiJawabanC != null) {
          _opsiControllers.add(TextEditingController(text: soal.opsiJawabanC!));
        }
        if (soal.opsiJawabanD != null) {
          _opsiControllers.add(TextEditingController(text: soal.opsiJawabanD!));
        }
        if (soal.opsiJawabanE != null) {
          _opsiControllers.add(TextEditingController(text: soal.opsiJawabanE!));
        }

        // Perbaikan: Validasi kunci jawaban setelah memuat soal
        // _validasiKunciJawabanSebelumSimpan();
      });
    }
  }

  /////////////////////// SUDAH AMAN ////////////////////////////////

  // Method untuk menyimpan informasi ujian ke dalam objek InfoUjian
  void _simpanInfoUjian() {
    _infoUjian = InfoUjian(
      idTemp: DateTime.now().millisecondsSinceEpoch,
      tipeUjian: selectedTipeUjian!,
      deskripsi: deskripsiController.text,
      tanggalUjian: selectedTanggal != null
          ? _formatDate(selectedTanggal!)
          : '',
      jamMulai: selectedJamMulai != null ? _formatTime(selectedJamMulai!) : '',
      jamSelesai: selectedJamSelesai != null
          ? _formatTime(selectedJamSelesai!)
          : '',
      statusNilai: selectedStatusNilai ?? '',
      statusUjian: selectedStatusUjian ?? '',
      soalUjian: _soalUjian,
    );
  }

  // Method untuk mencetak InfoUjian dalam bentuk JSON
  void _printInfoUjianJson() {
    if (_infoUjian != null) {
      print('=== INFO UJIAN JSON ===');
      print('InfoUjian JSON: ${_infoUjian!.toJson()}');
      print('=======================');
    } else {
      print('InfoUjian belum disimpan.');
    }
  }

  List<String> _getAvailableOpsi() {
    List<String> opsi = [];
    for (int i = 0; i < _opsiControllers.length; i++) {
      // Selalu tambahkan semua opsi yang ada, tidak peduli isi text-nya
      opsi.add(String.fromCharCode(65 + i)); // A, B, C, D, E
    }
    return opsi;
  }

  Future<void> _pilihTanggal() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedTanggal) {
      setState(() {
        selectedTanggal = picked;
      });
    }
  }

  Future<void> _pilihJamMulai() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedJamMulai) {
      setState(() {
        selectedJamMulai = picked;
      });
    }
  }

  Future<void> _pilihJamSelesai() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedJamSelesai) {
      setState(() {
        selectedJamSelesai = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  void _uploadUjian() async {
    if (!_validasiFormCurrentIndex()) return;
    // Simpan soal terakhir
    // _simpanSoalSekarang();

    if (_currentSoalIndex == _soalUjian.length) {
      _tambahSoal();
    } else {
      _simpanSoalSekarang();
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = selectedTipeUjian == 'Sumatif Lingkup Materi'
          ? await ref
                .read(ujianKelasRiverpodProvider.notifier)
                .addUjianSumatifLm(
                  tujuanPembelajaranId: selectedTujuanPembelajaranId!,
                  tipeUjian: selectedTipeUjian!,
                  deskripsi: deskripsiController.text,
                  tanggalUjian: _formatDate(selectedTanggal!),
                  jamMulai: _formatTime(selectedJamMulai!),
                  jamSelesai: _formatTime(selectedJamSelesai!),
                  statusNilai: (selectedStatusNilai == "Tampilkan")
                      ? "Ditampilkan"
                      : "Disembunyikan",
                  statusKonten: (selectedStatusUjian == "Tampilkan")
                      ? "Visible"
                      : "Hide",
                  soalUjian: _infoUjian!.soalUjian,
                )
          : await ref
                .read(ujianKelasRiverpodProvider.notifier)
                .addUjian(
                  tipeUjian: selectedTipeUjian!,
                  deskripsi: deskripsiController.text,
                  tanggalUjian: _formatDate(selectedTanggal!),
                  jamMulai: _formatTime(selectedJamMulai!),
                  jamSelesai: _formatTime(selectedJamSelesai!),
                  statusNilai: (selectedStatusNilai == "Tampilkan")
                      ? "Ditampilkan"
                      : "Disembunyikan",
                  statusKonten: (selectedStatusUjian == "Tampilkan")
                      ? "Visible"
                      : "Hide",
                  soalUjian: _infoUjian!.soalUjian,
                );

      // Navigator.pop(context);
      _tutupLoadingIndicator();

      if (success) {
        // Navigator.pop(context);
        if (!mounted) return;

        await showDialog(
          context: context,
          builder: (context) =>
              DialogSuccessWidget(succesText: 'Ujian berhasil diupload'),
        );

        if (!mounted) return;
        context.pop(); // Kembali ke halaman sebelumnya
      }
    } catch (e) {
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

    // if (!isValid) return;

    // Simpan informasi ujian terakhir
    // _simpanInfoUjian();

    // print('=== UPLOAD UJIAN ===');
    // print('InfoUjian JSON: ${_infoUjian!.toJson()}');
    // print('===================');

    // Tampilkan konfirmasi
    // ScaffoldMessenger.of(
    //   context,
    // ).showSnackBar(SnackBar(content: Text('Ujian berhasil diupload!')));
  }

  Widget _buildInformasiUjian() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi Ujian',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Textfield3Widget(
          title: 'Deskripsi Ujian',
          hintText: 'Masukkan deskripsi ujian',
          pController: deskripsiController,
          isRequired: false,
        ),
        SizedBox(height: 16),
        if (selectedTipeUjian == "Sumatif Lingkup Materi") ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: DropdownGeneralWidget(
                  pTitle: 'Lingkup Materi',
                  pHintText: 'Pilih lingkup materi',
                  valueParams: selectedLingkupMateri,
                  pItems: lingkupMateriList.map((e) => e.judulLM).toList(),
                  pOnChanged: (value) {
                    setState(() {
                      selectedLingkupMateri = value;
                      final selectedObj = lingkupMateriList.firstWhere(
                        (e) => e.judulLM == value,
                      );
                      selectedLingkupMateriId = selectedObj.lingkupMateriId;

                      // Ambil tujuan dari item yang dipilih
                      tujuanPembelajaranList = selectedObj.tujuanPembelajaran;
                      selectedTujuanPembelajaran = null;
                      selectedTujuanPembelajaranId = null;
                    });
                  },
                  isRequired: false,
                  isSubmitted: false,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: DropdownGeneralWidget(
                  pTitle: "Tujuan Pembelajaran",
                  pHintText: "Pilih tujuan pembelajaran",
                  valueParams: selectedTujuanPembelajaran,
                  pItems: tujuanPembelajaranList
                      .map((e) => e['judul'] as String)
                      .toList(),
                  pOnChanged: (value) {
                    setState(() {
                      selectedTujuanPembelajaran = value;

                      final selectedTP = tujuanPembelajaranList.firstWhere(
                        (e) => e['judul'] == value,
                      );

                      selectedTujuanPembelajaranId =
                          selectedTP['id']; // kalau butuh id
                    });
                  },
                  isRequired: false,
                  isSubmitted: false,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal Ujian',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  InkWell(
                    onTap: _pilihTanggal,
                    child: Container(
                      height: 36,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromRGBO(120, 144, 156, 1),
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedTanggal != null
                                ? _formatDate(selectedTanggal!)
                                : 'Pilih Tanggal',
                            style: TextStyle(fontSize: 12),
                          ),
                          Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jam Mulai',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  InkWell(
                    onTap: _pilihJamMulai,
                    child: Container(
                      height: 36,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromRGBO(120, 144, 156, 1),
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedJamMulai != null
                                ? _formatTime(selectedJamMulai!)
                                : 'Pilih Jam Mulai',
                            style: TextStyle(fontSize: 12),
                          ),
                          Icon(Icons.access_time, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jam Selesai',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  InkWell(
                    onTap: _pilihJamSelesai,
                    child: Container(
                      height: 36,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromRGBO(120, 144, 156, 1),
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedJamSelesai != null
                                ? _formatTime(selectedJamSelesai!)
                                : 'Pilih Jam Selesai',
                            style: TextStyle(fontSize: 12),
                          ),
                          Icon(Icons.access_time, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownGeneralWidget(
                pTitle: 'Status Nilai',
                pHintText: 'Pilih Status Nilai',
                valueParams: selectedStatusNilai,
                pItems: ['Tampilkan', 'Sembunyikan'],
                pOnChanged: (value) {
                  setState(() {
                    selectedStatusNilai = value;
                  });
                },
                isRequired: false,
                isSubmitted: false,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: DropdownGeneralWidget(
                pTitle: 'Status Ujian',
                pHintText: 'Pilih Status Ujian',
                valueParams: selectedStatusUjian,
                pItems: ['Tampilkan', 'Sembunyikan'],
                pOnChanged: (value) {
                  setState(() {
                    selectedStatusUjian = value;
                  });
                },
                isRequired: false,
                isSubmitted: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSoalUjian() {
    final availableOpsi = _getAvailableOpsi();

    // Perbaikan: Pastikan kunci jawaban valid sebelum build
    // if (selectedKunciJawaban != null && !availableOpsi.contains(selectedKunciJawaban)) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     setState(() {
    //       selectedKunciJawaban = availableOpsi.isNotEmpty ? availableOpsi.first : null;
    //     });
    //   });
    // }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Textfield3Widget(
          title: 'Soal No.${_currentSoalIndex + 1}',
          hintText: 'Masukkan pertanyaan soal',
          pController: soalController,
          isRequired: true,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownGeneralWidget(
                pTitle: 'Tipe Soal',
                pHintText: 'Pilih Tipe Soal',
                valueParams: selectedTipeSoal,
                pItems: ['Pilihan Ganda', 'Esai'],
                pOnChanged: (value) {
                  setState(() {
                    selectedTipeSoal = value;
                    if (value == 'Pilihan Ganda') {
                      bobotNilaiController.text = '1';
                      // Set kunci jawaban default jika berpindah ke pilihan ganda
                      if (availableOpsi.isNotEmpty &&
                          selectedKunciJawaban == null) {
                        selectedKunciJawaban = availableOpsi.first;
                      }
                    } else {
                      selectedKunciJawaban = null;
                    }
                  });
                },
                isRequired: true,
                isSubmitted: false,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Textfield3Widget(
                title: 'Bobot Nilai',
                hintText: 'Masukkan bobot nilai',
                pController: bobotNilaiController,
                isRequired: true,
                onChanged: (value) {
                  if (selectedTipeSoal == 'Pilihan Ganda') {
                    bobotNilaiController.text = '1';
                  }
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        // Tampilkan opsi jawaban hanya untuk pilihan ganda
        if (selectedTipeSoal == 'Pilihan Ganda') ...[
          SizedBox(height: 16),
          Text(
            'Opsi Jawaban:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          // Tampilkan semua opsi yang ada
          for (int i = 0; i < _opsiControllers.length; i++)
            Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFieldHorizontalGeneralWidget(
                            title: 'Opsi ${String.fromCharCode(65 + i)}',
                            hintText:
                                'Masukkan opsi ${String.fromCharCode(65 + i)}',
                            pController: _opsiControllers[i],
                            isRequired: i < 2, // Hanya opsi A dan B yang wajib
                            onChanged: (value) {
                              // Update UI ketika opsi berubah
                              setState(() {
                                _getAvailableOpsi();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    // Tombol hapus untuk opsi C, D, E (index 2,3,4)
                    SizedBox(height: 5),
                    // Tombol hapus hanya untuk opsi C, D, E dan hanya di opsi terakhir
                    if (i >= 2 && i == _opsiControllers.length - 1)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => _hapusOpsiJawaban(i),
                        ),
                      ),
                    // if (i >= 2)
                    //   IconButton(
                    //     icon: Icon(Icons.delete, color: Colors.red),
                    //     onPressed: () => _hapusOpsiJawaban(i),
                    //   ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          SizedBox(height: 16),
          // Tombol tambah opsi hanya ditampilkan jika belum mencapai maksimal 5 opsi
          if (_opsiControllers.length < 5)
            MainButtonWidget(
              btnAction: _tambahOpsiJawaban,
              btnTitle: "Tambah opsi jawaban",
            ),
          SizedBox(height: 16),
          // Hanya tampilkan dropdown kunci jawaban jika ada opsi yang tersedia
          if (availableOpsi.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: DropdownGeneralWidget(
                    pTitle: 'Kunci Jawaban',
                    pHintText: 'Pilih Kunci Jawaban',
                    valueParams: selectedKunciJawaban,
                    pItems: availableOpsi,
                    pOnChanged: (value) {
                      setState(() {
                        selectedKunciJawaban = value;
                      });
                    },
                    isRequired: true,
                    isSubmitted: false,
                  ),
                ),
              ],
            ),
          // if (availableOpsi.isEmpty)
          //   Text(
          //     'Isi minimal opsi A dan B untuk memilih kunci jawaban',
          //     style: TextStyle(color: Colors.red, fontSize: 12),
          //   ),
        ],
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Sebelumnya - SELALU ADA di section 1
          if (_currentSection == 1)
            ElevatedButton(
              onPressed: () {
                print("jumlah soal : ${_soalUjian.length}");
                print("jumlah index soal : $_currentSoalIndex");
                _simpanSoalSekarang();
                if (_currentSoalIndex == 0) {
                  setState(() {
                    _currentSection = 0;
                  });
                } else {
                  setState(() {
                    _currentSoalIndex--;
                    _muatSoalUntukEdit(_currentSoalIndex);
                  });
                }
              },
              child: Text('Sebelumnya'),
            )
          else
            SizedBox(width: 100),

          // Tombol di tengah - TAMBAH SOAL
          Row(
            children: [
              // Tombol Tambah Soal hanya di soal baru
              if (_currentSection == 1 &&
                  _currentSoalIndex == _soalUjian.length)
                ElevatedButton(
                  onPressed: () {
                    print("index soal : $_currentSoalIndex");
                    _tambahSoal();
                  },
                  child: Text('Tambah Soal'),
                ),
              if (_currentSoalIndex < _soalUjian.length && _currentSection == 1)
                ElevatedButton(
                  onPressed: () => _hapusSoal(_currentSoalIndex),
                  child: Text('Hapus Soal'),
                ),
            ],
          ),

          // Tombol di kanan
          Row(
            children: [
              // Tombol Selanjutnya untuk section informasi
              if (_currentSection == 0)
                ElevatedButton(
                  onPressed: () {
                    print("index soal : $_currentSoalIndex");
                    if (!_validasiFormCurrentIndex()) return;
                  },
                  child: Text('Selanjutnya'),
                ),

              // PERBAIKAN: Tombol Selanjutnya untuk soal yang sudah ada
              if (_currentSection == 1 &&
                  _currentSoalIndex <
                      _soalUjian.length) // ❗ PERUBAHAN: hapus -1
                ElevatedButton(
                  onPressed: () {
                    print("index soal : $_currentSoalIndex");
                    _simpanSoalSekarang();
                    setState(() {
                      _currentSoalIndex++;
                      if (_currentSoalIndex < _soalUjian.length) {
                        _muatSoalUntukEdit(_currentSoalIndex);
                      } else {
                        _resetFormSoal();
                      }
                    });
                  },
                  child: Text('Selanjutnya'),
                ),

              // Tombol Upload Ujian
              if (_currentSection == 1 &&
                  _currentSoalIndex == _soalUjian.length)
                ElevatedButton(
                  onPressed: () {
                    _uploadUjian();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    'Upload Ujian',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_currentSection == 0)
                                _buildInformasiUjian()
                              else
                                _buildSoalUjian(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    deskripsiController.dispose();
    soalController.dispose();
    bobotNilaiController.dispose();
    for (var controller in _opsiControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

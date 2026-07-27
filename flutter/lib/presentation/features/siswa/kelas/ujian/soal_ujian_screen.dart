// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../models/siswa/jawaban_ujian_model.dart';
import '../../../../../models/siswa/soal_ujian_siswa.dart';
import '../../../../controllers/siswa/ujian/ujian_riverpod.dart';
import '../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../../../shared_widgets/general_old/main_button_widget.dart';
import '../../../../shared_widgets/general_old/rich_textfield_widget.dart';
import 'widget/dialog_timer_habis.dart';

class SoalUjianSiswaScreen extends ConsumerStatefulWidget {
  const SoalUjianSiswaScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SoalUjianSiswaScreenState();
}

class _SoalUjianSiswaScreenState extends ConsumerState<SoalUjianSiswaScreen> {
  List<SoalUjianSiswa> daftarSoal = [];
  List<JawabanUjianModel> jawabanSiswa = [];
  List<TextEditingController> esaiControllers = [];
  bool isLoading = true;
  int currentSoalIndex = 0;

  String? endDateTime;

  DateTime? endDate;
  Duration remainingTime = Duration.zero;
  Timer? countdownTimer;

  // void startCountdown() {
  //   if (endDate == null) return;

  //   countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     final now = DateTime.now();
  //     setState(() {
  //       remainingTime = endDate!.difference(now);
  //     });

  //     if (remainingTime.inSeconds <= 0) {
  //       timer.cancel();
  //       // TODO: Aksi ketika waktu habis
  //       print("Waktu ujian habis!");
  //     }
  //   });
  // }

  void startCountdown() {
    if (endDate == null) return;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final now = DateTime.now();

      setState(() {
        remainingTime = endDate!.difference(now);
      });

      if (remainingTime.inSeconds <= 0) {
        timer.cancel();

        // if (isSubmitted) return;
        // isSubmitted = true;

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => DialogTimerHabisWidget(),
        );

        await submitJawabanOtomatis();
      }
    });
  }

  // Di dalam _SoalUjianSiswaScreenState

  Future<void> submitJawabanOtomatis() async {
    // Simpan semua jawaban esai terakhir sebelum submit
    for (int i = 0; i < daftarSoal.length; i++) {
      if (daftarSoal[i].tipeSoal == 'Esai') {
        final controller = esaiControllers[i];
        jawabanSiswa[i] = jawabanSiswa[i].copyWith(
          jawabanEsai: controller.text,
          statusJawaban: controller.text.isEmpty ? 'Salah' : 'Benar',
          nilaiJawaban: 0,
        );
      }
    }
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final success = await ref
          .read(ujianKelasRiverpodProvider.notifier)
          .addJawabanUjian(jawabanUjian: jawabanSiswa);

      _tutupLoadingIndicator();

      if (success) {
        await showDialog(
          context: context,
          builder: (_) =>
              DialogSuccessWidget(succesText: "Jawaban berhasil dikirim"),
        );

        if (!mounted) return;
        context.pop();
      }
    } catch (e) {
      _tutupLoadingIndicator();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) =>
              DialogErrorWidget(errorText: "Terjadi kesalahan : $e"),
        );
      }
    }
  }

  String formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = two(d.inHours);
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return "$h:$m:$s";
  }

  Future<void> initTimer() async {
    await loadBatasWaktuUjian();

    if (endDateTime != null) {
      endDate = DateTime.parse(endDateTime!);
      startCountdown();
    }
  }

  // Future<void> _loadDaftarSoalUjian() async {
  //   final list =
  //       await ref
  //           .read(ujianKelasRiverpodProvider.notifier)
  //           .fetchSoalUjianSiswa();

  //   if (!mounted) return;

  //   setState(() {
  //     daftarSoal = list;
  //     // Inisialisasi jawaban siswa
  //     jawabanSiswa = List.generate(
  //       list.length,
  //       (index) => JawabanUjianModel(
  //         soalUjianId: list[index].soalUjianId,
  //         nilaiJawaban: 0,
  //       ),
  //     );
  //     // Inisialisasi controller untuk esai
  //     esaiControllers = List.generate(
  //       list.length,
  //       (index) => TextEditingController(),
  //     );
  //     isLoading = false;
  //   });

  //   print('ini jawaban siswa');
  //   printJawabanSiswa();
  // }

  Future<void> _loadDaftarSoalUjian() async {
    final list = await ref
        .read(ujianKelasRiverpodProvider.notifier)
        .fetchSoalUjianSiswa();

    if (!mounted) return;

    setState(() {
      daftarSoal = list;
      // Inisialisasi jawaban siswa dengan status 'Salah' default
      jawabanSiswa = List.generate(
        list.length,
        (index) => JawabanUjianModel(
          soalUjianId: list[index].soalUjianId,
          jawabanPilgan: null,
          jawabanEsai: null,
          statusJawaban: 'Salah', // Default status menjadi 'Salah'
          nilaiJawaban: 0,
        ),
      );
      // Inisialisasi controller untuk esai
      esaiControllers = List.generate(
        list.length,
        (index) => TextEditingController(),
      );
      isLoading = false;
    });

    print('ini jawaban siswa');
    printJawabanSiswa();
  }

  void _handleJawabanPilgan(String? value) {
    if (value == null) return;

    String statusJawaban;
    int nilaiJawaban;
    if (value == daftarSoal[currentSoalIndex].kunciJawabanPilgan) {
      statusJawaban = 'Benar';
      nilaiJawaban = 1;
    } else {
      statusJawaban = 'Salah';
      nilaiJawaban = 0;
    }

    setState(() {
      jawabanSiswa[currentSoalIndex] = jawabanSiswa[currentSoalIndex].copyWith(
        jawabanPilgan: value,
        statusJawaban: statusJawaban,
        nilaiJawaban: nilaiJawaban,
      );
    });
  }

  void _handleJawabanEsai(String value) {
    setState(() {
      jawabanSiswa[currentSoalIndex] = jawabanSiswa[currentSoalIndex].copyWith(
        jawabanEsai: value,
        statusJawaban: value.isEmpty ? 'Salah' : 'Benar',
        nilaiJawaban: 0,
      );
    });
  }

  // Method untuk menyimpan jawaban esai sebelum pindah soal
  void _simpanJawabanEsaiSaatIni() {
    final soal = daftarSoal[currentSoalIndex];
    if (soal.tipeSoal == 'Esai') {
      final controller = esaiControllers[currentSoalIndex];
      _handleJawabanEsai(controller.text);
    }
  }

  void printJawabanSiswa() {
    final data = jawabanSiswa.map((e) => e.toJson()).toList();
    print(data);
  }

  void _previousSoal() {
    _simpanJawabanEsaiSaatIni(); // Simpan jawaban esai sebelum pindah
    printJawabanSiswa();
    if (currentSoalIndex > 0) {
      setState(() {
        currentSoalIndex--;
      });
    }
  }

  void _nextSoal() {
    _simpanJawabanEsaiSaatIni(); // Simpan jawaban esai sebelum pindah
    printJawabanSiswa();
    if (currentSoalIndex < daftarSoal.length - 1) {
      setState(() {
        currentSoalIndex++;
      });
    }
  }

  void _tutupLoadingIndicator() {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> _submitJawaban() async {
    // Simpan semua jawaban esai terakhir sebelum submit
    for (int i = 0; i < daftarSoal.length; i++) {
      if (daftarSoal[i].tipeSoal == 'Esai') {
        final controller = esaiControllers[i];
        jawabanSiswa[i] = jawabanSiswa[i].copyWith(
          jawabanEsai: controller.text,
          statusJawaban: controller.text.isEmpty ? 'Salah' : 'Benar',
          nilaiJawaban: 0,
        );
      }
    }

    final adaJawabanKosong = jawabanSiswa.asMap().entries.any((entry) {
      final index = entry.key;
      final jawaban = entry.value;
      final soal = daftarSoal[index];

      if (soal.tipeSoal == "Pilihan Ganda") {
        return jawaban.jawabanPilgan == null || jawaban.jawabanPilgan!.isEmpty;
      } else {
        return jawaban.jawabanEsai == null || jawaban.jawabanEsai!.isEmpty;
      }
    });

    if (adaJawabanKosong) {
      showDialog(
        context: context,
        builder: (context) =>
            DialogErrorWidget(errorText: "Masih ada jawaban yang kosong"),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await ref
          .read(ujianKelasRiverpodProvider.notifier)
          .addJawabanUjian(jawabanUjian: jawabanSiswa);

      _tutupLoadingIndicator();

      if (success) {
        if (!mounted) return;

        await showDialog(
          context: context,
          builder: (context) =>
              DialogSuccessWidget(succesText: "Jawaban berhasil dikirim"),
        );

        if (!mounted) return;
        context.pop();
      }
    } catch (e) {
      _tutupLoadingIndicator();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) =>
              DialogErrorWidget(errorText: "Terjadi kesalahan : $e"),
        );
      }
    }
  }

  Future<void> loadBatasWaktuUjian() async {
    final prefs = await SharedPreferences.getInstance();
    endDateTime = prefs.getString('endDateTime');
  }

  @override
  void dispose() {
    // Dispose semua controller untuk menghindari memory leak
    for (var controller in esaiControllers) {
      controller.dispose();
    }
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // loadBatasWaktuUjian();
    initTimer();
    _loadDaftarSoalUjian();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : daftarSoal.isEmpty
          ? Center(child: Text('Tidak ada soal ditemukan'))
          : Column(
              children: [
                // Header nomor soal
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Soal ${currentSoalIndex + 1} dari ${daftarSoal.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Chip(
                        label: Text(
                          formatDuration(remainingTime),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Colors.blue,
                      ),
                      // Chip(
                      //   label: Text(
                      //     daftarSoal[currentSoalIndex].tipeSoal,
                      //     style: TextStyle(color: Colors.white),
                      //   ),
                      //   backgroundColor: Colors.blue,
                      // ),
                    ],
                  ),
                ),

                // Konten soal
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: _buildSoalContent(),
                  ),
                ),

                // Navigation buttons
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (currentSoalIndex > 0)
                        Expanded(
                          child: MainButtonWidget(
                            btnAction: _previousSoal,
                            btnTitle: 'Sebelumnya',
                            disabled: false,
                          ),
                        ),
                      if (currentSoalIndex > 0) SizedBox(width: 16),
                      Expanded(
                        child: MainButtonWidget(
                          disabled: false,
                          btnAction: currentSoalIndex == daftarSoal.length - 1
                              ? _submitJawaban
                              : _nextSoal,
                          btnTitle: currentSoalIndex == daftarSoal.length - 1
                              ? 'Kirim Jawaban'
                              : 'Selanjutnya',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSoalContent() {
    final soal = daftarSoal[currentSoalIndex];
    final jawaban = jawabanSiswa[currentSoalIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Teks soal
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.yellow[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(soal.soal, style: TextStyle(fontSize: 16, height: 1.5)),
        ),

        SizedBox(height: 20),
        Text("Jawaban :", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),

        // Tampilkan berdasarkan tipe soal
        if (soal.tipeSoal == 'Pilihan Ganda') ...[
          _buildPilganOptions(soal, jawaban),
        ] else if (soal.tipeSoal == 'Esai') ...[
          _buildEsaiField(),
        ],
      ],
    );
  }

  Widget _buildPilganOptions(SoalUjianSiswa soal, JawabanUjianModel jawaban) {
    final options = [
      if (soal.opsiJawabanA != null && soal.opsiJawabanA!.isNotEmpty)
        _buildRadioOption('A', "A. ${soal.opsiJawabanA!}"),
      if (soal.opsiJawabanB != null && soal.opsiJawabanB!.isNotEmpty)
        _buildRadioOption('B', "B. ${soal.opsiJawabanB!}"),
      if (soal.opsiJawabanC != null && soal.opsiJawabanC!.isNotEmpty)
        _buildRadioOption('C', "C. ${soal.opsiJawabanC!}"),
      if (soal.opsiJawabanD != null && soal.opsiJawabanD!.isNotEmpty)
        _buildRadioOption('D', "D. ${soal.opsiJawabanD!}"),
      if (soal.opsiJawabanE != null && soal.opsiJawabanE!.isNotEmpty)
        _buildRadioOption('E', "E. ${soal.opsiJawabanE!}"),
    ];

    return Column(children: options);
  }

  Widget _buildRadioOption(String value, String text) {
    return RadioListTile<String>(
      title: Text(text),
      value: value,
      groupValue: jawabanSiswa[currentSoalIndex].jawabanPilgan,
      onChanged: _handleJawabanPilgan,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildEsaiField() {
    final controller = esaiControllers[currentSoalIndex];

    // Set nilai controller dari jawaban yang sudah disimpan
    if (controller.text.isEmpty &&
        jawabanSiswa[currentSoalIndex].jawabanEsai != null) {
      controller.text = jawabanSiswa[currentSoalIndex].jawabanEsai!;
    }

    return Column(
      children: [
        RichTextFieldGeneralWidget(
          title: '',
          hintText: 'Ketik jawaban Anda di sini...',
          p_controller: controller,
          isRequired: false,
          pMinLines: 5,
        ),
      ],
    );
  }
}

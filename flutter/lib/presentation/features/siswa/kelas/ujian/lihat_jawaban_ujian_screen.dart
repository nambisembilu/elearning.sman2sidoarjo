// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../models/siswa/jawaban_ujian_model.dart';
import '../../../../../models/siswa/soal_ujian_siswa.dart';
import '../../../../controllers/siswa/ujian/ujian_riverpod.dart';
import '../../../../shared_widgets/general_old/rich_textfield_widget.dart';

class LihatJawabanUjianSiswaScreen extends ConsumerStatefulWidget {
  const LihatJawabanUjianSiswaScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LihatJawabanUjianSiswaScreenState();
}

class _LihatJawabanUjianSiswaScreenState
    extends ConsumerState<LihatJawabanUjianSiswaScreen> {
  List<SoalUjianSiswa> daftarSoal = [];
  List<JawabanUjianModel> jawabanSiswa = [];
  List<TextEditingController> esaiControllers = [];
  bool isLoading = true;

  Future<void> _loadData() async {
    try {
      // Load soal
      final listSoal = await ref
          .read(ujianKelasRiverpodProvider.notifier)
          .fetchSoalUjianSiswa();

      // Load jawaban yang sudah disimpan
      final listJawaban = await ref
          .read(ujianKelasRiverpodProvider.notifier)
          .fetchJawabanUjianSiswa();

      if (!mounted) return;

      setState(() {
        daftarSoal = listSoal;
        jawabanSiswa = listJawaban;

        // Inisialisasi controller untuk esai dengan jawaban yang sudah disimpan
        esaiControllers = List.generate(listSoal.length, (index) {
          final controller = TextEditingController();
          // Cari jawaban untuk soal ini
          final jawaban = listJawaban.firstWhere(
            (jawaban) => jawaban.soalUjianId == listSoal[index].soalUjianId,
            orElse: () => JawabanUjianModel(
              soalUjianId: listSoal[index].soalUjianId,
              nilaiJawaban: 0,
            ),
          );
          controller.text = jawaban.jawabanEsai ?? '';
          return controller;
        });
        isLoading = false;
      });
    } catch (e) {
      print("Error loading data: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fungsi untuk mendapatkan jawaban berdasarkan soalUjianId
  JawabanUjianModel _getJawabanForSoal(int soalUjianId) {
    return jawabanSiswa.firstWhere(
      (jawaban) => jawaban.soalUjianId == soalUjianId,
      orElse: () =>
          JawabanUjianModel(soalUjianId: soalUjianId, nilaiJawaban: 0),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    // Dispose semua controller
    for (var controller in esaiControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : daftarSoal.isEmpty
          ? Center(child: Text('Tidak ada soal ditemukan'))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: daftarSoal.length,
              itemBuilder: (context, index) {
                final soal = daftarSoal[index];
                final jawaban = _getJawabanForSoal(soal.soalUjianId);
                return _buildSoalItem(soal, jawaban, index);
              },
            ),
    );
  }

  Widget _buildSoalItem(
    SoalUjianSiswa soal,
    JawabanUjianModel jawaban,
    int index,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header nomor soal dan tipe
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Soal ${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                Chip(
                  label: Text(
                    soal.tipeSoal,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: Colors.blue,
                ),
              ],
            ),
            SizedBox(height: 12),

            // Teks soal
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow[100]!),
              ),
              child: Text(
                soal.soal,
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            SizedBox(height: 16),

            // Jawaban user
            Text(
              "Jawaban Anda:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),

            // Tampilkan berdasarkan tipe soal
            if (soal.tipeSoal == 'Pilihan Ganda') ...[
              _buildPilganReview(soal, jawaban),
            ] else if (soal.tipeSoal == 'Esai') ...[
              _buildEsaiReview(soal, jawaban, index),
            ],

            SizedBox(height: 12),

            // Status dan nilai
            if (jawaban.statusJawaban != null)
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(jawaban.statusJawaban!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(jawaban.statusJawaban!),
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${jawaban.statusJawaban!}${jawaban.nilaiJawaban != null ? ' - Nilai: ${jawaban.nilaiJawaban}' : ''}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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

  Widget _buildPilganReview(SoalUjianSiswa soal, JawabanUjianModel jawaban) {
    final jawabanUser = jawaban.jawabanPilgan;
    final kunciJawaban = soal.kunciJawabanPilgan;

    return Column(
      children: [
        // Tampilkan opsi-opsi pilihan ganda
        if (soal.opsiJawabanA != null && soal.opsiJawabanA!.isNotEmpty)
          _buildOptionReview(
            'A',
            "A. ${soal.opsiJawabanA!}",
            jawabanUser,
            kunciJawaban,
          ),
        if (soal.opsiJawabanB != null && soal.opsiJawabanB!.isNotEmpty)
          _buildOptionReview(
            'B',
            "B. ${soal.opsiJawabanB!}",
            jawabanUser,
            kunciJawaban,
          ),
        if (soal.opsiJawabanC != null && soal.opsiJawabanC!.isNotEmpty)
          _buildOptionReview(
            'C',
            "C. ${soal.opsiJawabanC!}",
            jawabanUser,
            kunciJawaban,
          ),
        if (soal.opsiJawabanD != null && soal.opsiJawabanD!.isNotEmpty)
          _buildOptionReview(
            'D',
            "D. ${soal.opsiJawabanD!}",
            jawabanUser,
            kunciJawaban,
          ),
        if (soal.opsiJawabanE != null && soal.opsiJawabanE!.isNotEmpty)
          _buildOptionReview(
            'E',
            "E. ${soal.opsiJawabanE!}",
            jawabanUser,
            kunciJawaban,
          ),

        SizedBox(height: 8),

        // Tampilkan kunci jawaban
        if (kunciJawaban != null && kunciJawaban.isNotEmpty)
          Text(
            'Kunci Jawaban: $kunciJawaban',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  Widget _buildOptionReview(
    String value,
    String text,
    String? jawabanUser,
    String? kunciJawaban,
  ) {
    final isUserAnswer = jawabanUser == value;
    final isCorrectAnswer = kunciJawaban == value;

    Color backgroundColor = Colors.transparent;
    Color textColor = Colors.black;
    IconData? icon;
    Color iconColor = Colors.transparent;

    if (isUserAnswer && isCorrectAnswer) {
      // User memilih jawaban yang benar
      backgroundColor = Colors.green[50]!;
      textColor = Colors.green[800]!;
      icon = Icons.check_circle;
      iconColor = Colors.green;
    } else if (isUserAnswer && !isCorrectAnswer) {
      // User memilih jawaban yang salah
      backgroundColor = Colors.red[50]!;
      textColor = Colors.red[800]!;
      icon = Icons.cancel;
      iconColor = Colors.red;
    } else if (!isUserAnswer && isCorrectAnswer) {
      // Ini adalah jawaban yang benar (tapi tidak dipilih user)
      backgroundColor = Colors.blue[50]!;
      textColor = Colors.blue[800]!;
      icon = Icons.check_circle;
      iconColor = Colors.blue;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 4),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isUserAnswer ? textColor : Colors.grey[300]!,
          width: isUserAnswer ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: iconColor, size: 16),
          SizedBox(width: icon != null ? 8 : 0),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: isUserAnswer ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (isUserAnswer)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: textColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Jawaban Anda',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEsaiReview(
    SoalUjianSiswa soal,
    JawabanUjianModel jawaban,
    int index,
  ) {
    final controller = esaiControllers[index];

    return Column(
      children: [
        RichTextFieldGeneralWidget(
          title: '',
          hintText: 'Jawaban esai akan ditampilkan di sini...',
          p_controller: controller,
          isRequired: false,
          pMinLines: 5,
        ),
        if (jawaban.nilaiJawaban != null && jawaban.nilaiJawaban! > 0)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Nilai: ${jawaban.nilaiJawaban}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Benar':
        return Colors.green;
      case 'Salah':
        return Colors.red;
      case 'Menunggu':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Benar':
        return Icons.check_circle;
      case 'Salah':
        return Icons.cancel;
      case 'Menunggu':
        return Icons.access_time;
      default:
        return Icons.help_outline;
    }
  }
}

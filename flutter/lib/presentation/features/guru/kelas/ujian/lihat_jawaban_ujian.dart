// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../models/guru/jawaban_ujian_model.dart';
import '../../../../../models/guru/soal_ujian_siswa.dart';
import '../../../../controllers/guru/ujian/ujian_kelas_riverpod.dart';

class LihatJawabanUjianScreen extends ConsumerStatefulWidget {
  const LihatJawabanUjianScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LihatJawabanUjianScreenState();
}

class _LihatJawabanUjianScreenState
    extends ConsumerState<LihatJawabanUjianScreen> {
  List<SoalUjianSiswa> daftarSoal = [];
  List<JawabanUjianModel> jawabanSiswa = [];
  List<TextEditingController> esaiControllers = [];
  List<TextEditingController> nilaiControllers = [];
  List<TextEditingController> catatanControllers = [];
  List<bool> isLoadingButtons = []; // Untuk melacak loading per button
  bool isLoading = true;
  String namaSiswa = '';
  int nisSiswa = 0;

  Future<void> _loadData() async {
    try {
      // Load data siswa dari shared preferences
      // final prefs = await SharedPreferences.getInstance();
      // final userIdSiswa = prefs.getInt('userIdSiswa');

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
          final jawaban = listJawaban.firstWhere(
            (jawaban) => jawaban.soalUjianId == listSoal[index].soalUjianId,
            orElse: () => JawabanUjianModel(
              soalUjianId: listSoal[index].soalUjianId,
              nilaiJawaban: 0,
              bobotNilai: 0,
              jawabanUjianId: 0,
            ),
          );
          controller.text = jawaban.jawabanEsai ?? '';
          return controller;
        });

        // Inisialisasi controller untuk nilai
        nilaiControllers = List.generate(listSoal.length, (index) {
          final controller = TextEditingController();
          final jawaban = listJawaban.firstWhere(
            (jawaban) => jawaban.soalUjianId == listSoal[index].soalUjianId,
            orElse: () => JawabanUjianModel(
              soalUjianId: listSoal[index].soalUjianId,
              nilaiJawaban: 0,
              bobotNilai: 0,
              jawabanUjianId: 0,
            ),
          );
          controller.text = jawaban.nilaiJawaban?.toString() ?? '0';
          return controller;
        });

        // Inisialisasi controller untuk catatan
        catatanControllers = List.generate(listSoal.length, (index) {
          return TextEditingController();
        });

        // Inisialisasi loading buttons
        isLoadingButtons = List.generate(listSoal.length, (index) => false);

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
      orElse: () => JawabanUjianModel(
        soalUjianId: soalUjianId,
        nilaiJawaban: 0,
        bobotNilai: 0,
        jawabanUjianId: 0,
      ),
    );
  }

  // Fungsi untuk menyimpan nilai
  Future<void> _simpanNilai(int index, int jawabanUjianId) async {
    final soal = daftarSoal[index];
    final nilaiText = nilaiControllers[index].text;
    final nilai = int.tryParse(nilaiText);
    final catatan = catatanControllers[index].text;

    if (nilai == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nilai harus berupa angka')));
      return;
    }

    // Validasi nilai tidak boleh negatif
    if (nilai < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nilai tidak boleh negatif')),
      );
      return;
    }

    // Validasi nilai maksimal
    final int maxNilai =
        jawabanSiswa
            .firstWhere(
              (j) => j.soalUjianId == soal.soalUjianId,
              orElse: () => JawabanUjianModel(
                soalUjianId: soal.soalUjianId,
                bobotNilai: 0,
                nilaiJawaban: 0,
                jawabanUjianId: 0,
              ),
            )
            .bobotNilai ??
        0;

    if (nilai > maxNilai) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nilai maksimal adalah $maxNilai')),
      );
      return;
    }

    try {
      // Set loading untuk button tertentu
      setState(() {
        isLoadingButtons[index] = true;
      });

      // Gunakan riverpod untuk update nilai
      final success = await ref
          .read(ujianKelasRiverpodProvider.notifier)
          .updateNilaiJawaban(
            jawabanUjianId: jawabanUjianId,
            nilaiJawaban: double.parse(nilaiText),
          );

      // Reset loading
      setState(() {
        isLoadingButtons[index] = false;
      });

      if (success) {
        // Tampilkan dialog sukses
        _showSuccessDialog(context, 'Nilai berhasil disimpan!', () {
          // Update local state setelah dialog ditutup
          setState(() {
            final jawabanIndex = jawabanSiswa.indexWhere(
              (j) => j.soalUjianId == soal.soalUjianId,
            );
            if (jawabanIndex != -1) {
              jawabanSiswa[jawabanIndex] = jawabanSiswa[jawabanIndex].copyWith(
                nilaiJawaban: nilai,
                statusJawaban: 'Telah Dinilai',
              );
            }
          });
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal menyimpan nilai')));
      }
    } catch (e) {
      setState(() {
        isLoadingButtons[index] = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Fungsi untuk menampilkan dialog sukses
  void _showSuccessDialog(
    BuildContext context,
    String message,
    VoidCallback onOkPressed,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Text('Berhasil', style: TextStyle(color: Colors.green)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onOkPressed();
            },
            child: Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menyimpan semua nilai sekaligus
  Future<void> _simpanSemuaNilai() async {
    try {
      // Tampilkan loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      bool semuaBerhasil = true;
      List<Future<bool>> futures = [];

      for (int i = 0; i < daftarSoal.length; i++) {
        final soal = daftarSoal[i];
        if (soal.tipeSoal == 'Esai') {
          final nilaiText = nilaiControllers[i].text;
          final nilai = int.tryParse(nilaiText);
          final catatan = catatanControllers[i].text;

          if (nilai != null && nilai >= 0) {
            // futures.add(
            //   ref
            //       .read(ujianKelasRiverpodProvider.notifier)
            //       .updateNilaiEsai(
            //         soalUjianId: soal.soalUjianId,
            //         nilai: nilai,
            //         catatan: catatan.isNotEmpty ? catatan : null,
            //       ),
            // );
          }
        }
      }

      final results = await Future.wait(futures);
      semuaBerhasil = results.every((result) => result);

      Navigator.pop(context); // Tutup loading

      if (semuaBerhasil) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua nilai berhasil disimpan')),
        );

        // Reload data untuk update status
        await _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Beberapa nilai gagal disimpan')),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadDataSiswa();
  }

  Future<void> _loadDataSiswa() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Anda mungkin perlu mengambil nama dan NIS dari API atau shared preferences
      namaSiswa = prefs.getString('namaSiswa') ?? 'Siswa';
      nisSiswa = prefs.getInt('nisSiswa') ?? 0;
    });
  }

  @override
  void dispose() {
    // Dispose semua controller
    for (var controller in esaiControllers) {
      controller.dispose();
    }
    for (var controller in nilaiControllers) {
      controller.dispose();
    }
    for (var controller in catatanControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: const Text('Detail Pengerjaan Ujian'),
      //   backgroundColor: Colors.blue,
      //   foregroundColor: Colors.white,
      //   actions: [
      //     if (!isLoading && daftarSoal.isNotEmpty)
      //       IconButton(
      //         icon: const Icon(Icons.save),
      //         onPressed: _simpanSemuaNilai,
      //         tooltip: 'Simpan Semua Nilai',
      //       ),
      //   ],
      // ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : daftarSoal.isEmpty
          ? const Center(child: Text('Tidak ada soal ditemukan'))
          : Column(
              children: [
                // Header informasi siswa
                // Container(
                //   width: double.infinity,
                //   padding: const EdgeInsets.all(16),
                //   decoration: BoxDecoration(
                //     color: Colors.blue[50],
                //     border: Border.all(color: Colors.blue[100]!),
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(
                //         'Nama: $namaSiswa',
                //         style: const TextStyle(
                //           fontWeight: FontWeight.bold,
                //           fontSize: 16,
                //         ),
                //       ),
                //       const SizedBox(height: 4),
                //       Text(
                //         'NIS: $nisSiswa',
                //         style: const TextStyle(
                //           fontSize: 14,
                //           color: Colors.grey,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: daftarSoal.length,
                    itemBuilder: (context, index) {
                      final soal = daftarSoal[index];
                      final jawaban = _getJawabanForSoal(soal.soalUjianId);
                      return _buildSoalItem(soal, jawaban, index);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSoalItem(
    SoalUjianSiswa soal,
    JawabanUjianModel jawaban,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header nomor soal dan tipe
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Soal ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                Chip(
                  label: Text(
                    soal.tipeSoal,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: soal.tipeSoal == 'Pilihan Ganda'
                      ? Colors.green
                      : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Teks soal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow[100]!),
              ),
              child: Text(
                soal.soal,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),

            // Jawaban user
            const Text(
              "Jawaban Siswa:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            // Tampilkan berdasarkan tipe soal
            if (soal.tipeSoal == 'Pilihan Ganda') ...[
              _buildPilganReview(soal, jawaban),
            ] else if (soal.tipeSoal == 'Esai') ...[
              _buildEsaiReview(soal, jawaban, index),
            ],

            const SizedBox(height: 12),

            // Status dan nilai
            if (jawaban.statusJawaban != null)
              Container(
                padding: const EdgeInsets.all(8),
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
                    const SizedBox(width: 4),
                    Text(
                      '${jawaban.statusJawaban!}${jawaban.nilaiJawaban != null ? ' - Nilai: ${jawaban.nilaiJawaban}' : ''}',
                      style: const TextStyle(
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

        const SizedBox(height: 8),

        // Tampilkan kunci jawaban
        if (kunciJawaban != null && kunciJawaban.isNotEmpty)
          Text(
            'Kunci Jawaban: $kunciJawaban',
            style: const TextStyle(
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
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: textColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Jawaban Siswa',
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
    final nilaiController = nilaiControllers[index];
    final catatanController = catatanControllers[index];
    final isLoading = index < isLoadingButtons.length
        ? isLoadingButtons[index]
        : false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Jawaban esai siswa
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            controller.text.isEmpty
                ? 'Siswa belum mengisi jawaban'
                : controller.text,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),

        // Input untuk memberikan nilai
        Text(
          "Bobot nilai : ${jawaban.bobotNilai ?? 0}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: nilaiController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nilai maksimal : ${jawaban.bobotNilai}',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (value.isEmpty) return;

                  // Validasi input
                  final numValue = int.tryParse(value);

                  if (numValue != null && numValue < 0) {
                    nilaiController.text = '0';
                  }

                  final int maxNilai = jawaban.bobotNilai ?? 0;
                  if (numValue! > maxNilai) {
                    nilaiController.text = maxNilai.toString();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => _simpanNilai(index, jawaban.jawabanUjianId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Simpan Nilai'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Input catatan
        // TextField(
        //   controller: catatanController,
        //   decoration: const InputDecoration(
        //     labelText: 'Catatan (Opsional)',
        //     border: OutlineInputBorder(),
        //     hintText: 'Berikan catatan untuk jawaban ini...',
        //     contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        //   ),
        //   maxLines: 3,
        // ),
        if (jawaban.nilaiJawaban != null && jawaban.nilaiJawaban! > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Nilai Saat Ini: ${jawaban.nilaiJawaban}',
              style: const TextStyle(
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
      case 'Telah Dinilai':
        return Colors.blue;
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
      case 'Telah Dinilai':
        return Icons.assignment_turned_in;
      default:
        return Icons.help_outline;
    }
  }
}

// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../../models/guru/daftar_pengumpulan_tugas.dart';
import '../../../../../controllers/guru/tugas/tugas_kelas_riverpod.dart';
import '../../../../../shared_widgets/general_old/rich_textfield_widget.dart';
import '../../../../../shared_widgets/general_old/textfield2_widget.dart';

class DialogPenilaianTugas extends ConsumerStatefulWidget {
  final DaftarPengumpulanTugas data;

  const DialogPenilaianTugas({super.key, required this.data});

  @override
  ConsumerState<DialogPenilaianTugas> createState() =>
      _DialogPenilaianTugasState();
}

class _DialogPenilaianTugasState extends ConsumerState<DialogPenilaianTugas> {
  final TextEditingController nilaiController = TextEditingController();
  final TextEditingController feedbackController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set nilai dan feedback yang sudah ada jika ada
    if (widget.data.nilai != null && widget.data.nilai! > 0) {
      nilaiController.text = widget.data.nilai!.toString();
      feedbackController.text = widget.data.feedback ?? '';
    }
    if (widget.data.feedback != null) {
      feedbackController.text = widget.data.feedback!;
    }
  }

  Future<void> _simpanPenilaian() async {
    if (nilaiController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nilai harus diisi')));
      return;
    }

    final double? nilai = double.tryParse(nilaiController.text);
    if (nilai == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nilai harus berupa angka')));
      return;
    }

    if (nilai < 0 || nilai > 100) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nilai harus antara 0-100')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final success = await ref
          .read(tugasKelasRiverpodProvider.notifier)
          .addNilaiTugas(
            pengumpulanTugasId: widget.data.pengumpulanTugasId!,
            nilai: nilai,
            feedback: feedbackController.text,
          );

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nilai berhasil disimpan')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal menyimpan nilai')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
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
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Symbols.assignment, size: 24),
          const SizedBox(width: 8),
          Text('Penilaian - ${widget.data.namaSiswa}'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informasi Siswa
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data.namaSiswa,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('NIS: ${widget.data.nis}'),
                    Text(
                      'Status: ${widget.data.statusPengumpulan ?? 'Belum Mengumpulkan'}',
                    ),
                    if (widget.data.tanggalPengumpulan != null)
                      Text(
                        'Tanggal Pengumpulan: ${widget.data.tanggalPengumpulan}',
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // File yang Dikumpulkan
            if (widget.data.filePengumpulanTugas.isNotEmpty) ...[
              const Text(
                'File yang Dikumpulkan:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ...widget.data.filePengumpulanTugas.map((file) {
                final fileName = _getFileNameFromUrl(file['link_file'] ?? '');
                return Card(
                  child: ListTile(
                    leading: const Icon(Symbols.attachment, size: 20),
                    title: Text(fileName, style: const TextStyle(fontSize: 12)),
                    dense: true,
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // Input Nilai
            TextField2GeneralWidget(
              title: "Nilai",
              hintText: "Masukkan nilai (0-100)",
              pController: nilaiController,
              isRequired: true,
            ),

            const SizedBox(height: 16),

            // Input Feedback
            RichTextFieldGeneralWidget(
              title: "Feedback",
              hintText: "Masukkan feedback untuk siswa...",
              p_controller: feedbackController,
              isRequired: false,
              pMinLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _simpanPenilaian,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff016EB3),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Simpan Nilai',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}
